import logging
from os import environ

import structlog  # type: ignore
from solarsystem.lambda_utils import (
    initialize,
    populate_environ_with_secrets,
    extract_message_from_event,
)

# You should import your {{cookiecutter.package_name}} package here


def handler(event, context):
    logger = structlog.get_logger()
    populate_environ_with_secrets()
    initialize()
    logger.info("behold! {{cookiecutter.name}} is alive")
    sns_message: dict = extract_message_from_event(event)
    # Define your logic here!
