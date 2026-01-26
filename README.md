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

## 🏗️ Architecture & Technologies

The system follows a **Hub-and-Spoke** architecture where the **API Gateway** acts as the single entry point. Services communicate synchronously via **REST (HTTP)** for data retrieval and asynchronously via **RabbitMQ** for heavy background tasks (email notifications).

### **Tech Stack**
* **Backend:** Node.js, Express
* **Database:** MySQL (Sequelize ORM) with Migrations
* **Messaging:** RabbitMQ (Message Queues & Exchanges)
* **Auth:** JSON Web Tokens (JWT), bcrypt
* **Cloud (AWS):** EC2, RDS, Application Load Balancer (ALB), Auto Scaling Groups (ASG)

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
