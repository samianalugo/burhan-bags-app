import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "https://burhan-bags-app.onrender.com/api/";

void main() {
  runApp(const MyApp());
}

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}


class AuthService {
  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// ================= LOGIN =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("${baseUrl}login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.text, "password": password.text}),
      );
      if (!mounted) return;
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        showAppMessage(context, body['error'] ?? "Login failed");
      }
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, "Network error");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= REGISTER =================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final telNumber = TextEditingController();
  bool isLoading = false;

  Future<void> register() async {
    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("${baseUrl}register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text,
          "password": password.text,
          "first_name": firstName.text,
          "last_name": lastName.text,
          "tel_number": telNumber.text,
        }),
      );
      if (!mounted) return;
      final body = jsonDecode(res.body);
      if (res.statusCode == 201) {
        showAppMessage(context, "Account created! Please login.");
        Navigator.pop(context);
      } else {
        showAppMessage(context, body['error'] ?? "Registration failed");
      }
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, "Network error. Please try again.");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: firstName,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastName,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telNumber,
              decoration: const InputDecoration(labelText: "Telephone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}

// ================= HOME =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final pages = [
    const DashboardPage(),
    const ProductPage(),
    const ProfitPage(),
    const ManagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Burhan Bags")),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white)),
            ),

            drawerItem("Dashboard", Icons.dashboard, 0),
            drawerItem("Products", Icons.inventory, 1),
            drawerItem("Profit", Icons.attach_money, 2),
            drawerItem("Manage", Icons.settings, 3),
          ],
        ),
      ),

      body: pages[selectedIndex],
    );
  }

  Widget drawerItem(String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedIndex == index,
      onTap: () {
        setState(() => selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

// ================= PRODUCTS =================
class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);

    try {
      final res = await http.get(Uri.parse("${baseUrl}products/"));

      if (res.statusCode == 200) {
        products = jsonDecode(res.body);
      }
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, "Server error");
    }

    setState(() => isLoading = false);
  }

  Future<void> addProduct(Map data) async {
    final res = await http.post(
      Uri.parse("${baseUrl}products/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (!mounted) return;
    if (res.statusCode == 201) {
      showAppMessage(context, "Added");
      fetchProducts();
    }
  }

  Future<void> sellProduct(int id, int qty) async {
    final res = await http.post(
      Uri.parse("${baseUrl}sales/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"product": id, "quantity": qty}),
    );

    if (!mounted) return;
    if (res.statusCode == 201 || res.statusCode == 200) {
      showAppMessage(context, "Sale recorded");
      fetchProducts();
    }
  }

  void showSellDialog(Map p) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sell Product"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Quantity"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(controller.text) ?? 0;

              if (qty <= 0) {
                showAppMessage(context, "Enter valid quantity");
                return;
              }

              if (qty > p['stock']) {
                showAppMessage(context, "Not enough stock");
                return;
              }

              sellProduct(p['id'], qty);
              Navigator.pop(context);
            },
            child: const Text("Sell"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text("No products"));
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final data = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPage()),
          );
          if (data != null) addProduct(data);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          var p = products[i];

          return Card(
            child: ListTile(
              title: Text(p['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stock: ${p['stock']}",
                    style: TextStyle(
                      color: p['stock'] < 5 ? Colors.red : Colors.black,
                      fontWeight: p['stock'] < 5
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text("Cost: ${p['cost_price']}"),
                  Text("Sell: ${p['sell_price']}"),
                ],
              ),
              onTap: () => showSellDialog(p),
            ),
          );
        },
      ),
    );
  }
}

// ================= DASHBOARD =================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map data = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetch();
  }


  Future<void> fetch() async {
    setState(() { isLoading = true; error = null; });
    try {
      final res = await http.get(Uri.parse("${baseUrl}analytics/"));
      if (res.statusCode == 200) {
        setState(() => data = jsonDecode(res.body));
      } else {
        setState(() => error = "Server error ${res.statusCode}");
      }
    } catch (e) {
      setState(() => error = "Network error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));
    if (data.isEmpty) return const Center(child: Text("No data"));

    return RefreshIndicator(
      onRefresh: fetch,
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          card("Profit", data['total_profit']),
          card("Products", data['total_products']),
          card("Sales", data['total_sales']),
          card("Low Stock", data['low_stock']),
        ],
      ),
    );
  }

  Widget card(String title, dynamic value) {
    return Card(
      child: Center(
        child: Text("$title\n$value",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ================= ADD =================
class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final stock = TextEditingController();
    final cost = TextEditingController();
    final price = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            field(name, "Name"),
            field(stock, "Stock", true),
            field(cost, "Cost", true),
            field(price, "Sell", true),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "name": name.text,
                  "stock": int.tryParse(stock.text) ?? 0,
                  "cost_price": double.tryParse(cost.text) ?? 0,
                  "sell_price": double.tryParse(price.text) ?? 0,
                });
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }

  Widget field(TextEditingController c, String label, [bool num = false]) {
    return TextField(
      controller: c,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    );
  }
}

// ================= PROFIT =================
class ProfitPage extends StatefulWidget {
  const ProfitPage({super.key});

  @override
  State<ProfitPage> createState() => _ProfitPageState();
}

class _ProfitPageState extends State<ProfitPage> {
  double profit = 0;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final res = await http.get(Uri.parse("${baseUrl}profit/"));
    if (res.statusCode == 200) {
      setState(() => profit = jsonDecode(res.body)['total_profit'] * 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Profit: \$${profit.toStringAsFixed(2)}"),
    );
  }
}

// ================= MANAGE =================
class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  List products = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final res = await http.get(Uri.parse("${baseUrl}products/"));
    if (res.statusCode == 200) {
      setState(() => products = jsonDecode(res.body));
    }
  }

  Future<void> delete(int id) async {
    await http.delete(Uri.parse("${baseUrl}products/$id/"));
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, i) {
        var p = products[i];
        return ListTile(
          title: Text(p['name']),
          subtitle: Text("Stock: ${p['stock']}"),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => delete(p['id']),
          ),
        );
      },
    );
  }
}