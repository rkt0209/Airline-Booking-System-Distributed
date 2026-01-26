#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# --- 1. CONFIGURATION ---
# [SECURITY WARNING] Replace these placeholders with your actual AWS RDS details before running
DB_HOST="<YOUR_RDS_ENDPOINT>"  # e.g., airline-db.xxx.eu-north-1.rds.amazonaws.com
DB_USER="<YOUR_DB_USERNAME>"   # e.g., admin
DB_PASS="<YOUR_DB_PASSWORD>"
# ---------------------

# 2. System Updates & Install Tools
cd /home/ubuntu
sudo apt update -y
# --- TIMEZONE FIX (Set to India Standard Time) ---
sudo timedatectl set-timezone Asia/Kolkata
# -------------------------------------------------
sudo apt install nodejs npm -y
sudo apt install mysql-client-core-8.0 -y
sudo apt install rabbitmq-server -y
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

# 3. Setup Databases
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS auth_db;"
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS booking_db;"
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS flights_search_db;"

# Helper Function for Config
create_config_json() {
    local DB_NAME=$1
    local TARGET_DIR=$2
    mkdir -p $TARGET_DIR/src/config
    cat <<EOF > $TARGET_DIR/src/config/config.json
{
  "development": {
    "username": "$DB_USER",
    "password": "$DB_PASS",
    "database": "$DB_NAME",
    "host": "$DB_HOST",
    "dialect": "mysql",
    "timezone": "+05:30" 
  }
}
EOF
}

# --- DEPLOY SERVICES ---

# A. API GATEWAY
cd /home/ubuntu
git clone https://github.com/rkt0209/ApiGateway.git
cd ApiGateway
npm install
sudo npm install -g pm2
sudo pm2 start index.js --name "ApiGateway"

# B. AUTH SERVICE
cd /home/ubuntu
git clone https://github.com/rkt0209/Auth_Service.git
cd Auth_Service
npm install
# Secrets injected via environment variables
cat <<EOF > .env
PORT=7000
SALT=<YOUR_SALT_KEY>
JWT_KEY=<YOUR_JWT_SECRET>
DB_SYNC=true
EOF
create_config_json "auth_db" "/home/ubuntu/Auth_Service"
npx sequelize db:migrate --config src/config/config.json --migrations-path src/migrations
sudo pm2 start index.js --name "AuthService"

# C. FLIGHT SEARCH SERVICE
cd /home/ubuntu
git clone https://github.com/rkt0209/flightsandSearch.git
cd flightsandSearch
npm install
cat <<EOF > .env
PORT=3000
DB_SYNC=true
EOF
create_config_json "flights_search_db" "/home/ubuntu/flightsandSearch"
npx sequelize db:migrate --config src/config/config.json --migrations-path src/migrations
sudo pm2 start src/index.js --name "FlightService"

# D. BOOKING SERVICE
cd /home/ubuntu
git clone https://github.com/rkt0209/bookingService.git
cd bookingService
npm install
cat <<EOF > .env
PORT=5000
DB_SYNC=true
FLIGHT_SERVICE_PATH=http://localhost:3000/flightservice
USER_SERVICE_PATH=http://localhost:7000/authservice
EXCHANGE_NAME=AIRLINE_BOOKING
REMINDER_BINDING_KEY=REMINDER_SERVICE
MESSAGE_BROKER_URL=amqp://localhost
EOF
create_config_json "booking_db" "/home/ubuntu/bookingService"
npx sequelize db:migrate --config src/config/config.json --migrations-path src/migrations
sudo pm2 start src/index.js --name "BookingService"

# E. REMINDER SERVICE
cd /home/ubuntu
git clone https://github.com/rkt0209/reminderService.git
cd reminderService
npm install
# Email credentials hidden for security
cat <<EOF > .env
PORT=3004
EMAIL_ID=<YOUR_EMAIL_ADDRESS>
EMAIL_PASS=<YOUR_APP_PASSWORD>
EXCHANGE_NAME=AIRLINE_BOOKING
REMINDER_BINDING_KEY=REMINDER_SERVICE
MESSAGE_BROKER_URL=amqp://localhost
EOF
create_config_json "booking_db" "/home/ubuntu/reminderService"
npx sequelize db:migrate --config src/config/config.json --migrations-path src/migrations
sudo pm2 start src/index.js --name "ReminderService"

# 4. Final Startup
sudo pm2 save
sudo pm2 startup
