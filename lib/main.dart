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

// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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