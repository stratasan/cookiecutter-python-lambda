# {{cookiecutter.name}}

## Business!

(Please write some prose about the specific business logic this
service is implementing)

## Testing / CICD

This service is deployed with GitHub Actions.

Tests can be run locally by installing `requirements-test.txt` and
running `make test`.

(More about observing the service in DD if you'd like)

## Other stuff

This is an automatically-generated package using [cookiecutter](https://cookiecutter.readthedocs.io/).

This projects includes the following files:

- handler.py: This is the entrypoint to the lambda function. It shouldn't do much except crack open the event and pass it along to business logic written in
- {{cookiecutter.package_name}}: This is a python package for actual business logic
- lambda.tf,sources.tf,iam.tf: Terraform files for automatically generating:
  - the lambda function
  - an IAM role it will run as
  - cloudwatch log group
  - (potentially a SQS/Lambda event connection)
- Makefile to do some things like package, applying TF, etc
- requirements.txt and requirements-test.txt: specify 3rd-party libs here
- tests/ directory to hold tests because you will add more tests :)
- {{cookiecutter.name}}.yml: a github actions workflow file to implement CICD for your project

## Using Vault

If this service uses vault, please implement the following:

In star/ops/terraform/infra/iam/vault/vault.tf add the following:

```
resource "vault_generic_secret" "{{ cookiecutter.name }}-role" {
  path = "auth/aws/role/${data.terraform_remote_state.{{ cookiecutter.name }}.outputs.iam_name}"

  data_json = <<EOT
{
  "bound_iam_principal_arn": "${data.terraform_remote_state.{{ cookiecutter.name }}.outputs.iam_arn}",
  "policies": "default,${vault_policy.star-services-policy.name}",
  "max_ttl":"60",
  "resolve_aws_unique_ids": "false"
}
EOT
}
```

And in star/ops/terraform/infra/iam/vault/sources.tf add this snippet:

```
data "terraform_remote_state" "{{ cookiecutter.name }}" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "com-stratasan-star-v1-terraform"
    key    = "lambda/{{ cookiecutter.name }}/terraform.tfstate"
    region = "us-east-1"
  }
}
```

After those snippets have been added, make sure the following are done:

1. login to vault
2. submit a PR for this new service so that CICD builds the dev IAM role
3. in star/ops/terraform/infra/iam/vault, run `terraform workspace select dev && terraform apply -auto-approve`. This is very
   important as it actually builds the necessary auth structures that will let your lambda authenticate and read from Vault.
4. When your PR is merged, run `terraform workspace select prod && terraform apply -auto-approve`. This is also necessary so that the production service can interact with vault as well.

For reasons (the biggest being vault is not on public internet), these things can't be done within CICD so they must be done manually, but only once.
