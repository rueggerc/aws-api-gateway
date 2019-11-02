
// Lambda Module Definition


resource "aws_lambda_function" "lambda" {
    function_name       = "${var.function_name}"
    role                = "${var.role}"
    handler             = "${var.handler}"
    runtime             = "${var.runtime}"
    filename            = "${var.filename}"
    source_code_hash    = "${filebase64sha256(var.filename)}"
    memory_size         = "${var.memory}"
    timeout             = "${var.timeout}"


    environment {
      variables = "${var.environment_variables}"
    }

    tags = "${var.tags}"

}