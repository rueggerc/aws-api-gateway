
########################################################
# API Gateway Lambda Integration Module Input Variables
########################################################

variable region {
  description = "AWS Region"
}

variable env {
  description = "Environment we are deplying to"
}

variable rest_api_id {
  description = "API Gateway REST API ID"
}

variable rest_api_root_resource_id {
  description = "API Gateway REST API Root Resource ID"
}

variable lambda_arn {
  description = "ARN of Lambda to be invoked from API Gateway"
}

variable lambda_function_name {
  description = "Name of Lambda to be invoked from API Gateway"
}

variable "path_part" {
    description = "Path to use for invoking Lambda"
}

variable "authorizer_id" {
    description = "API Gateway Authorizer ID"
}

variable "accountId" {
    description = "Current AWS Identify"
}



