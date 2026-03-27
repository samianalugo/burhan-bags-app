import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://172.20.10.10:8000/api/";

void main() {
  runApp(const MyApp());
}

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

// ================= MAIN APP =================
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

  final List<Widget> pages = [
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
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Products"),
              selected: selectedIndex == 0,
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text("Profit"),
              selected: selectedIndex == 1,
              onTap: () {
                setState(() => selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Manage Products"),
              selected: selectedIndex == 2,
              onTap: () {
                setState(() => selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: pages[selectedIndex],
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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final res = await http
          .get(Uri.parse("${baseUrl}products/"))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        setState(() => products = jsonDecode(res.body));
      } else {
        showAppMessage(context, 'Fetch failed: ${res.statusCode}');
      }
    } catch (e) {
      showAppMessage(context, 'Server error. Check backend.');
    }
  }

  Future<void> addProduct(Map data) async {
    try {
      final res = await http.post(
        Uri.parse("${baseUrl}products/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode == 201) {
        showAppMessage(context, 'Product added');
        fetchProducts();
      } else {
        showAppMessage(context, 'Add failed');
      }
    } catch (e) {
      showAppMessage(context, 'Error adding product');
    }
  }

  Future<void> sellProduct(int id, int qty) async {
    try {
      final res = await http.post(
        Uri.parse("${baseUrl}sales/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"product": id, "quantity": qty}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        showAppMessage(context, 'Sale recorded');
        fetchProducts();
      } else {
        showAppMessage(context, 'Sell failed');
      }
    } catch (e) {
      showAppMessage(context, 'Sell error');
    }
  }

  void showSellDialog(int id) {
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(controller.text) ?? 0;
              if (qty > 0) {
                sellProduct(id, qty);
                Navigator.pop(context);
              }
            },
            child: const Text("Sell"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPage()),
          );
          if (result != null) addProduct(result);
        },
        child: const Icon(Icons.add),
      ),
      body: products.isEmpty
          ? const Center(child: Text("No products yet.\nTap + to add.", textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                var p = products[i];
                return Card(
                  child: ListTile(
                    title: Text(p['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Stock: ${p['stock']}"),
                        Text("Cost: ${p['cost_price']}"),
                        Text("Sell: ${p['sell_price']}"),
                      ],
                    ),
                    onTap: () => showSellDialog(p['id']),
                  ),
                );
              },
            ),
    );
  }
}

// ================= ADD PRODUCT =================
class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final name = TextEditingController();
  final stock = TextEditingController();
  final cost = TextEditingController();
  final price = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            field(name, "Name"),
            field(stock, "Stock", true),
            field(cost, "Cost Price", true),
            field(price, "Selling Price", true),
            const SizedBox(height: 20),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget field(TextEditingController c, String label, [bool num = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
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
  double totalProfit = 0;

  @override
  void initState() {
    super.initState();
    fetchProfit();
  }

  Future<void> fetchProfit() async {
    try {
      final res = await http.get(Uri.parse("${baseUrl}profit/"));
      if (res.statusCode == 200) {
        setState(() => totalProfit = (jsonDecode(res.body)['total_profit'] ?? 0) * 1.0);
      }
    } catch (e) {
      showAppMessage(context, "Error loading profit");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchProfit,
      child: ListView(
        children: [
          const SizedBox(height: 200),
          Center(
            child: Text(
              "Total Profit: \$${totalProfit.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
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
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final res = await http.get(Uri.parse("${baseUrl}products/"));
      if (res.statusCode == 200) {
        setState(() => products = jsonDecode(res.body));
      }
    } catch (e) {
      showAppMessage(context, "Error loading products");
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final res = await http.delete(Uri.parse("${baseUrl}products/$id/"));
      if (res.statusCode == 204) {
        showAppMessage(context, "Deleted");
        fetchProducts();
      }
    } catch (e) {
      showAppMessage(context, "Delete failed");
    }
  }

  Future<void> updateProduct(int id, Map data) async {
    try {
      final res = await http.put(
        Uri.parse("${baseUrl}products/$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        showAppMessage(context, "Updated");
        fetchProducts();
      }
    } catch (e) {
      showAppMessage(context, "Update failed");
    }
  }

  void showEditDialog(Map p) {
    final name = TextEditingController(text: p['name']);
    final stock = TextEditingController(text: p['stock'].toString());
    final cost = TextEditingController(text: p['cost_price'].toString());
    final price = TextEditingController(text: p['sell_price'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            field(name, "Name"),
            field(stock, "Stock", true),
            field(cost, "Cost Price", true),
            field(price, "Selling Price", true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              updateProduct(p['id'], {
                "name": name.text,
                "stock": int.tryParse(stock.text) ?? 0,
                "cost_price": double.tryParse(cost.text) ?? 0,
                "sell_price": double.tryParse(price.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget field(TextEditingController c, String label, [bool num = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        decoration: const InputDecoration(border: OutlineInputBorder())
            .copyWith(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? const Center(child: Text("No products available"))
        : ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) {
              var p = products[i];
              return Card(
                child: ListTile(
                  title: Text(p['name']),
                  subtitle: Text("Stock: ${p['stock']}"),
                  leading: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showEditDialog(p),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteProduct(p['id']),
                  ),
                ),
              );
            },
          );
  }
}