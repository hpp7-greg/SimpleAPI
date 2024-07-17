variable "environment" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "lambda_role_name" {
  type = string
}

variable "gateway_name" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "region" {
    type = "string"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}
