import boto3

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
        return 'An error occurred.'
        
    return 'Reservation added successfully.'

def lambda_handler(event, context):
    reservation_id = event['reservation_id']
    customer_name = event['customer_name']
    room_number = event['room_number']
    nights = event['nights']

    response = add_res(reservation_id,customer_name,room_number,nights)
    
    return {
        'statusCode': 200,
        'body': response
    }
    