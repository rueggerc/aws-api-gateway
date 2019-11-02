

variable region {
  description = "AWS Region"
}

variable invoke_role {
  description = "Role to use to Invoke Authorizer from API Gateway"
}

variable name {
  description = "API Gateway Name"
  default = "Sensor API"
}

variable authorizer_name {
  description = "API Gateway Authorizer Name"
  default = "Sensor API Authorizer"
}

variable authorizer_lambda_arn {
  description = "API Gateway Authorizer ARN"
}

variable accountId {
  description = "AWS Account ID"
}

variable stage_name {
    description = "API Gateway Stage Name"
}
