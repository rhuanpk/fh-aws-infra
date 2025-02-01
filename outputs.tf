output "endpoint_bd_video" {
  description = "Endpoint da instância RDS - video: "
  value       = aws_db_instance.video.endpoint
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_user_pool_client_secret" {
  value     = aws_cognito_user_pool_client.user_pool_client.client_secret
  sensitive = true
}

output "s3_bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "sqs_queue_name" {
  value = aws_sqs_queue.example.name
}
