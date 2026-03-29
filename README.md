# ✈️ Airline Booking Platform — Full Stack (Microservices + Android)

**A distributed, event-driven backend system for flight management, booking orchestration, and automated notifications — paired with a premium Jetpack Compose Android client.**

Built with **Node.js**, **Express**, **MySQL**, **RabbitMQ**, and **Kotlin (Jetpack Compose)**.
Deployed on **AWS** using a custom API Gateway and Auto Scaling Groups.

---

## 📱 Android App

### Download & Try (Static UI Preview APK)
> This APK demonstrates the full UI/UX with static mock data. No backend required.

**[⬇️ Download APK (Google Drive)](https://drive.google.com/file/d/1mizDEc4hqTUytJFRnaJZeA0Q22mcGWJ1/view?usp=drivesdk)**

### Android Source Code
**[📦 Android App Repository — GitHub](https://github.com/rkt0209/airlineManagmentAPP)**

### Install the APK on Your Android Device
1. Open the Google Drive link above on your Android phone and tap **Download**
2. Once downloaded, tap the `.apk` file in your notifications or file manager
3. If prompted, go to `Settings → Security → Install unknown apps` and enable it for your browser/file manager
4. Tap **Install** and open the app
5. > **Note:** This APK uses static mock data. To use live booking with the real backend, build from source (see [Run the Android App](#-run-the-android-app-from-source) below)

---

## 🔗 Microservice Repositories

| Service | Responsibility | Repository |
| :--- | :--- | :--- |
| **API Gateway** | Central entry point, Routing, Rate Limiting, Auth Proxy | [Link](https://github.com/rkt0209/ApiGateway) |
| **Auth Service** | JWT issuance, Validation, User Management | [Link](https://github.com/rkt0209/Auth_Service) |
| **Flight Service** | Flight Catalog, City/Airport Management, Search Filters | [Link](https://github.com/rkt0209/flightsandSearch) |
| **Booking Service** | Booking Orchestration, Transaction Management, Message Publishing | [Link](https://github.com/rkt0209/bookingService) |
| **Reminder Service** | Cron Jobs, Email Notifications, RabbitMQ Consumer | [Link](https://github.com/rkt0209/reminderService) |

---

## 📖 Project Overview

This is a comprehensive **Airline Booking System** built using a **Microservices Architecture**. It simulates a real-world production environment where different functionalities (Authentication, Booking, Flight Search, Notifications) are decoupled into independent services.

The system handles the complete flow of a flight reservation — from searching for flights and managing seat inventory, to processing secure bookings and sending asynchronous email notifications — all accessible through a polished Android mobile client.

---

## ✨ Key Features

### 📱 **Android App Features**
- **JWT Authentication** — Login & signup with role selection (Passenger / Admin); session persisted in SharedPreferences
- **Live Flight Search** — Real airport dropdowns from API; filtered by departure airport, arrival airport, and travel date (timezone-aware)
- **Premium Flight Cards** — Airline branding, flight duration, seat availability indicator, price per seat
- **Booking Flow** — Seat selector, real-time booking creation, success/error dialogs; triggers confirmation email via RabbitMQ
- **My Bookings** — Boarding-pass style cards split into **Upcoming** and **Previous** tabs, sorted by departure time
- **User Profile** — Displays real JWT-decoded email and role
- **Admin Panel** — Full flight and airport CRUD management
- **Custom UI** — Wave-shaped curved bottom nav with raised FAB; all times shown in device local timezone

### 👤 **Backend Features (User-Facing)**
- **Smart Flight Search** — Filter by source, destination, and price range
- **Real-Time Seat Availability** — Atomic seat inventory update prevents overbooking
- **Secure Authentication** — JWT + bcrypt password hashing
- **Instant Booking Confirmation** — Email sent immediately after booking
- **Automated Reminders** — Cron job sends flight reminder emails 24 hours before departure

### ⚙️ **Backend Features (Technical)**
- **Centralized API Gateway** — Single entry point for routing, rate limiting, and logging
- **Event-Driven Architecture** — RabbitMQ decouples booking from notifications for low latency
- **Resilient Scheduling** — Reminder Service handles scheduling even if mail server is temporarily down
- **Scalable Infrastructure** — AWS Auto Scaling Groups + Load Balancers for traffic spikes

---

## 🏗️ System Architecture

```
Android App (Jetpack Compose)
        │
        ▼
  API Gateway :3005
  ┌─────────────────────────────────┐
  │  Auth Service       :7000       │
  │  Flight Service     :3000       │
  │  Booking Service    :5000  ──── RabbitMQ ──── Reminder Service :3004
  └─────────────────────────────────┘                    │
        │                                           Nodemailer (Email)
     MySQL / AWS RDS
```

**Key Workflows:**
1. **Search:** `App` → `Gateway` → `Flight Service` (MySQL)
2. **Booking:** `App` → `Gateway` → `Booking Service` → `Flight Service` (seat check) → `MySQL` (save)
3. **Notification:** `Booking Service` → `RabbitMQ` → `Reminder Service` → `Nodemailer`

---

## 🛠️ Full Tech Stack

### Android App
| Layer | Technology |
| :--- | :--- |
| Language | Kotlin |
| UI | Jetpack Compose (Material 3) |
| Navigation | Compose Navigation (`androidx.navigation`) |
| Dependency Injection | Dagger Hilt (`@HiltViewModel`, `@Singleton`) |
| Networking | Retrofit 2 + OkHttp (with `AuthInterceptor` for JWT) |
| Serialization | Gson (`@SerializedName`) |
| State Management | Kotlin `StateFlow` / `MutableStateFlow` |
| Auth | JWT decoded from SharedPreferences |
| Date/Time | `java.time` (API 26+): `Instant`, `ZoneId`, `LocalDate` |
| Min SDK | API 26 (Android 8.0) |

### Backend
| Layer | Technology |
| :--- | :--- |
| Runtime | Node.js |
| Framework | Express.js |
| Database | MySQL + Sequelize ORM |
| Cloud DB | AWS RDS |
| Message Broker | RabbitMQ (`amqplib`) |
| Task Scheduling | node-cron |
| Email | Nodemailer |
| Auth | JWT + bcrypt |
| Logging | Morgan |
| Cloud Infra | AWS EC2, Auto Scaling Groups, ALB |

---

## 🚀 How to Run the Full Stack Locally

### Prerequisites
- Node.js (v18+)
- MySQL Server running locally
- RabbitMQ running locally (`amqp://localhost`)
- Android Studio Hedgehog or newer (for the app)
- JDK 17+, Android SDK API 26+

---

### Step 1 — Clone All Repositories

Clone the backend monorepo and the Android app:
```bash
# Backend (this repo — contains all 5 services as subfolders)
git clone https://github.com/rkt0209/AirLineBookingProject
cd AirLineBookingProject

# Android App
git clone https://github.com/rkt0209/airlineManagmentAPP
```

---

### Step 2 — Database Setup

Create the three databases in your local MySQL:
```sql
CREATE DATABASE auth_db;
CREATE DATABASE booking_db;
CREATE DATABASE flights_search_db;
```

---

### Step 3 — Configure Each Service

#### 3a. Database Config (`src/config/config.json`)
Create `config.json` inside each service's `src/config/` folder:

```json
{
  "development": {
    "username": "root",
    "password": "YOUR_MYSQL_PASSWORD",
    "database": "SERVICE_DB_NAME",
    "host": "127.0.0.1",
    "dialect": "mysql"
  }
}
```

| Service | `"database"` value |
| :--- | :--- |
| Auth Service | `"auth_db"` |
| Booking Service | `"booking_db"` |
| Reminder Service | `"booking_db"` |
| Flight Service | `"flights_search_db"` |

#### 3b. Environment Variables (`.env`)

Create a `.env` file in the root of each service folder:

**API Gateway**
```env
PORT=3005
AUTH_SERVICE=http://localhost:7000
BOOKING_SERVICE=http://localhost:5000
FLIGHT_SERVICE=http://localhost:3000
```

**Auth Service**
```env
PORT=7000
SALT=YourRandomSaltString
JWT_KEY=YourSecretKey
DB_SYNC=true
```

**Flight Search Service**
```env
PORT=3000
DB_SYNC=true
```

**Booking Service**
```env
PORT=5000
DB_SYNC=false
FLIGHT_SERVICE_PATH=http://localhost:3000/flightservice
USER_SERVICE_PATH=http://localhost:7000/authservice
MESSAGE_BROKER_URL=amqp://localhost
EXCHANGE_NAME=AIRLINE_BOOKING
REMINDER_BINDING_KEY=REMINDER_SERVICE
```

**Reminder Service**
```env
PORT=3004
EMAIL_ID=your-email@gmail.com
EMAIL_PASS=your-gmail-app-password
MESSAGE_BROKER_URL=amqp://localhost
EXCHANGE_NAME=AIRLINE_BOOKING
REMINDER_BINDING_KEY=REMINDER_SERVICE
```

> For `EMAIL_PASS`: use a **Gmail App Password** (not your account password). Generate one at `Google Account → Security → 2-Step Verification → App Passwords`.

---

### Step 4 — Install, Migrate & Start Each Service

Open **5 separate terminals** and run in this order:

```bash
# 1. Auth Service
cd AUTH_SERVICE && npm install && npx sequelize db:migrate && npm start

# 2. Flight Service
cd FlightAndSearchService && npm install && npx sequelize db:migrate && npm start

# 3. Reminder Service
cd ReminderService && npm install && npx sequelize db:migrate && npm start

# 4. Booking Service
cd BookingService && npm install && npx sequelize db:migrate && npm start

# 5. API Gateway (last — depends on all other services)
cd API_GATEWAY && npm install && npm start
```

> **Startup order matters:** RabbitMQ and MySQL must be running before any service. API Gateway must start last.

The backend is now live at: `http://localhost:3005`

---

## 📱 Run the Android App from Source

### Step 1 — Open in Android Studio
- Launch Android Studio
- `File → Open` → select the `airlineManagmentAPP/` folder
- Wait for Gradle sync to complete

### Step 2 — Configure the Backend URL

The app defaults to `http://10.0.2.2:3005` — the Android emulator's loopback address for your host machine.

| Scenario | What to do |
| :--- | :--- |
| Running on **emulator** | No change needed — `10.0.2.2` works out of the box |
| Running on a **physical device** | Open `app/src/main/java/com/example/airline/core/network/NetworkModule.kt` and replace `10.0.2.2` with your machine's local IP (e.g., `192.168.1.5`) |

> Your phone and computer must be on the **same Wi-Fi network**.

### Step 3 — Build & Run
- Select an emulator or connected device (API 26+)
- Click **Run ▶** or press `Shift + F10`
- The app will launch and connect to your running backend

---

## 📲 Install the Live-Connected APK (Build from Source)

If you want to share the app with someone who already has the backend running:

1. In Android Studio: `Build → Build Bundle(s) / APK(s) → Build APK(s)`
2. APK is generated at:
   ```
   airlineManagmentAPP/app/build/outputs/apk/debug/app-debug.apk
   ```
3. Transfer the APK to the target Android device (USB, Google Drive, etc.)
4. On the device: `Settings → Security → Install unknown apps` → enable for your file manager
5. Tap the APK file and install
6. Ensure the device is on the same network as the backend, or point to a deployed backend URL

---

## ☁️ How to Deploy on AWS

### Deployment Overview
- **Hardware:** t2.micro / t2.medium EC2 instances
- **OS:** Ubuntu 24.04 LTS
- **Database:** AWS RDS (MySQL)
- **Scaling:** AWS Auto Scaling Group (ASG) behind an Application Load Balancer (ALB)

### Step-by-Step Guide
1. **RDS Setup:** Create a MySQL instance on AWS RDS
2. **Launch Template:** Create an EC2 Launch Template using the User Data Script in `aws/launch-script.sh`
   > Update the `DB_HOST` variable in the script with your RDS Endpoint
3. **Auto Scaling:** Create an Auto Scaling Group using the template
4. **Load Balancer:** Attach an Application Load Balancer (Internet Facing) listening on **Port 80**
5. **Target Group:** Point the Load Balancer to **Port 3005** (the API Gateway)
6. **Android App (Cloud):** Update `NetworkModule.kt` with the Load Balancer DNS and rebuild the APK

### Accessing the Deployed API
```
GET  http://<LOAD_BALANCER_DNS>/home
POST http://<LOAD_BALANCER_DNS>/flightservice/api/v1/flights
```

---

## 📂 Backend Project Structure

```
/config       — Environment configs and DB connections
/controllers  — HTTP request/response handlers
/services     — Core business logic
/repository   — Data Access Layer (DB queries)
/models       — Sequelize schema definitions
/migrations   — Database schema version control
/seeders      — Initial data population scripts
/middlewares  — Auth checks, validation, error handling
/routes       — API route definitions
/utils        — Helper functions and error classes
```

---

## 📄 License

This project is for educational and portfolio purposes.
