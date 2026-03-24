import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(BurhanBagsApp());
}

class BurhanBagsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burhan Bags',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
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
  }

  // ================= SAVE/LOAD =================

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
      dailyProfits =
          Map<String, double>.from(jsonDecode(data).map((k, v) =>
              MapEntry(k, (v as num).toDouble())));
    }

    todayProfit = dailyProfits[getTodayDate()] ?? 0;
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
      double cost = product['costPrice'] ?? 0;
      double sell = product['sellPrice'] ?? 0;

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
        title: Text("Sell ${products[index]['name']}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Quantity"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(controller.text) ?? 0;

              if (qty <= 0) return;

              if (qty > products[index]['stock']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Not enough stock")),
                );
                return;
              }

              sellProduct(index, qty);
              Navigator.pop(context);
            },
            child: Text("Sell"),
          )
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Burhan Bags"),
            Text("Profit: UGX ${todayProfit.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 14)),
          ],
        ),
      ),

      // ================= SIDEBAR =================

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Burhan Bags",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add Product"),
              onTap: () async {
                Navigator.pop(context);

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddProductPage()),
                );

                if (result != null) addProduct(result);
              },
            ),

            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Product"),
              onTap: () {
                Navigator.pop(context);
                selectProductAction(isEdit: true);
              },
            ),

            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Delete Product"),
              onTap: () {
                Navigator.pop(context);
                selectProductAction(isEdit: false);
              },
            ),
          ],
        ),
      ),

      // ================= PRODUCT LIST =================

      body: products.isEmpty
          ? Center(child: Text("No products added"))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                var p = products[index];

                return Card(
                  child: ListTile(
                    title: Text(p['name']),
                    subtitle: Text(
                      "Stock: ${p['stock']} | Buy: ${p['costPrice']} | Sell: ${p['sellPrice']}",
                    ),
                    trailing: Icon(Icons.sell),
                    onTap: () => showSellDialog(index),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductPage()),
          );

          if (result != null) addProduct(result);
        },
      ),
    );
  }

  // ================= SELECT PRODUCT =================

  void selectProductAction({required bool isEdit}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Select Product to Edit" : "Select Product to Delete"),
        content: Container(
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

// ================= ADD / EDIT PAGE =================

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  AddProductPage({this.product});

  @override
  _AddProductPageState createState() => _AddProductPageState();
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
          AppBar(title: Text(widget.product == null ? "Add" : "Edit Product")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: stock, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Stock")),
            TextField(controller: cost, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Cost Price")),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Selling Price")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "name": name.text,
                  "stock": int.tryParse(stock.text) ?? 0,
                  "costPrice": double.tryParse(cost.text) ?? 0,
                  "sellPrice": double.tryParse(price.text) ?? 0,
                });
              },
              child: Text(widget.product == null ? "Add" : "Update"),
            )
          ],
        ),
      ),
    );
  }
}