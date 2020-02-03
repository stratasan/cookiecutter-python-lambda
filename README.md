# cookiecutter-python-lambda

## tl;dr

This cookiecutter project is a quick way to start a python Lambda function and includes:

* A Makefile for building, testing and packaging a python package for use in Lambda.
* A Github Actions workflow for keeping the service up-to-date. This includes building, testing, linting Terraform and running TF plans and applys to update the function.
* Terraform files to build the Lambda function, an IAM role the function will use, an IAM policy so it can actually do things, a Cloudwatch log group, SQS queue to provide messages to the function and other errata.
* An initial `handler.py`

## This is not likely useful to you out of the box

This is a public project but there is a lot of stuff specific to our applications and way of thinking. We're not looking for outside contributions but want to put this out into the world to provide inspiration for other people interested in building better developer experiences, etc.

## Why does this exist?

As we've begun writing more event-driven services, the need for Stratasan developers to own these services end-to-end has increased. First and foremost, we want our operations folks to focus on the hard, organizational-wide things like defining VPCs, ensuring traffic routes across them correctly, ACLs, security, etc. It is our belief that application developers should run their own services, from initial creation through testing, deployments, monitoring and fixing issues.

However, the leg-work involved in making a production-ready Lambda is significant. Things that are generally
shared or should be done extremely similar across these services include:

* Modern CICD pipeline
* Centralized logging and monitoring
* A good start towards role-specific IAM permissions
* Agreed upon ways to get events to these lambdas
* Shared libraries should be installed by default

We use [Terraform](https://www.terraform.io/) to simplify the specification and improve maintainability of
our Lambda functions, but being successful with Terraform ultimately means being successful at your cloud. Becoming proficient with AWS never ends, so we decided to build this "starter package" to reduce the need for everyone to learn their own way of doing things (which in practice means everybody does everything differently).

## Using this project

Having installed [cookiecutter](https://cookiecutter.readthedocs.io/en/1.7.0/), run:

```
$ cookiecutter gh:stratasan/cookiecutter-lambda-python/
[answer questions that cookiecutter asks you]
```

## Philosophical decisions

You may or may not agree with these. Either way, that's ok.

### Terraform workspaces

We use [Terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) to separate `dev` and `prod` instances of the same resource. It's not perfect, but is a suitable trade-off for us.

### SNS -> SQS -> Lambda

Our general architecture for driving these event-based lambdas is for producers (web front-ends, API servers) to submit [SNS](https://aws.amazon.com/sns/) messages into topics. Using a [Subscription Filter](https://docs.aws.amazon.com/sns/latest/dg/sns-subscription-filter-policies.html), we can direct these messages into specific a [SQS](https://docs.aws.amazon.com/sns/latest/dg/sns-subscription-filter-policies.html) queue based on Message Attributes. So rather than a 1:1 mapping between topics and queues, we can use SNS the way it was meant to be, as a fan out with potentially multiple queues receiving the same message.

There, an [Event Source Mapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html) connects the queue to our Lambda function. In the case where a service needs more than the 15-minute maximum timeout provided by Lambda, we can move to packaging our code into a container and running on Fargate in ECS. The SNS->SQS architecture remains the same, however. Most importantly, producers do not need to change at all.

### Make is your friend

The Github Actions workflows are relatively generic with real logic resting in the Makefiles. Because the workflows must live in `.github/workflows` we've found it easier to keep logic nearby in a `Makefile` rather than put custom stuff in the workflow. YMMV.

### GitHub Actions

Speaking of Actions, we are **huge** fans. We appreciate being able to trigger workflows based on changes to specific paths and in general we've found performance to be stellar.
