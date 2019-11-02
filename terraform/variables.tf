

#############################
# Global
#############################
variable "region" {
  description = "Region in which to deploy resources"
}

variable env {
  description = "Environment We Deploy To"
}

variable "lambda_handler" {
  description = "Lambda Handler"
  default = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda Runtime"
  default = "nodejs10.x"
}

#############################
# API Gateway
#############################
variable api_gateway_name {
  description = "API Gateway Name"
}

#############################
# Authorizer
#############################

variable "lambda_authorizer_function_name" {
  description = "Authorizer Function Name"
}

variable "lambda_authorizer_zip_file" {
  description = "Authorizer ZIP file"
}


variable "environment_variables" {
  description = "Lambda Environment Variables"
  type = "map"
}

variable "lambda_authorizer_tags" {
  description = "Lambda Tags"
  type = "map"
}

variable "lambda_authorizer_memory" {
  description = "Lambda Authorizer Memory"
}

variable "lambda_authorizer_timeout" {
  description = "Lambda Authorizer Timeout"
}
