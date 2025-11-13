# 📱 Skill Link

### *Marketplace Mobile App for Unregulated Occupations*

Skill Link is a cross-platform mobile application designed to connect individuals who need task-based services with local skilled workers operating in unregulated sectors. Built using **Flutter** and powered by **Supabase**, the app provides a digital marketplace where users can post tasks, place bids, communicate in real time, make secure payments, and exchange feedback — bringing structure and transparency to India’s informal gig economy.

---

## 🚀 Features

### 🧑‍💼 User Module

* Single user role for both posters and taskers
* Manage profile, bio, and location
* Secure authentication via Supabase Auth

### 📝 Task Management

* Create, edit, and manage tasks
* Add budgets, descriptions, and optional images
* Real-time task feed for browsing listings

### 💸 Bidding System

* Taskers can place competitive bids
* Posters can review and select winning bids
* Automatic task assignment workflow

### 💬 Chat & Realtime Messaging

* Dedicated chat room per task
* Supabase Realtime supports instant updates
* Attachment uploads (images/files)

### 🏦 Escrow-Style Payments (Yet to implement)

* Secure transaction flow using serverless logic
* Funds held until task completion
* Payment release triggered after verification

### ⭐ Rating & Review (Yet to implement)

* Posters provide feedback after task completion
* Improves reliability and user reputation

---

## 🛠️ Tech Stack

**Frontend:**

* Flutter (Dart)
* Riverpod (State Management)

**Backend:**

* Supabase (PostgreSQL, Auth, Realtime, Storage)
* Supabase Edge Functions (escrow/payment logic)

---

## 🔧 Installation & Setup Instructions

### 1️⃣ **Clone the Repository**

```bash
git clone https://github.com/alanbjoseph/Skill-Link.git
cd Skill-Link
```

### 2️⃣ **Install Flutter Dependencies**

```bash
flutter pub get
```

### 3️⃣ **Add Environment Variables**

Create a `.env` file or use `flutter_dotenv` depending on your setup. Add:

```
SUPABASE_URL=your-supabase-project-url
SUPABASE_ANON_KEY=your-anon-key
```

### 4️⃣ **Run the App**

```bash
flutter run
```

Make sure a device or emulator is connected.

---

## 📦 Releases

The latest official builds (APK / IPA / Release Bundles) are available in the repository's **Releases** section:

👉 [Releases](https://github.com/alanbjoseph/Skill-Link/releases)

---

## 🏗️ System Architecture (Brief)

Skill Link follows a **client–server architecture**:

* **Flutter client** handles UI, forms, navigation, chat, and bidding logic.
* **Supabase backend** manages authentication, database operations, file storage, and real-time events.
* **Edge Functions** handle secure payment workflows and escrow logic.

This structure ensures scalability, low latency, and modular expansion as the app grows.

---

## 🔮 Future Enhancements

* Machine-learning-powered price regulation for unregulated tasks
* Full-featured web version
* Separate user roles with government ID verification
* Expanded payment options (Cards, Wallets, Net Banking)
* Improved recommendation algorithms
* Admin dashboards for analytics and dispute resolution

---

## 🧑‍🤝‍🧑 Contributing

Contributions are welcome once the repository is opened for collaboration.
Please create an issue or pull request with clear descriptions of proposed changes.

---

## 📩 Contact

For queries, suggestions, or collaboration opportunities:

📧 **[alanbj4258@gmail.com](mailto:alanbj4258@gmail.com)**
🔗 GitHub: [https://github.com/alanbjoseph](https://github.com/alanbjoseph)

---