#######################################
# API Gateway Module
#######################################



# API Gateway
resource "aws_api_gateway_rest_api" "api" {
    name = "${upper(var.name)}"
}

# Authorizer 
resource "aws_api_gateway_authorizer" "authorizer" {
    name                   = "${var.authorizer_name}"
    rest_api_id            = "${aws_api_gateway_rest_api.api.id}"
    authorizer_uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.authorizer_lambda_arn}/invocations"
    // authorizer_credentials = "${var.invoke_role}"
}


###################################################
# Deployment
###################################################
# resource "aws_api_gateway_deployment" "deployment" {
#     rest_api_id         = "${aws_api_gateway_rest_api.api.id}"
#     stage_name          = "${var.stage_name}"

#     // Force Stage to be Deployed
#     stage_description   = "Stage Deployed at Time: ${timestamp()}"
# }