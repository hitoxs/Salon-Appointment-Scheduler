#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Display the list of services
echo "Services offered:"
$PSQL -c "SELECT service_id, name FROM services" |
  awk '{print NR")",$0}'

while true; do
  echo ""
  read -p "What service would you like today? Enter the service ID: " SERVICE_ID_SELECTED

  # Check if the service ID exists
  service_exists=$($PSQL -tAc "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ $service_exists -eq 1 ]]; then
    break
  else
    echo ""
    echo "I could not find that service. What would you like today?"
  fi
done

echo ""
read -p "What's your phone number? " CUSTOMER_PHONE

# Check if the customer exists
customer_exists=$($PSQL -tAc "SELECT COUNT(*) FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ $customer_exists -eq 0 ]]; then
  read -p "I don't have a record for that phone number, what's your name? " CUSTOMER_NAME

  $PSQL -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
fi

echo ""
read -p "What time would you like your service? " SERVICE_TIME

# Get service name
SERVICE_NAME=$($PSQL -tAc "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Get customer name
CUSTOMER_NAME=$($PSQL -tAc "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Insert appointment into the database
$PSQL -c "INSERT INTO appointments (customer_id, service_id, time) SELECT customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME' FROM customers WHERE phone = '$CUSTOMER_PHONE';"

echo ""
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
