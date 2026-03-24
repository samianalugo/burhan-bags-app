# 👜 Burhan Bags Stock Management App

A simple and powerful **Flutter-based inventory and sales management app** designed for small businesses like bag shops.

This app helps you manage products, track stock, record sales, and monitor daily profits — all in one place.

---

## 🚀 Features

### 📦 Product Management

* Add new products
* Edit existing products
* Delete products
* Store product details:

  * Name
  * Stock quantity
  * Cost price
  * Selling price

### 💰 Sales & Profit Tracking

* Sell products directly from the app
* Automatic stock reduction after sale
* Profit calculated per sale
* Daily profit tracking
* Profit data saved permanently (even after app restart)

### 📊 User Interface

* Clean and simple UI
* Sidebar navigation (Drawer)
* Quick access to:

  * Home
  * Add Product
  * Edit Product
  * Delete Product

### 💾 Data Persistence

* Uses `SharedPreferences`
* Saves:

  * Product list
  * Daily profits

---

## 🛠️ Tech Stack

* **Flutter** (UI Framework)
* **Dart**
* **SharedPreferences** (Local storage)
* **Material Design**

---

## 📂 Project Structure

```
lib/
 └── main.dart   # Main application file
```

---

## ⚙️ Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/samianalugo/burhan-bags-app
cd burhan-bags-app
```

---

### 2. Install dependencies

```bash
flutter pub get
```

---

### 3. Run the app

```bash
flutter run
```

---

## 🧪 CI/CD

This project uses **GitHub Actions** for Continuous Integration:

* Code analysis
* Test execution
* APK build

Workflow file:

```
.github/workflows/flutter.yml
```

---

## 📦 Build APK

To generate a release APK manually:

```bash
flutter build apk --release
```

---

## 🔮 Future Improvements

* 📊 Profit history dashboard
* 📈 Charts (daily/weekly/monthly)
* 🧾 Sales receipts
* 🔐 User authentication
* ☁️ Cloud backup (Firebase)

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repo
2. Create a new branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

This project is open source and available under the **MIT License**.

---

## 👨‍💻 Author

Developed by **Nalugo Samia**

---

## ⭐ Support

If you like this project, please ⭐ the repo on GitHub!
