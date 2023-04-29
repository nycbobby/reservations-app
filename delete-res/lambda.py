import boto3
import json

dynamodb = boto3.resource('dynamodb')

TABLE = dynamodb.Table('Reservations')

def delete_res(reservation_id):
    try:
        TABLE.delete_item(
            Key={
                'ReservationId': reservation_id
            }
        )
        message = 'Reservation deleted successfully.'
    except:
        message = 'An error occurred while deleting reservation.' 
    finally:
        print(message)
        return message

def lambda_handler(event, context):
    json_data = json.loads(event['body'])
    reservation_id = json_data['reservation_id']

    response = delete_res(reservation_id)
    
    return {
        'statusCode': 200,
        'body': response
    }
