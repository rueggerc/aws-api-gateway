
########################################################
# Provider
########################################################
provider "aws" {
  region = "${var.region}"
}

########################################################
# Backend
########################################################
terraform {
    backend "s3" {
        bucket = "rueggerllc-terraform-state"
        key = "aws-lambda-api/us-east-1/dev/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "rueggerllc-terraform-locks"
        encrypt = true
    }
}

########################################################
# Remote State IAM Roles
########################################################
data "terraform_remote_state" "iam_roles" {
    backend = "s3"
    config = {
        bucket = "rueggerllc-terraform-state"
        key = "aws-iam-roles/${var.region}/${var.env}/terraform.tfstate"
        region = "${var.region}"
    }
}

########################################################
# Remote State Sensors Service
########################################################
data "terraform_remote_state" "aws_lambda_sensor_service" {
    backend = "s3"
    config = {
        bucket = "rueggerllc-terraform-state"
        key = "aws-lambda-sensor-service/${var.region}/${var.env}/terraform.tfstate"
        region = "${var.region}"
    }
}

########################################################
# Current Account
########################################################
data "aws_caller_identity" "current_account" {
}

##################################
# Lambda Authorizer
##################################
module "lambda_authorizer" {
    source                = "./modules/lambda"
    function_name         = "${upper(var.lambda_authorizer_function_name)}-${upper(var.env)}"
    role                  = "${data.terraform_remote_state.iam_roles.outputs.rueggerllc_execution_role_arn}"
    handler               = "${var.lambda_handler}"
    runtime               = "${var.lambda_runtime}"
    memory                = "${var.lambda_authorizer_memory}"
    timeout               = "${var.lambda_authorizer_timeout}"
    filename              = "${var.lambda_authorizer_zip_file}"
    tags                  = "${var.lambda_authorizer_tags}"
    environment_variables = "${var.environment_variables}"
}

##################################
# API Gateway
##################################
resource "aws_api_gateway_rest_api" "api" {
    name = "${upper(var.api_gateway_name)}-${upper(var.env)}"
}

##################################
# API Gateway Authorizer
##################################
resource "aws_api_gateway_authorizer" "authorizer" {
    name                   = "${var.authorizer_name}"
    rest_api_id            = "${aws_api_gateway_rest_api.api.id}"
    authorizer_uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.lambda_authorizer.arn}/invocations"
    authorizer_credentials = "${data.terraform_remote_state.iam_roles.outputs.rueggerllc_api_gateway_lambda_invoke_role_arn}"
    authorizer_result_ttl_in_seconds = "1"
}

##########################
# SECTION get-sensor-data
#########################


##################################
# Resource /get-sensor-data
##################################
resource "aws_api_gateway_resource" "resource_get_sensor_data" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
    path_part   = "get-sensor-data"
}

#########################################
# Resource /get-sensor-data/{sensor-type}
#########################################
resource "aws_api_gateway_resource" "resource_get_sensor_data_sensor_type" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    parent_id   = "${aws_api_gateway_resource.resource_get_sensor_data.id}"
    path_part   = "{sensor-type}"
}


######################################################
# 1
# Resource /get-sensor-data/{sensor-type}/{sensor-id}
######################################################
resource "aws_api_gateway_resource" "resource_get_sensor_data_sensor_id" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    parent_id   = "${aws_api_gateway_resource.resource_get_sensor_data_sensor_type.id}"
    path_part   = "{sensor-id}"
}

###########################################################
# 2 Get Sensor Data
# Method: GET /get-sensor-data/{sensor-type}/{sensor-id}
###########################################################
# Method
resource "aws_api_gateway_method" "method_get_sensor_data" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    resource_id = "${aws_api_gateway_resource.resource_get_sensor_data_sensor_id.id}"
    http_method = "GET"
    authorization = "CUSTOM"
    authorizer_id = "${aws_api_gateway_authorizer.authorizer.id}"
}

