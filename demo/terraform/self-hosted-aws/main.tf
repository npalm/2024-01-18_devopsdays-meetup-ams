locals {
  environment = var.environment != null ? var.environment : "default"
  aws_region  = "eu-west-1"
}

resource "random_id" "random" {
  byte_length = 20
}

module "base" {
  source = "./base"

  prefix     = local.environment
  aws_region = local.aws_region
}

module "download" {
  source  = "philips-labs/github-runner/aws//modules/download-lambda"
  version = "5.6.2"
  lambdas = [
    {
      name = "webhook"
      tag  = "v5.6.2"
    },
    {
      name = "runners"
      tag  = "v5.6.2"
    },
    {
      name = "runner-binaries-syncer"
      tag  = "v5.6.2"
    }
  ]
}

module "runners" {
  depends_on = [ module.download ]
  source                          = "philips-labs/github-runner/aws"
  version                         = "5.6.2"
  create_service_linked_role_spot = true
  aws_region                      = local.aws_region
  vpc_id                          = module.base.vpc.vpc_id
  subnet_ids                      = module.base.vpc.private_subnets

  prefix = local.environment

  github_app = {
    key_base64     = var.github_app.key_base64
    id             = var.github_app.id
    webhook_secret = random_id.random.hex
  }


  # Grab zip files via lambda_download
  webhook_lambda_zip                = "./webhook.zip"
  runner_binaries_syncer_lambda_zip = "./runner-binaries-syncer.zip"
  runners_lambda_zip                = "./runners.zip"

  enable_organization_runners = false
  runner_extra_labels         = ["demo"]

  # enable access to the runners via SSM
  enable_ssm_on_runners = true

  instance_types = ["m5.large", "c5.large"]

  # override delay of events in seconds
  delay_webhook_event   = 5
  runners_maximum_count = 3

  # set up a fifo queue to remain order
  enable_fifo_build_queue = true

  scale_down_schedule_expression        = "cron(* * * * ? *)"
  enable_user_data_debug_logging_runner = true
  runner_name_prefix                    = "${local.environment}_"

  enable_ami_housekeeper = false
}

module "webhook_github_app" {
  source  = "philips-labs/github-runner/aws//modules/webhook-github-app"
  version = "5.6.2"
    depends_on = [module.runners]

  github_app = {
    key_base64     = var.github_app.key_base64
    id             = var.github_app.id
    webhook_secret = random_id.random.hex
  }
  webhook_endpoint = module.runners.webhook.endpoint
}

//role_scale_up

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::*devopsdays-meetup-ams*"]
  }
}

## attach policy aws_iam_policy_document.s3 to  moudule runners output role runners.role_scale_up 
resource "aws_iam_role_policy" "s3" {
  name   = "s3-policy"
  role       = module.runners.runners.role_runner.name
  policy = data.aws_iam_policy_document.s3.json
}

