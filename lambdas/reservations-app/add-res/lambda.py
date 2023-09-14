import boto3
import json

DYNAMODB = boto3.resource('dynamodb')

def add_res(reservation_id, customer_name, room_number, nights, table):
    try:
        table.put_item(
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
    # load reservation data
    json_data = json.loads(event['body'])
    reservation_id = json_data['reservation_id']
    customer_name = json_data['customer_name']
    room_number = json_data['room_number']
    nights = json_data['nights']

    # load table name
    table_name = f"{event['headers']['customer'].lower()}-reservations"
    table = DYNAMODB.Table(table_name)

    response = add_res(reservation_id, customer_name, room_number, nights, table)
    
    return {
        'statusCode': 200,
        'body': response
    }
    