import boto3
import json

DYNAMODB = boto3.resource('dynamodb')

def delete_res(reservation_id, table):
    try:
        table.delete_item(
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
    # load reservation data
    json_data = json.loads(event['body'])
    reservation_id = json_data['reservation_id']

    # load table name
    table_name = f"{event['headers']['customer'].lower()}-reservations"
    table = DYNAMODB.Table(table_name)

    response = delete_res(reservation_id, table)
    
    return {
        'statusCode': 200,
        'body': response
    }
