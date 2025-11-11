import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FlutterFirebaseShopApp());
}

class FlutterFirebaseShopApp extends StatelessWidget {
  const FlutterFirebaseShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFirebaseShop',
      debugShowCheckedModeBanner: false,
      home: AuthChecker(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/menu': (context) => const MainMenu(),
        '/add': (context) => const AddProduct(),
        '/list': (context) => const ProductList(),
        '/cart': (context) => const CartList(),
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?> (
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authState) {
        // Loading Screen While Waiting For Connection
        if (authState.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged In User Detected
        if (authState.hasData) {
          return const MainMenu();
        }

        // No Logged In User
        return const LoginPage();
      },
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> tryLogin() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/menu');
    } on FirebaseAuthException catch (e) {
      String err = e.message ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.redAccent, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.6,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Times New Roman",
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Email",
                          hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Password",
                          hintStyle: const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : tryLogin,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("Login", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: const Text(
                        "Don't have an account? Sign up!",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> tryRegister() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/menu');
    } on FirebaseAuthException catch (e) {
      String err = e.message ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red, Colors.redAccent, Colors.orange], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.6,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(15)),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sign Up!",
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, fontFamily: "Times New Roman"),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Email", hintStyle: const TextStyle(fontWeight: FontWeight.bold), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Password", hintStyle: const TextStyle(fontWeight: FontWeight.bold), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : tryRegister,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                        child: loading ? const CircularProgressIndicator(color: Colors.black) : const Text("Register", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text("Already have an account? Log in!", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red, Colors.redAccent, Colors.orange], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Main Menu",
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, fontFamily: "Times New Roman"),
                    ),
                    Text(
                      "Current User: $userEmail",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(width: 180, height: 50, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/add'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent), child: const Text("Add Products", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 40),
                    SizedBox(width: 180, height: 50, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/list'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent), child: const Text("Product List", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 40),
                    SizedBox(width: 180, height: 50, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/cart'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent), child: const Text("Cart", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text("Log Out", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final int stock;

  ProductModel({required this.id, required this.name, required this.price, required this.stock});

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'price': price, 'stock': stock};
}

class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;

  CartItemModel({required this.id, required this.productId, required this.name, required this.price, required this.quantity});

  double get total => price * quantity;

  factory CartItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
    );
  }
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  bool loading = false;

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final stock = int.tryParse(stockController.text.trim()) ?? 0;

    final productsRef = FirebaseFirestore.instance.collection('products');