###################################################################################################
# 3 Get Sensor Data 
# Proxy Integration: GET /get-sensor-data/{sensor-type}/{sensor-id}  ==>  invokes GET-SENSOR-DATA
# Remote State Reference: aws_lambda_sensor_service.outputs.get_sensor_data_arn
###################################################################################################
resource "aws_api_gateway_integration" "get_sensor_data_method_integration" {
    rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
    resource_id             = "${aws_api_gateway_resource.resource_get_sensor_data_sensor_id.id}"
    http_method             = "${aws_api_gateway_method.method_get_sensor_data.http_method}"

    # AWS Lambdas can only be invoked with POST method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.aws_lambda_sensor_service.outputs.get_sensor_data_arn}/invocations"
}

################################################################################################
# 4 Get Sensor Data 
# Lambda Permission:  GET /get-sensor-data/{sensor-type}/{sensor-id} => invokes GET-SENSOR-DATA
# Remote State Reference: aws_lambda_sensor_service.outputs.get_sensor_data_function_name
################################################################################################
 resource "aws_lambda_permission" "allow_api_gateway_invoke_get_sensor_data" {
    statement_id  = "AllowExecutionFromApiGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${data.terraform_remote_state.aws_lambda_sensor_service.outputs.get_sensor_data_function_name}"
    principal     = "apigateway.amazonaws.com"
    source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current_account.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method_get_sensor_data.http_method}${aws_api_gateway_resource.resource_get_sensor_data_sensor_id.path}"
    depends_on    = [
        "aws_api_gateway_resource.resource_get_sensor_data"
    ]
 }


##########################
# SECTION set-sensor-data
#########################

resource "aws_api_gateway_resource" "resource_set_sensor_data" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
    path_part   = "set-sensor-data"
}

###########################################################
# 2 Set Sensor Data
# Method: POST /set-sensor-data
###########################################################
# Method
resource "aws_api_gateway_method" "method_set_sensor_data" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    resource_id = "${aws_api_gateway_resource.resource_set_sensor_data.id}"
    http_method = "POST"
    authorization = "CUSTOM"
    authorizer_id = "${aws_api_gateway_authorizer.authorizer.id}"
}

##############################################################################
# 3 Set Sensor Data 
# Proxy Integration: POST /set-sensor-data  ==>  invokes SET-SENSOR-DATA
# Remote State Reference: aws_lambda_sensor_service.outputs.set_sensor_data_arn
###############################################################################
resource "aws_api_gateway_integration" "set_sensor_data_method_integration" {
    rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
    resource_id             = "${aws_api_gateway_resource.resource_set_sensor_data.id}"
    http_method             = "${aws_api_gateway_method.method_set_sensor_data.http_method}"

    # AWS Lambdas can only be invoked with POST method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.aws_lambda_sensor_service.outputs.set_sensor_data_arn}/invocations"
}

#################################################################################
# 4 Set Sensor Data 
# Lambda Permission:  POST /set-sensor-data => invokes SET-SENSOR-DATA
# Remote State Reference: aws_lambda_sensor_service.outputs.set_sensor_data_name
#################################################################################
 resource "aws_lambda_permission" "allow_api_gateway_invoke_set_sensor_data" {
    statement_id  = "AllowExecutionFromApiGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${data.terraform_remote_state.aws_lambda_sensor_service.outputs.set_sensor_data_function_name}"
    principal     = "apigateway.amazonaws.com"
    source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current_account.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method_set_sensor_data.http_method}${aws_api_gateway_resource.resource_set_sensor_data.path}"
    depends_on    = [
        "aws_api_gateway_resource.resource_set_sensor_data"
    ]
 }


###################################################
# Gateway Deployment
###################################################
resource "aws_api_gateway_deployment" "deployment" {
    rest_api_id         = "${aws_api_gateway_rest_api.api.id}"
    stage_name          = "${var.env}"

    // Force Stage to be Deployed
    stage_description   = "Stage Deployed at Time: ${timestamp()}"

    // Depends On
    depends_on = [
      "aws_api_gateway_integration.get_sensor_data_method_integration",
      "aws_api_gateway_integration.set_sensor_data_method_integration"    
    ]

    // Lifecycle
    lifecycle {
        create_before_destroy = true
    }
}