import os, requests, json

# set constants
URL_STEM = "http://a8597e5ddf35d4b2e87d568baabb8cc6-1491154.us-east-1.elb.amazonaws.com"
API_KEY = ''
CUSTOMER = 'Star'
HEADERS = {
    'x-api-key': API_KEY,
    'customer': CUSTOMER
}

def pause():
    # screen pause
    input('\nPress Enter to continue...')

def add_res(reservation_id,customer_name,room_number,nights):
    # create new reservation
    payload = {
        "reservation_id": reservation_id, 
        "customer_name": customer_name,
        "room_number": room_number,
        "nights": nights
    }
    url = URL_STEM + '/add-res'
    response = requests.post(url, json=payload, headers=HEADERS)
    return response

def get_res(print_table=True):
    # get all reservations
    url = URL_STEM + '/get-res'
    response = requests.get(url, headers=HEADERS)
    response_dict = json.loads(response.text)
    if print_table:
        print(response_dict['pretty_table'])
    return response_dict['raw_scan']

def delete_res(reservation_id):
    # delete a reservation
    url = URL_STEM + '/delete-res'
    payload = {"reservation_id": reservation_id}
    response = requests.post(url, json=payload, headers=HEADERS)
    return response

is_running = True

while is_running:
    
    os.system('clear')
    
    print(f'Welcome to the {CUSTOMER} Hotel Reservation System')
    print('\n1. Add Reservation')
    print('2. Delete a Reservation')
    print('3. List all Reservations')
    print('4. Exit')

    selection = int(input('\nPlease make a selection: '))

    os.system('clear')

    if selection == 1:
        
        # get table scan
        response = get_res(print_table=False)
        
        # generate next reservation id
        id_list = [int(x['ReservationId']) for x in response['Items']]
        if len(id_list) > 0:
            reservation_id = int(sorted(id_list)[-1])+1
        else:
            reservation_id = 1

        # collect inputs for new reservation
        print('Please enter the required fields.')
        customer_name = input('\nCustomer Name: ')
        room_number = int(input('Room Number: '))
        nights = int(input('Number of Nights: '))
        
        # add reservation
        response = add_res(reservation_id,customer_name,room_number,nights)
        print('\n'+response.text)
        pause()

    elif selection == 2:
        
        # print list of existing reservations
        get_res()

        # get reservation id to delete
        delete_selection = int(input('\nPlease enter reservation id to delete: '))
        
        # delete reservation
        response = delete_res(delete_selection)
        print('\n'+response.text)
        pause()

    elif selection == 3:
        # list all reservations
        get_res()
        pause()
    elif selection == 4:
        # exit
        is_running = False