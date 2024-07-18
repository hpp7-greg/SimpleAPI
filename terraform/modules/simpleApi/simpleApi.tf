# create ecr repo
resource "aws_ecr_repository" "simple-api-ecr-repo" {
  name = var.ecr_repo
}

# get authorization credentials to push to ecr
data "aws_ecr_authorization_token" "token" {}

# build docker image - need to increment image name each time a rebuild is required for lambda source code
resource "docker_image" "simple-api-image" {
  name = "868024899531.dkr.ecr.us-east-2.amazonaws.com/${aws_ecr_repository.simple-api-ecr-repo.name}:0.0.2"
  build {
    context = "./../../../source"
  }
  platform = "linux/arm64"
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "./../../../source/*") : filesha1(f)]))
  }
  depends_on = [ aws_ecr_repository.simple-api-ecr-repo ]
}

# push image to ecr repo
resource "docker_registry_image" "lambda-image" {
  name = docker_image.simple-api-image.name
  depends_on = [ docker_image.simple-api-image ]
}

resource "aws_lambda_function" "simple-api-lambda" {
  function_name = "simple-api-${var.environment}"
  timeout       = 5 # seconds
  image_uri     = "${docker_image.simple-api-image.name}"
  package_type  = "Image"

  role = aws_iam_role.lambda_exec.arn

  depends_on = [ docker_image.simple-api-image, docker_registry_image.lambda-image ]
}

resource "aws_cloudwatch_log_group" "simple-api-log-group" {
  name = "/aws/lambda/${aws_lambda_function.simple-api-lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_role_name}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "simple-api" {
  name          = "${var.gateway_name}-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "simple-api-stage" {
  api_id = aws_apigatewayv2_api.simple-api.id

  name        = "${var.stage_name}-${var.environment}"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.simple-api-gw-log-group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "simple-api-lambda-integration" {
  api_id = aws_apigatewayv2_api.simple-api.id

  integration_uri    = aws_lambda_function.simple-api-lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "simple-api-gw-route" {
  api_id = aws_apigatewayv2_api.simple-api.id

  route_key = "GET /timeMe"
  target    = "integrations/${aws_apigatewayv2_integration.simple-api-lambda-integration.id}"
}

resource "aws_cloudwatch_log_group" "simple-api-gw-log-group" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.simple-api.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "simple-api-gw-lambda-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.simple-api-lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.simple-api.execution_arn}/*/*"
}
