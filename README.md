<div align="center">

  # 🏢 Enterprise Smart Apartment & Complex Management System
  ### Privacy-First, Role-Based Community Platform Powered by Flutter & Firebase

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean-blueviolet?style=for-the-badge)](#-technical-architecture)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](YOUR_LINKEDIN_URL_HERE)
  [![Demo](https://img.shields.io/badge/Google%20Drive-APK%20%26%20Demo-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/file/d/1qazrkkPzZanzRvirfsafmo1PBJneNte9/view)

</div>

---

## ⚡ Executive Summary / Proje Özeti

**Smart Apartment Management System**, geleneksel apartman ve site yönetim süreçlerini dijitalleştiren, **ölçeklenebilir, rol tabanlı ve KVKK/GDPR uyumlu (Gizlilik Odaklı)** mobil platformdur. 

WhatsApp gruplarında yaşanan numara/kimlik ifşası, karmaşık aidat takipleri ve kaybolan duyuru sorunlarına uçtan uca modern bir mimari çözümdür.

---

## 🆚 Why Move Away From WhatsApp Groups?

| Özellik | WhatsApp Grupları ❌ | Smart Apartment System 🚀 |
| :--- | :--- | :--- |
| **Kişisel Veri Gizliliği** | Herkes başkasının telefon numarasını görür | **Sadece Daire No görünür (Tam Gizlilik)** |
| **Ödeme Takipleri** | Dekontlar grupta kaybolur / Manuel takip | **Sisteme yüklenir, Yöneticiden onay bekler** |
| **Karar Alma / Oylama** | Mesaj kirliliği, sayım zorluğu | **Canlı Anket (Poll) modülü ile anlık sonuç** |
| **Şikayet Yönetimi** | Kaotik tartışmalar | **Bireysel bilet (Ticket) formatında çözümlenir** |
| **Erişim Kontrolü** | Eski kiracılar grupta kalabilir | **Rol bazlı erişim denetimi (RBAC)** |

---

## 🛠 Tech Stack & Libraries

* **Framework:** Flutter (Dart 3.x)
* **Backend Platform:** Firebase (BaaS)
  * **Authentication:** Firebase Auth (Email/Password & Role-Based Auth)
  * **Database:** Cloud Firestore (NoSQL, Real-Time Sync)
  * **Storage:** Firebase Storage (Dekont ve medya belgeleri)
* **Architecture:** Feature-First Clean Architecture + Layered Data Segregation
* **State Management:** Provider / Riverpod / Bloc
* **Push Notifications:** Firebase Cloud Messaging (FCM) & `flutter_local_notifications`

---

## 🏗 Technical Architecture

Uygulama, esneklik ve sürdürülebilirlik açısından endüstri standardı olan **Feature-First Clean Architecture** prensiplerine göre yapılandırılmıştır.

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
