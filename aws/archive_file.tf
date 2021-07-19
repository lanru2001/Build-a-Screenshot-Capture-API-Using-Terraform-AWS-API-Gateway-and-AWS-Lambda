data "archive_file" "screenshot_service_zip" {
  type        = "zip"
  source_dir  = "./lambda"
  output_path = "./screenshot-service.zip"
}

data "archive_file" "screenshot_service_layer_zip" {
  type = "zip"
  source_dir = "./chromedriver_layer"
  output_path = "./chromedriver_lambda_layer.zip"
}
