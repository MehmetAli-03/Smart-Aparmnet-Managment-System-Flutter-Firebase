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

  ### 🎬 [>> CANLI DEMO VİDEOSUNU İZLE & APK İNDİR (GOOGLE DRIVE) <<](https://drive.google.com/file/d/1qazrkkPzZanzRvirfsafmo1PBJneNte9/view)

</div>

---

## 📱 Live Demo & Video Showcase (Öne Çıkanlar)

Uygulamanın çalışan test sürümlerini (APK), ekran kayıtlarını ve canlı test videolarını aşağıdaki bağlantı üzerinden inceleyebilirsiniz:

> 🚀 **Google Drive Medya Klasörü:** [Smart Management App - Demo & APK](https://drive.google.com/file/d/1qazrkkPzZanzRvirfsafmo1PBJneNte9/view)
> 
> * **Test APK:** Fiziksel Android cihazınıza yükleyip test edebilirsiniz.
> * **Video Walkthrough:** Admin ve Sakin (Resident) panellerinin canlı kullanım senaryoları.

---

## ⚡ Executive Summary / Proje Özeti

**Smart Apartment Management System**, geleneksel apartman ve site yönetim süreçlerindeki verimsizliği ortadan kaldıran, **ölçeklenebilir, rol tabanlı (RBAC) ve KVKK/GDPR uyumlu (Gizlilik Odaklı)** bir mobil ekosistemdir.

Klasik iletişim kanallarında (WhatsApp vb.) yaşanan **kişisel veri ihlalleri, kaybolan ödeme dekontları, takibi imkansız şikayetler ve şeffaf olmayan karar alma süreçleri** bu uygulama ile tek bir merkezi platformda çözüme kavuşturulur.

---

## 🔍 Deep Dive: Module & Feature Capabilities (Detaylı Özellik Modülleri)

### 🔐 1. Zero-Trust Privacy & Auth System (Gizlilik & Doğrulama Modülü)
* **Telefon Numarası Gizleme:** WhatsApp gruplarının aksine, bina sakinlerinin kişisel telefon numaraları ve soyadları diğer kullanıcılar tarafından **asla görülemez**.
* **Daire Bazlı Kimliklendirme:** Kullanıcılar sistemde sadece `Daire No` (Örn: *Daire 14 - Sakin*) olarak temsil edilir.
* **Rol Tabanlı Giriş (RBAC):** Firebase Auth altyapısı ile `Admin` (Yönetici) ve `Resident` (Bina Sakini) hesapları giriş anında yetkilendirilir ve ilgili arayüze yönlendirilir.

### 💳 2. Financial Engine & Receipt Approval (Finans & Dekont Modülü)
* **Bina IBAN ve Aidat Takipleri:** Sakinler, yönetimin belirlediği güncel aidat miktarını ve bina banka IBAN bilgilerini canlı olarak görüntüler.
* **Dekont Yükleme (Receipt Upload):** Sakinler yaptıkları ödemelerin dekont/fatura görsellerini doğrudan uygulama üzerinden Firebase Storage'a yükler.
* **Yönetici Onay Mekanizması:** Yöneticinin paneline düşen dekontlar incelenir; "Onaylandı" veya "Reddedildi" olarak işaretlenir. Tüm finansal geçmiş kayıt altında tutulur.

### 🎫 3. Ticket-Based Complaint & Maintenance System (Şikayet & Arıza Takipleri)
* **Bireysel Bilet Açma:** Sakinler bina ile ilgili arıza, gürültü veya temizlik problemlerini resim ve açıklama ekleyerek bilet (ticket) olarak yönetime iletir.
* **Durum Takibi (Real-time Status):** Biletlerin durumu (`Beklemede` $\rightarrow$ `İşlemde` $\rightarrow$ `Çözüldü`) sakin tarafından canlı takip edilir.
* **Gürültüsüz Çözüm:** Şikayetler genel gruplarda tartışmaya yol açmadan doğrudan yönetim ile sakin arasında çözülür.

### 🗳️ 4. Real-Time Polls & Decision Engine (Canlı Anket & Oylama)
* **Demokratik Karar Alma:** Yönetici, binayı ilgilendiren kararlar için (Örn: *Dış cephe boyası seçimi*, *Güvenlik kamerası takılması*) anketler oluşturur.
* **Tek Daire - Tek Oy İlkesi:** Veritabanı kuralları ile her dairenin sadece 1 oy kullanması garanti altına alınır.
* **Anlık Grafik & Sonuçlar:** Kullanılan oylar anlık grafiklerle tüm sakinlere şeffafça gösterilir.

### 📢 5. Push-Notified Announcement Board (Duyuru Pano Modülü)
* **Öncelikli Duyurular:** Yönetici tarafından yayınlanan acil durum veya genel bilgilendirmeler (Su kesintisi, toplantı tarihi vb.) anında panoya düşer.
* **Yerel Bildirim Entegrasyonu:** `flutter_local_notifications` ve Firebase Messaging ile duyurular sakinin telefonuna bildirim olarak iletilir.

---

## 🆚 Comparison Matrix: WhatsApp vs. Smart Apartment System

| Özellik / Senaryo | WhatsApp Grupları ❌ | Smart Apartment System 🚀 |
| :--- | :--- | :--- |
| **KVKK / GDPR Uyumluğu** | İhlal var (Numaralar herkese açık) | **Tam Uyumlu (Sadece Daire No görünür)** |
| **Aidat Dekont Takipleri** | Mesajlar arasında kaybolur | **Sisteme yüklenir, Yöneticiden onay bekler** |
| **Karar Alma / Oylama** | Kaotik mesajlaşma, manuel sayım | **Canlı Anket (Poll) modülü ile anlık sonuç** |
| **Arıza & Şikayet Yönetimi** | Mahalle baskısı, uzayıp giden tartışmalar | **Bireysel Bilet (Ticket) sistemiyle gizli takip** |
| **Eski Kiracı / Sakin Takipleri** | Grupta unutulur, bilgi sızabilir | **Yönetici tarafından anında erişim engeli** |

---

## 🏗 Technical Architecture & Clean Code

Proje, bakımı kolay, test edilebilir ve yüksek ölçeklenebilir **Feature-First Clean Architecture** standartlarında geliştirilmiştir.

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
