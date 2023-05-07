import boto3
import json

dynamodb = boto3.resource('dynamodb')

TABLE = dynamodb.Table('Reservations')

def add_res(reservation_id, customer_name, room_number, nights):
    try:
        TABLE.put_item(
            Item={
                'ReservationId': reservation_id,
                'CustomerName': customer_name,
                'RoomNumber': room_number,
                'Nights': nights,
            }
        )
    except:
        return 'An error occurred adding the reservation.'
        
    return 'Reservation added successfully.'

def lambda_handler(event, context):
    json_data = json.loads(event['body'])
    reservation_id = json_data['reservation_id']
    customer_name = json_data['customer_name']
    room_number = json_data['room_number']
    nights = json_data['nights']

    response = add_res(reservation_id,customer_name,room_number,nights)
    
    return {
        'statusCode': 200,
        'body': response
    }
    