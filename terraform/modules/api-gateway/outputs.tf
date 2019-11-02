output "api_gateway_api_id" {
    value = "${aws_api_gateway_rest_api.api.id}"
}

output "api_gateway_authorizer_id" {
    value = "${aws_api_gateway_authorizer.authorizer.id}"
}