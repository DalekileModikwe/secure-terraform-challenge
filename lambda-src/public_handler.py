import json
import os
import urllib.error
import urllib.request


def lambda_handler(event, context):
    """Relay only the expected request body to the private API tier."""
    request_body = event.get("body") or "{}"
    private_api_url = os.environ["PRIVATE_API_URL"]

    # Keep the broker Lambda intentionally thin. The public tier should validate
    # envelope-level shape, then hand off sensitive work to the isolated tier.
    request = urllib.request.Request(
        private_api_url,
        data=request_body.encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            payload = json.loads(response.read().decode("utf-8"))
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps(
                    {
                        "message": "Request processed successfully.",
                        "request_id": getattr(context, "aws_request_id", "unknown"),
                        "result": payload,
                    }
                ),
            }
    except urllib.error.HTTPError as error:
        return {
            "statusCode": error.code,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Private API returned an error.", "details": error.reason}),
        }
    except Exception as error:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Unexpected error in broker Lambda.", "details": str(error)}),
        }
