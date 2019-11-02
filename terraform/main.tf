provider "aws" {
  region = "${var.region}"
}

# Backend
terraform {
    backend "s3" {
        bucket = "rueggerllc-terraform-state"
        key = "aws-lambda-api/us-east-1/dev/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "rueggerllc-terraform-locks"
        encrypt = true
    }
}

# Remote State
data "terraform_remote_state" "iam_roles" {
    backend = "s3"
    config = {
        bucket = "rueggerllc-terraform-state"
        key = "aws-iam-roles/${var.region}/${var.env}/terraform.tfstate"
        region = "${var.region}"
    }
}

# AWS Account
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
# API Gateway and Authorizer
##################################
module "api_gateway" {
    source                = "./modules/api-gateway"
    name                  = "${var.api_gateway_name}-${upper(var.env)}"
    accountId             = "${data.aws_caller_identity.current_account.account_id}"
    invoke_role           = "${data.terraform_remote_state.iam_roles.outputs.rueggerllc_api_gateway_lambda_invoke_role_arn}"
    authorizer_lambda_arn = "${module.lambda_authorizer.arn}"
    region                = "${var.region}"
    stage_name            = "${var.env}"
}