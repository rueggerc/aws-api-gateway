
// MODULE:lambda Variables


variable "environment_variables" {
  description = "Lambda Environment Variables"
  type = "map"
}

variable "function_name" {
  description = "Authorizer Function Name"
}

variable "handler" {
  description = "Lambda Handler"
}

variable "runtime" {
  description = "Lambda Runtime"
}

variable "role" {
  description = "Lambda Execution Role"
}

variable "tags" {
  description = "Lambda Tags"
  type = "map"
}

variable "memory" {
  description = "Lambda Memory"
}

variable "timeout" {
  description = "Lambda Timeout"
}


variable "filename" {
  description = "Lambda Zip File"
}