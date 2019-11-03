
##########################################
# API Gateway Module Output Variables
##########################################

output "api_id" {
    value = "${aws_api_gateway_rest_api.api.id}"
}

output "root_resource_id" {
    value = "${aws_api_gateway_rest_api.api.root_resource_id}"
}


output "authorizer_id" {
    value = "${aws_api_gateway_authorizer.authorizer.id}"
}