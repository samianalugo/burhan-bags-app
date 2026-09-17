# 👜 Burhan Bags Stock Management App

A Flutter inventory and sales app for small businesses such as bag shops. It helps you manage products, track stock, record sales, and monitor profit.

---

## Features

### Authentication

- Register with email and password
- Log in to access the app

### Product Management

- Add new products
- View product list and stock
- Delete products
- Store name, stock quantity, cost price, and selling price

### Sales and Profit

- Sell products from the app
- Stock reduces automatically after a sale
- Profit is calculated per sale
- Dashboard analytics and total profit tracking

### User Interface

- Drawer navigation with:
  - Dashboard
  - Products
  - Profit
  - Manage

---

## Tech Stack

- **Flutter** and **Dart** (mobile/web UI)
- **Django REST Framework** (backend API)
- **HTTP** for API calls
- **Material Design**

Live API: `https://burhan-bags-app.onrender.com/api/`

---

## Project Structure

```
lib/
 ├── main.dart
 ├── auth_pages.dart
 ├── pages/
 │    ├── login_page.dart
 │    ├── register_page.dart
 │    ├── home_page.dart
 │    ├── dashboard_page.dart
 │    ├── product_page.dart
 │    ├── add_page.dart
 │    ├── profit_page.dart
 │    └── manage_page.dart
 ├── services/
 │    └── auth_service.dart
 └── utils/
      └── app_utils.dart

backend/
 ├── manage.py
 └── api/          # products, sales, profits, login, register
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/samianalugo/burhan-bags-app
cd burhan-bags-app
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### Backend (optional, local)

```bash
cd backend
pip install -r requirements.txt
python manage.py runserver
```

---

## CI/CD

GitHub Actions runs on pushes to `main`:

- Code analysis
- Tests
- Release APK build

Workflow file: `.github/workflows/flutter.yml`

---

## Build APK

```bash
flutter build apk --release
```

---

## Future Improvements

- Profit history dashboard
- Charts (daily / weekly / monthly)
- Sales receipts
- Cloud backup

---

## Contributing

1. Fork the repo
2. Create a new branch
3. Make your changes
4. Submit a pull request

---

## License

This project is open source and available under the **MIT License**.

---

## Author

Developed by **Nalugo Samia**
