import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BurhanBagsApp());
}

class BurhanBagsApp extends StatelessWidget {
  const BurhanBagsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burhan Bags',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue,
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> products = [];
  Map<String, double> dailyProfits = {};
  double todayProfit = 0;

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadProfits();
    loadExpenses();
  }

  Map<String, double> dailyExpenses = {};
  double todayExpenses = 0;

  // ================= STORAGE =================

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('products', jsonEncode(products));
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('products');

    if (data != null) {
      products = List<Map<String, dynamic>>.from(jsonDecode(data));
      setState(() {});
    }
  }

  Future<void> saveProfits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profits', jsonEncode(dailyProfits));
  }

  Future<void> loadProfits() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('profits');

    if (data != null) {
      dailyProfits = Map<String, double>.from(
        jsonDecode(data).map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
    }

    todayProfit = dailyProfits[getTodayDate()] ?? 0;
    setState(() {});
  }
 
  Future<void> saveExpenses() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('expenses', jsonEncode(dailyExpenses));
}

Future<void> loadExpenses() async {
  final prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString('expenses');

  if (data != null) {
    dailyExpenses = Map<String, double>.from(
      jsonDecode(data).map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  todayExpenses = dailyExpenses[getTodayDate()] ?? 0;
  setState(() {});
}
  // ================= CRUD =================

  void addProduct(Map<String, dynamic> product) {
    products.add(product);
    saveProducts();
    setState(() {});
  }

  void editProduct(int index, Map<String, dynamic> updated) {
    products[index] = updated;
    saveProducts();
    setState(() {});
  }

  void deleteProduct(int index) {
    products.removeAt(index);
    saveProducts();
    setState(() {});
  }

  // ================= SELL =================

  void sellProduct(int index, int qty) {
    var product = products[index];

    if (product['stock'] >= qty) {
      double cost = product['costPrice'];
      double sell = product['sellPrice'];

      double profit = (sell - cost) * qty;

      product['stock'] -= qty;

      String today = getTodayDate();
      dailyProfits[today] = (dailyProfits[today] ?? 0) + profit;
      todayProfit = dailyProfits[today]!;

      saveProducts();
      saveProfits();

      setState(() {});
    }
  }

  void showSellDialog(int index) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Sell ${products[index]['name']}"),
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

              if (qty <= 0) return;

              if (qty > products[index]['stock']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Not enough stock")),
                );
                return;
              }

              sellProduct(index, qty);
              Navigator.pop(context);
            },
            child: const Text("Sell"),
          )
        ],
      ),
    );
  }

  void addExpense(double amount) {
    String today = getTodayDate();

    dailyExpenses[today] = (dailyExpenses[today] ?? 0) + amount;
    todayExpenses = dailyExpenses[today]!;

    saveExpenses();
    setState(() {});
  }

  Map<String, double> getWeeklyProfits() {
  Map<String, double> weekly = {};
  DateTime now = DateTime.now();

  for (int i = 0; i < 7; i++) {
    DateTime day = now.subtract(Duration(days: i));
    String key = "${day.year}-${day.month}-${day.day}";
    weekly[key] = dailyProfits[key] ?? 0;
  }

  return weekly;
}

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Burhan Bags"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "UGX ${todayProfit.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
  // added the expense function 
  
      // ===== Drawer =====
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.store, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text("Burhan Bags",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Product"),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductPage()),
                );
                if (result != null) addProduct(result);
              },
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Product"),
              onTap: () {
                Navigator.pop(context);
                selectProductAction(isEdit: true);
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete Product"),
              onTap: () {
                Navigator.pop(context);
                selectProductAction(isEdit: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Weekly Report"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyReportPage(
                      weeklyData: getWeeklyProfits(),
                    ),
                  ),
                );
              },
              ),

              ListTile(
                leading: const Icon(Icons.money_off),
                title: const Text("Daily Expenses"),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpensesPage(),
                    ),
               );
        },
      ),
          ],
        ),
      ),

      // ===== Body =====
      body: Column(
        children: [
          // Profit Card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Profit",
                    style: TextStyle(color: Colors.white)),
                Text(
                  "UGX ${todayProfit.toStringAsFixed(0)}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Expanded(
            child: products.isEmpty
                ? const Center(child: Text("No products added"))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      var p = products[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(p['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text("Stock: ${p['stock']}"),
                                Text("Buy: UGX ${p['costPrice']}"),
                                Text("Sell: UGX ${p['sellPrice']}"),
                              ],
                            ),
                            trailing: const Icon(Icons.sell,
                                color: Colors.green),
                            onTap: () => showSellDialog(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
          if (result != null) addProduct(result);
        },
      ),
    );
  }

  void selectProductAction({required bool isEdit}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Product" : "Delete Product"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(products[index]['name']),
                onTap: () async {
                  Navigator.pop(context);

                  if (isEdit) {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddProductPage(product: products[index]),
                      ),
                    );

                    if (updated != null) editProduct(index, updated);
                  } else {
                    deleteProduct(index);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ================= ADD PAGE =================

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final name = TextEditingController();
  final stock = TextEditingController();
  final cost = TextEditingController();
  final price = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      name.text = widget.product!['name'];
      stock.text = widget.product!['stock'].toString();
      cost.text = widget.product!['costPrice'].toString();
      price.text = widget.product!['sellPrice'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.product == null ? "Add Product" : "Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField(name, "Product Name"),
            const SizedBox(height: 10),
            buildField(stock, "Stock", isNumber: true),
            const SizedBox(height: 10),
            buildField(cost, "Cost Price", isNumber: true),
            const SizedBox(height: 10),
            buildField(price, "Selling Price", isNumber: true),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    "name": name.text,
                    "stock": int.tryParse(stock.text) ?? 0,
                    "costPrice": double.tryParse(cost.text) ?? 0,
                    "sellPrice": double.tryParse(price.text) ?? 0,
                  });
                },
                child: Text(widget.product == null ? "Add Product" : "Update"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

//expense page
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  Map<String, double> expenses = {};
  double todayTotal = 0;

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('expenses');

    if (data != null) {
      expenses = Map<String, double>.from(
        jsonDecode(data).map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
    }

    todayTotal = expenses[getTodayDate()] ?? 0;
    setState(() {});
  }

  Future<void> saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', jsonEncode(expenses));
  }

  void addExpense(double amount) {
    String today = getTodayDate();

    expenses[today] = (expenses[today] ?? 0) + amount;
    todayTotal = expenses[today]!;

    saveExpenses();
    setState(() {});
  }

  void showAddDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Expense"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              double amount =
                  double.tryParse(controller.text) ?? 0;

              if (amount <= 0) return;

              addExpense(amount);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Expenses")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Today's Expenses"),
                trailing: Text(
                  "UGX ${todayTotal.toStringAsFixed(0)}",
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: expenses.entries.map((entry) {
                  return Card(
                    child: ListTile(
                      title: Text(entry.key),
                      trailing: Text(
                        "UGX ${entry.value.toStringAsFixed(0)}",
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WeeklyReportPage extends StatelessWidget {
  final Map<String, double> weeklyData;

  const WeeklyReportPage({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Report")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: weeklyData.entries.map((entry) {
          return Card(
            child: ListTile(
              title: Text(entry.key),
              trailing: Text(
                "UGX ${entry.value.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}