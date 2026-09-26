<div align="center">

  # 🏢 Enterprise Smart Apartment & Complex Management System
  ### Privacy-First, Role-Based Community Platform Powered by Flutter & Firebase

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean-blueviolet?style=for-the-badge)](#-technical-architecture)
  [![Demo](https://img.shields.io/badge/Google%20Drive-APK%20%26%20Live%20Demo-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/file/d/1qazrkkPzZanzRvirfsafmo1PBJneNte9/view)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](YOUR_LINKEDIN_URL_HERE)

  <br />

  ### 🎬 [>> WATCH LIVE DEMO & DOWNLOAD APK (GOOGLE DRIVE) <<](https://drive.google.com/file/d/1qazrkkPzZanzRvirfsafmo1PBJneNte9/view)

</div>

---

## 📱 Live Demo & Video Showcase (Highlights)

You can review the working test builds (APK), screen recordings, and live demo videos via the link below:

> 🚀 **Google Drive Media Folder:** [Smart Management App - Demo & APK](https://drive.google.com/file/d/1qazrkkPzZanzRvirfsafmo1PBJneNte9/view)
> 
> * **Test APK:** Install and test directly on your physical Android device.
> * **Video Walkthrough:** Live usage scenarios of both Admin and Resident panels.

---

## ⚡ Executive Summary

**Smart Apartment Management System** is a mobile ecosystem designed to eliminate inefficiencies in traditional apartment and complex management processes. It is **scalable, role-based (RBAC), and compliance-ready (Privacy-First / KVKK & GDPR compliant)**.

Issues commonly faced in traditional communication channels (e.g., WhatsApp groups)—such as **data privacy violations, lost payment receipts, untrackable complaints, and non-transparent decision-making processes**—are resolved within a single, centralized platform.

---

## 🔍 Deep Dive: Module & Feature Capabilities

### 🔐 1. Zero-Trust Privacy & Auth System
* **Phone Number Obfuscation:** Unlike WhatsApp groups, residents' personal phone numbers and last names are **never visible** to other users.
* **Apartment-Based Identification:** Users are represented in the system strictly by their `Apartment No` (e.g., *Apt 14 - Resident*).
* **Role-Based Access Control (RBAC):** Powered by Firebase Auth, `Admin` and `Resident` accounts are authorized upon login and routed to their respective dashboards.

### 💳 2. Financial Engine & Receipt Approval
* **Building IBAN & Dues Tracking:** Residents can view up-to-date monthly dues and the building's official bank IBAN in real time.
* **Receipt Upload:** Residents upload proof-of-payment documents or bank receipts directly to Firebase Storage via the app.
* **Admin Approval Workflow:** Uploaded receipts land on the admin dashboard for review and can be marked as "Approved" or "Rejected", keeping a complete audit trail.

### 🎫 3. Ticket-Based Complaint & Maintenance System
* **Individual Ticket Logging:** Residents submit maintenance issues, noise complaints, or cleaning requests directly to management as tickets with descriptions and photos.
* **Real-Time Status Tracking:** Ticket lifecycles (`Pending` $\rightarrow$ `In Progress` $\rightarrow$ `Resolved`) are tracked live by the resident.
* **Private Resolution:** Issues are resolved privately between management and the resident, avoiding toxic group chat arguments.

### 🗳️ 4. Real-Time Polls & Decision Engine
* **Democratic Decision Making:** Admins create interactive polls for building decisions (e.g., *exterior painting color*, *security camera installation*).
* **One Apartment, One Vote:** Database security rules enforce that each apartment can cast only one vote.
* **Live Analytics & Results:** Voting tallies are updated dynamically and presented transparently to all residents.

### 📢 5. Push-Notified Announcement Board
* **Priority Notices:** Critical updates published by management (water outages, annual meetings, etc.) appear instantly on the notice board.
* **Push Notification Integration:** Built with `flutter_local_notifications` and Firebase Messaging to deliver urgent announcements straight to residents' phones.

---

## 🆚 Comparison Matrix: WhatsApp vs. Smart Apartment System

| Feature / Scenario | WhatsApp Groups ❌ | Smart Apartment System 🚀 |
| :--- | :--- | :--- |
| **Privacy & Compliance** | Violations common (Phone numbers public) | **Full Compliance (Only Apartment No visible)** |
| **Payment & Receipt Tracking** | Lost in chat history | **Uploaded to system, awaiting admin approval** |
| **Decision Making / Polling** | Chaotic messaging, manual counting | **Live Polling module with real-time results** |
| **Incident & Maintenance Handling** | Public arguments, peer pressure | **Private Ticket system with status tracking** |
| **Tenant Offboarding** | Forgotten in group chats, data leak risk | **Instant access revocation by Admin** |

---

## 🏗 Technical Architecture & Clean Code

The project is developed following the industry-standard **Feature-First Clean Architecture** for maximum maintainability, testability, and scalability.

```text
lib/
├── main.dart                             # Application Entrypoint & Global Providers
├── core/                                 # Shared Infrastructure Across Features
│   ├── constants/                        # App Colors, Typography, Constants
│   ├── services/                         # Global Services (Local Notifications, Network)
│   └── widgets/                          # Reusable UI Elements (Buttons, Inputs, Navs)
│
└── features/                             # Business Logic Modules
    ├── auth/                             # Authentication & Account Provisioning
    │   ├── data/                         # Auth Services & User DTO Models
    │   └── presentation/                 # Login, Register & Join Apartment Views
    │
    ├── announcement/                     # Notice Board System
    │   ├── data/                         # Firestore Announcement Repositories
    │   └── presentation/                 # Announcement Feed & Manager Panel
    │
    ├── complaint/                        # Incident & Maintenance Tracking
    │   ├── data/                         # Complaint Models & Ticket Handlers
    │   └── presentation/                 # Ticket Creation & Resolution Portal
    │
    ├── payment/                          # Financial Engine & Bank Receipts
    │   ├── data/                         # Financial Logs & Storage Services
    │   └── presentation/                 # IBAN Display, Receipt Upload & Approval List
    │
    ├── poll/                             # Decision Making & Surveys
    │   ├── data/                         # Voting Models & Real-time Listeners
    │   └── presentation/                 # Interactive Survey Interface
    │
    └── home/                             # Role-Based Dashboard Hub
        └── presentation/pages/
            ├── admin/                    # Management Control Center
            └── resident/                 # Resident Dashboard
