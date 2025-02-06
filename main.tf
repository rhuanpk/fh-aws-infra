provider "aws" {
  region = "us-east-1"
}

# Buscando subnet para BD
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = slice(data.aws_subnets.default_subnets.ids, 0, 2)

  tags = {
    Name = "rds-db-subnet-group"
  }
}

# Grupo de segurança BD
resource "aws_security_group" "rds_mysql_sg" {
  vpc_id      = data.aws_vpc.default.id
  name        = "rds-mysql-sg"
  description = "Grupo de seguranca para RDS MySQL"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Criando BD
resource "aws_db_instance" "video" {
  identifier             = "mysql-fh-video"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_name                = "video"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
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
  name            = "HackUserPoolClient"
  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = true
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

# Criação do bucket S3 com acesso público para download (sem ACLs)
resource "aws_s3_bucket" "example" {
  bucket = "hackvideobucket00-${random_id.bucket_id.hex}"
}

resource "random_id" "bucket_id" {
  byte_length = 8
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

# Configuração do S3 para enviar eventos ao SQS
resource "aws_s3_bucket_notification" "example_notification" {
  bucket = aws_s3_bucket.example.id

  queue {
    queue_arn     = aws_sqs_queue.example.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ""
  }

  depends_on = [aws_s3_bucket.example, aws_sqs_queue_policy.example_policy]
}


