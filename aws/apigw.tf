#This API will be used to direct all requests that are made for the screenshot service

resource "aws_api_gateway_rest_api" "screenshot_api" {
  name        = "screenshot_api"
  description = "Lambda-powered screenshot API"
  depends_on = [
    aws_lambda_function.take_screenshot
  ]
}

#The API Gateway resource for the lambda function

  resource "aws_api_gateway_resource" "screenshot_api_gateway" {
  path_part   = "screenshot"
  parent_id   = aws_api_gateway_rest_api.screenshot_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.screenshot_api.id
}

#Create a stage for the API. A stage is a fancy way of naming our deployment of the API. 
#You can configure caching, logging, request throttling, and more using a stage

resource "aws_api_gateway_stage" "dev_stage" {
  stage_name = "dev"
  rest_api_id = aws_api_gateway_rest_api.screenshot_api.id
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment_get.id
}

#Create an API key and usage plan tied to our stage, so that only users with knowledge of the key can use this service.

resource "aws_api_gateway_usage_plan" "apigw_usage_plan" {
  name = "apigw_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.screenshot_api.id
    stage = aws_api_gateway_stage.dev_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "apigw_usage_plan_key" {
  key_id = aws_api_gateway_api_key.apigw_dev_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.apigw_usage_plan.id
}

resource "aws_api_gateway_api_key" "apigw_dev_key" {
  name = "dev_key"
}

#Configure the API to respond to either a GET or POST request if a valid API Gateway Key is provided.

resource "aws_api_gateway_method" "take_screenshot_get" {
  rest_api_id   = aws_api_gateway_rest_api.screenshot_api.id
  resource_id   = aws_api_gateway_resource.screenshot_api_gateway.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "take_screenshot_post" {
  rest_api_id   = aws_api_gateway_rest_api.screenshot_api.id
  resource_id   = aws_api_gateway_resource.screenshot_api_gateway.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

#API Gateway permission to invoke the lambda function 
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.take_screenshot.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.screenshot_api.execution_arn}/*/*/*"
}

#Set up API Gateway integration with the lambda function.
#This integration tells the API Gateway what lambda function to invoke when it receives a request at the specified endpoint and HTTP method.

resource "aws_api_gateway_integration" "lambda_integration_get" {
  depends_on = [
    aws_lambda_permission.apigw
  ]
  rest_api_id = aws_api_gateway_rest_api.screenshot_api.id
  resource_id = aws_api_gateway_method.take_screenshot_get.resource_id
  http_method = aws_api_gateway_method.take_screenshot_get.http_method

  integration_http_method = "POST" # https://github.com/hashicorp/terraform/issues/9271 Lambda requires POST as the integration type
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.take_screenshot.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_integration_post" {
  depends_on = [
    aws_lambda_permission.apigw
  ]
  rest_api_id = aws_api_gateway_rest_api.screenshot_api.id
  resource_id = aws_api_gateway_method.take_screenshot_post.resource_id
  http_method = aws_api_gateway_method.take_screenshot_post.http_method

  integration_http_method = "POST" # https://github.com/hashicorp/terraform/issues/9271 Lambda requires POST as the integration type
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.take_screenshot.invoke_arn
}
