import json
import os
from datetime import UTC, datetime

import boto3


s3_client = boto3.client("s3")


def lambda_handler(event, context):
    """Write the processed payload to S3 and return only non-sensitive metadata."""
    bucket_name = os.environ["BUCKET_NAME"]
    request_body = event.get("body") or "{}"
    payload = json.loads(request_body)

    # The object key keeps enough context for operations to trace writes without
    # exposing raw customer data in the path itself.
    object_key = "processed/{timestamp}-{request_id}.json".format(
        timestamp=datetime.now(UTC).strftime("%Y%m%dT%H%M%SZ"),
        request_id=getattr(context, "aws_request_id", "unknown"),
    )

    processed_payload = {
        "request_id": getattr(context, "aws_request_id", "unknown"),
        "processed_at": datetime.now(UTC).isoformat(),
        "attributes": payload.get("attributes", {}),
        "status": "stored",
    }

    s3_client.put_object(
        Bucket=bucket_name,
        Key=object_key,
        Body=json.dumps(processed_payload).encode("utf-8"),
        ContentType="application/json",
        ServerSideEncryption="AES256",
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"request_id": processed_payload["request_id"], "object_key": object_key, "status": "ok"}),
    }
