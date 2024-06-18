import json
import datetime

def lambda_handler(event, context):
    currentTime = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S.%fZ")
    response = {
        "currentTime": currentTime
    }
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
