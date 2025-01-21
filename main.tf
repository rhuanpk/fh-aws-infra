provider "aws" {
  region = "us-east-1"
}

# Criação do User Pool do Cognito
resource "aws_cognito_user_pool" "user_pool" {
  name = "HackUserPool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  username_attributes = ["email"]

  mfa_configuration = "OFF"

  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
  }
}

# Criação do Cognito User Pool Client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name               = "HackUserPoolClient"
  user_pool_id       = aws_cognito_user_pool.user_pool.id
  generate_secret    = true
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH", 
    "ALLOW_REFRESH_TOKEN_AUTH", 
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH" 
  ]

  callback_urls = ["https://www.example.com"]
  logout_urls   = ["https://www.example.com/logout"]
  
  allowed_oauth_flows  = ["code", "implicit"]
  allowed_oauth_scopes = ["openid", "email", "profile"]

  prevent_user_existence_errors = "ENABLED"
}

# Criação do Domínio do Cognito
resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = "hackuser"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

# Criação do bucket S3 com acesso público para download (sem ACLs)
resource "aws_s3_bucket" "example" {
  bucket = "hackvideobucket01"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Criação da Fila SQS
resource "aws_sqs_queue" "example" {
  name = "hack-sqs-queue"
}

# Configuração do S3 para enviar eventos ao SQS
resource "aws_s3_bucket_notification" "example_notification" {
  bucket = aws_s3_bucket.example.id

  queue {
    queue_arn     = aws_sqs_queue.example.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ""
  }

  depends_on = [aws_s3_bucket.example]
}

# Permissão para o S3 publicar eventos na SQS
resource "aws_sqs_queue_policy" "example_policy" {
  queue_url = aws_sqs_queue.example.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.example.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.example.arn
          }
        }
      }
    ]
  })
}

# Outputs
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

output "cognito_user_pool_domain" {
  value = aws_cognito_user_pool_domain.user_pool_domain.domain
}

output "s3_bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "sqs_queue_name" {
  value = aws_sqs_queue.example.name
}