    final existing = await productsRef.where('name', isEqualTo: name).limit(1).get();
    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product "$name" already exists!')));
      setState(() => loading = false);
      return;
    }

    await productsRef.add({'name': name, 'price': price, 'stock': stock});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name added successfully!')));
    nameController.clear();
    priceController.clear();
    stockController.clear();

    setState(() => loading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.red, Colors.redAccent, Colors.orange], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Container(
              width: sw,
              height: sh * 0.7,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(15)),
              child: Form(
                key: _formKey,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Add A Product!", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: "Times New Roman")),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: nameController,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Product Name", hintStyle: const TextStyle(fontWeight: FontWeight.bold), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Product Price", hintStyle: const TextStyle(fontWeight: FontWeight.bold), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Product Stock", hintStyle: const TextStyle(fontWeight: FontWeight.bold), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton(onPressed: loading ? null : _saveProduct, style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent), child: loading ? const CircularProgressIndicator(color: Colors.black) : const Text("Add Product", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(width: 180, height: 50, child: ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/menu'), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text("Return", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final productsCol = FirebaseFirestore.instance.collection('products');
    final userCartCol = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCol.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products yet.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final p = doc.data() as Map<String, dynamic>;
              final stock = p['stock'] as int;
              final isOutOfStock = stock <= 0;

              return Card(
                color: isOutOfStock ? Colors.grey[300] : Colors.white,
                child: ListTile(
                  title: Text(
                    p['name'],
                    style: TextStyle(
                      color: isOutOfStock ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    isOutOfStock
                        ? "Out of Stock"
                        : "₱${(p['price'] as num).toStringAsFixed(2)} • Stock: $stock",
                    style: TextStyle(
                      color: isOutOfStock ? Colors.red : Colors.black54,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isOutOfStock)
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          color: Colors.green,
                          onPressed: () {
                            final addToCartController = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Add To Cart"),
                                  content: TextField(
                                    controller: addToCartController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "How many items?",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final qty = int.tryParse(
                                            addToCartController.text.trim()) ??
                                            0;
                                        if (qty <= 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Please enter a valid quantity.")));
                                          return;
                                        }
                                        final prodRef = productsCol.doc(doc.id);

                                        try {
                                          await FirebaseFirestore.instance
                                              .runTransaction((txn) async {
                                            final prodSnap = await txn.get(prodRef);
                                            if (!prodSnap.exists) {
                                              throw Exception("Product not found");
                                            }
                                            final currentStock = (prodSnap.data()
                                            as Map<String, dynamic>)['stock'] as int;
                                            if (qty > currentStock) {
                                              throw Exception(
                                                  "Not enough stock! Only $currentStock left.");
                                            }
                                            txn.update(prodRef, {'stock': currentStock - qty});

                                            final existingQuery = await userCartCol
                                                .where('productId', isEqualTo: doc.id)
                                                .limit(1)
                                                .get();

                                            if (existingQuery.docs.isEmpty) {
                                              final newDoc = userCartCol.doc();
                                              txn.set(newDoc, {
                                                'productId': doc.id,
                                                'name': p['name'],
                                                'price': p['price'],
                                                'quantity': qty,
                                                'addedAt': FieldValue.serverTimestamp(),
                                              });
                                            } else {
                                              final cartDoc = existingQuery.docs.first;
                                              final prevQty =
                                              (cartDoc.data()['quantity'] as int);
                                              txn.update(userCartCol.doc(cartDoc.id), {
                                                'quantity': prevQty + qty,
                                              });
                                            }
                                          });

                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                              content: Text(
                                                  "${p['name']} added to cart ($qty pcs).")));
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text(e.toString())),
                                          );
                                        }
                                      },
                                      child: const Text("Add"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      if (isOutOfStock)
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          color: Colors.red,
                          onPressed: () async {
                            await productsCol.doc(doc.id).delete();
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.add_box),
                        color: Colors.blue,
                        onPressed: () {
                          final updateStockController = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Update Stock"),
                                content: TextField(
                                  controller: updateStockController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Restock how many?",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final addedStock =
                                          int.tryParse(updateStockController.text
                                              .trim()) ??
                                              0;
                                      if (addedStock <= 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                            content: Text(
                                                "Please enter a valid quantity.")));
                                        return;
                                      }

                                      await productsCol.doc(doc.id).update({
                                        'stock': stock + addedStock,
                                      });

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              "${p['name']} stock replenished by $addedStock.")));
                                    },
                                    child: const Text("Add"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CartList extends StatelessWidget {
  const CartList({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userCartCol = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userCartCol.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          final cartDocs = snapshot.data!.docs;
          final total = cartDocs.fold<double>(
              0,
                  (sum, doc) =>
              sum +
                  ((doc.data() as Map<String, dynamic>)['price'] as num) *
                      ((doc.data() as Map<String, dynamic>)['quantity'] as int));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final doc = cartDocs[index];
                    final item = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(
                          "₱${(item['price'] as num).toStringAsFixed(2)} × ${item['quantity']} = ₱${((item['price'] as num) * (item['quantity'] as int)).toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final prodRef = FirebaseFirestore.instance
                              .collection('products')
                              .doc(item['productId']);
                          await FirebaseFirestore.instance.runTransaction((txn) async {
                            final prodSnap = await txn.get(prodRef);
                            if (prodSnap.exists) {
                              final currentStock =
                              (prodSnap.data()!['stock'] as int);
                              txn.update(prodRef, {
                                'stock': currentStock + (item['quantity'] as int)
                              });
                            }
                            txn.delete(userCartCol.doc(doc.id));
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Total: ₱${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 60),
                child: SizedBox(
                  width: 360,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final cartSnap = await userCartCol.get();
                      if (cartSnap.docs.isEmpty) return;

                      for (var doc in cartSnap.docs) {
                        await userCartCol.doc(doc.id).delete();
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Purchase successful!")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                    ),
                    child: const Text(
                      "Buy Order",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
