

region = "us-east-1"
lambda_handler = "index.handler"
lambda_runtime = "nodejs10.x"
env = "dev"


# API Gateway
api_gateway_name                = "Sensor API"
authorizer_name                 = "Sensor-API-Authorizer"

# Authorizer
lambda_authorizer_function_name = "API-GATEWAY-AUTHORIZER"
lambda_authorizer_zip_file      = "sensor-authorizer.${version}.zip"
lambda_authorizer_memory        = "128"
lambda_authorizer_timeout       = "5"


# Environment Variables
environment_variables = {
  SSM_SENSORS_ROOT = "/mw/sensors/dev"
}

# Tags
lambda_authorizer_tags = { 
  CreatedBy = "Chris"
  Service   = "API Gateway Authorizer"
  Company   = "Ruegger Consulting LLC"
  Version   = "${version}"
}
