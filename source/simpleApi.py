import json
from datetime import datetime


def handler(event, context):
    print(type(event))
    print(event)
    data = event
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(
            {
                "requestorIp": data["requestContext"]["identity"]["sourceIp"],
                "timestamp"  : str(datetime.now())
            }),
    }


if __name__ == "__main__":
    ## a change
    samplePayload = {
        "version": "2.0",
        "rawPath": "/default/",
        "cookies": [
        ],
        "headers": {
            "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            "accept-encoding": "gzip, deflate, br",
        },
        "requestContext": {
            "accountId": "123456789012",
            "apiId": "r3pmxmplak",
            "domainName": "r3pmxmplak.execute-api.us-east-2.amazonaws.com",
            "domainPrefix": "r3pmxmplak",
            "http": {
                "method": "GET",
                "path": "/default/nodejs-apig-function-1G3XMPLZXVXYI",
                "protocol": "HTTP/1.1",
                "sourceIp": "205.255.255.176",
                "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36"
            },
        },
        "isBase64Encoded": "true"
    }
    print(handler(samplePayload, None))