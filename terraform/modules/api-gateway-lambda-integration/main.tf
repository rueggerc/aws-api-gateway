
#######################################
# API Gateway Integration Module
#######################################

# Resource
resource "aws_api_gateway_resource" "resource" {
    rest_api_id = "${var.rest_api_id}"
    parent_id   = "${var.rest_api_root_resource_id}"
    path_part   = "${var.path_part}"
}

# Method
resource "aws_api_gateway_method" "request_method" {
    rest_api_id = "${var.rest_api_id}"
    resource_id = "${aws_api_gateway_resource.resource.id}"
    http_method = "GET"
    authorization = "CUSTOM"
    authorizer_id = "${var.authorizer_id}"
}


# Integration Between API Gateway and Lambda
resource "aws_api_gateway_integration" "request_method_integration" {
    rest_api_id             = "${var.rest_api_id}"
    resource_id             = "${aws_api_gateway_resource.resource.id}"
    http_method             = "${aws_api_gateway_method.request_method.http_method}"

    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "arn:aws:apigateawy:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
}


 # Permission
 resource "aws_lambda_permission" "allow_api_gateway" {
    statement_id  = "AllowExecutionFromApiGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${var.lambda_function_name}"
    principal     = "apigateway.amazonaws.com"
    source_arn    = "arn:aws:execute-api:${var.region}:${var.accountId}:${var.rest_api_id}/*/${aws_api_gateway_method.request_method.http_method}${aws_api_gateway_resource.resource.path}"
 }

