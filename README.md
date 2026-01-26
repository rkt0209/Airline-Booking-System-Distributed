# ✈️ Airline Booking Microservices Platform

**A distributed, event-driven backend system for flight management, booking orchestration, and automated notifications.**

Built with **Node.js**, **Express**, **MySQL**, **RabbitMQ**, and deployed on **AWS** using a custom API Gateway and Auto Scaling Groups.

---

## 🔗 Microservice Repositories
This project is composed of 5 independent microservices. Click below to view the source code for each:

| Service | Responsibility | Repository Link |
| :--- | :--- | :--- |
| **API Gateway** | Central entry point, Routing, Rate Limiting, Auth Proxy | [Link to API Gateway](https://github.com/rkt0209/ApiGateway) |
| **Auth Service** | JWT issuance, Validation, User Management | [Link to Auth Service](https://github.com/rkt0209/Auth_Service) |
| **Flight Service** | Flight Catalog, City/Airport Management, Search Filters | [Link to Flight Service](https://github.com/rkt0209/flightsandSearch) |
| **Booking Service** | Booking Orchestration, Transaction Management, Message Publishing | [Link to Booking Service](https://github.com/rkt0209/bookingService) |
| **Reminder Service** | Cron Jobs, Email Notifications, RabbitMQ Consumer | [Link to Reminder Service](https://github.com/rkt0209/reminderService) |

---
## 📖 Project Overview

This is a comprehensive **Airline Booking System** built using a **Microservices Architecture**. It simulates a real-world production environment where different functionalities (Authentication, Booking, Flight Search, Notifications) are decoupled into independent services.

The system handles the complete flow of a flight reservation—from searching for flights and managing seat inventory to processing secure bookings and sending asynchronous email notifications.

---

## ✨ Key Features

### 👤 **For the User (Functional Features)**
* **Smart Flight Search:** Users can filter flights based on Source, Destination, and Price range.
* **Real-Time Seat Availability:** The system prevents overbooking by atomically updating seat inventory during the transaction.
* **Secure Authentication:** User accounts are protected using **JWT (JSON Web Tokens)** and secure password hashing.
* **Instant Notifications:** Users receive immediate booking confirmations via email.
* **Automated Reminders:** A background cron job automatically schedules and sends flight reminder emails 24 hours before departure.

### ⚙️ **For the Developer (Technical Features)**
* **Centralized API Gateway:** A single entry point that manages request routing, rate limiting, and request logging.
* **Event-Driven Architecture:** Uses **RabbitMQ** to decouple the booking process from email notifications, ensuring low latency.
* **Resilient Scheduling:** A custom Reminder Service handles scheduling tasks reliably, even if the mail server is temporarily down.
* **Scalable Infrastructure:** Designed to be deployed on **AWS** with Auto Scaling Groups and Load Balancers to handle traffic spikes.

---
## 🏗️ Architecture & Technologies

The system follows a **Hub-and-Spoke** architecture where the **API Gateway** acts as the single entry point. Services communicate synchronously via **REST (HTTP)** for data retrieval and asynchronously via **RabbitMQ** for heavy background tasks (email notifications).

## 🛠️ Tech Stack & Architecture

This project is built using a robust, production-ready technology stack designed for scalability and maintainability.

### **Core Backend**
* **Runtime:**  Node.js
* **Framework:** Express.js
* **Architecture:** Microservices (4 Independent Services + API Gateway)

### **Database & Storage**
* **Database:**  MySQL (Relational DB)
* **ORM:** Sequelize (for schema modeling, migrations, and seeders)
* **Cloud Storage:** AWS RDS (Managed Relational Database Service)

### **Messaging & Asynchronous Tasks**
* **Message Broker:**  RabbitMQ (utilizing `amqplib`)
* **Task Scheduling:** Node-Cron (for automated email reminders)
* **Email Service:** Nodemailer

### **Cloud Infrastructure (AWS)**
* **Compute:** AWS EC2 (Elastic Compute Cloud)
* **Scaling:** AWS Auto Scaling Groups (Dynamic scaling based on load)
* **Networking:** Application Load Balancer (ALB) for traffic distribution
* **Gateway:** Custom API Gateway for centralized routing

### **DevOps & Tooling**
* **Logging:** Morgan (HTTP request logger)
* **Error Handling:** Centralized Error Handling classes
* **Security:** JSON Web Tokens (JWT), bcrypt

---

### 📂 Project Structure & Patterns
The codebase follows the **Repository-Service-Controller** design pattern to ensure separation of concerns and clean, testable code.

* **`/config`** - Environment-specific configurations and DB connections.
* **`/controllers`** - Handles incoming HTTP requests and responses.
* **`/services`** - Contains core business logic.
* **`/repository`** - Direct database interactions (Data Access Layer).
* **`/models`** - Sequelize schema definitions.
* **`/migrations`** - Database schema version control.
* **`/seeders`** - Scripts to populate initial data.
* **`/middlewares`** - Request validation, Auth checks, and error handling.
* **`/routes`** - API route definitions.
* **`/utils`** - Helper functions and error classes.

### **Key Workflows**
1.  **User Search:** `Client` → `Gateway` → `Flight Service` (MySQL)
2.  **Booking:** `Client` → `Gateway` → `Booking Service` → `Flight Service` (Check Seats) → `MySQL` (Save)
3.  **Notification:** `Booking Service` → `RabbitMQ` → `Reminder Service` → `Nodemailer` (Email)

---

## 🚀 How to Run Locally

### **Prerequisites**
* Node.js (v18+)
* MySQL Server (Running locally or via Docker)
* RabbitMQ Server (Running locally or via Docker)

### **Step 1: Clone Repositories**
Clone all 5 repositories into a single folder.

### **Step 2: Database Setup**
Create the databases in your local MySQL instance:
```sql
CREATE DATABASE auth_db;
CREATE DATABASE booking_db;
CREATE DATABASE flights_search_db;
```
### Step 3: Configure Database (config.json)
For each of the services that use a database (Auth, Booking, Flight, Reminder), you must create a configuration file to tell Sequelize how to connect to your local DB.

- Navigate to src/config inside the service folder.
- Create a file named config.json.
- Paste the following code (update password with your local MySQL password):
```
{
  "development": {
    "username": "root",
    "password": "YOUR_LOCAL_MYSQL_PASSWORD",
    "database": "auth_db",
    "host": "127.0.0.1",
    "dialect": "mysql"
  }
}
```
* Important: You must change the "database" key for each service:
* Auth Service: "database": "auth_db"
* Booking & Reminder Service: "database": "booking_db"
* Flight Service: "database": "flights_search_db"
### Step 4: Configure Environment Variables (.env)
Create a .env file in the root of each service folder with the following details:
# 1. API Gateway
```
PORT=3005
AUTH_SERVICE=http://localhost:7000
BOOKING_SERVICE=http://localhost:5000
FLIGHT_SERVICE=http://localhost:3000
```

# 2. Auth Service
```
PORT=7000
SALT=YourRandomSaltString
JWT_KEY=YourSecretKey
DB_SYNC=true
```
# 3. Flight Search Service
```
PORT=3000
DB_SYNC=true
```
# 4. Booking Service
```
PORT=5000
DB_SYNC=true
FLIGHT_SERVICE_PATH=http://localhost:3000/flightservice
USER_SERVICE_PATH=http://localhost:7000/authservice
MESSAGE_BROKER_URL=amqp://localhost
EXCHANGE_NAME=AIRLINE_BOOKING
REMINDER_BINDING_KEY=REMINDER_SERVICE
```
# 5. Reminder Service
```
PORT=3004
# Use your actual email credentials to test sending emails
EMAIL_ID=your-email@gmail.com
EMAIL_PASS=your-app-password
MESSAGE_BROKER_URL=amqp://localhost
EXCHANGE_NAME=AIRLINE_BOOKING
REMINDER_BINDING_KEY=REMINDER_SERVICE
### Step 4: Install & Run
Open a separate terminal for each service and run:
```
# Inside each service folder:
Open 5 separate terminals (one for each service) and run the following commands in order:
```
npm install
npx sequelize db:migrate
npm start
```
### Order of Startup:
- RabbitMQ & MySQL
- Auth Service
- Flight Service
- Reminder Service
- Booking Service
- API Gateway
Access the system at http://localhost:3005 (Gateway Port).

## ☁️ How to Deploy on AWS

This project supports a fully automated deployment using EC2 Launch Templates.

### Deployment Overview
* **Hardware:** t2.micro / t2.medium EC2 instances.
* **OS:** Ubuntu 24.04 LTS.
* **Database:** AWS RDS (MySQL).
* **Scaling:** AWS Auto Scaling Group (ASG) behind an Application Load Balancer (ALB).

### Step-by-Step Guide
* **RDS Setup:** Create a MySQL instance on AWS RDS.
* **Launch Template:** Create an EC2 Launch Template using the User Data Script provided in this repo (`aws/launch-script.sh`).
    * > **Note:** Update the `DB_HOST` variable in the script with your RDS Endpoint.
* **Auto Scaling:** Create an Auto Scaling Group using the template.
* **Load Balancer:** Attach an Application Load Balancer (Internet Facing) listening on **Port 80**.
* **Target Group:** Point the Load Balancer to **Port 3005** (The API Gateway).

### Accessing the Deployed App
Once deployed, the API is accessible via the Load Balancer DNS:

```http
GET http://<LOAD_BALANCER_DNS>/home
POST http://<LOAD_BALANCER_DNS>/flightservice/api/v1/flights
```
