import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage(title: 'Customer Management'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String baseUrl = "http://192.168.81.208:8080/api/v1/customer";
  final Dio _dio = Dio();

  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerSalaryController = TextEditingController();

  List<Map<String, dynamic>> customers = [];

  Future<void> handleSaveCustomer() async {
    final customer = {
      'id': _customerIdController.text,
      'name': _customerNameController.text,
      'address': _customerAddressController.text,
      'salary': _customerSalaryController.text
    };

    try {
      await _dio.post('$baseUrl/saveCustomer',
          data: customer,
          options: Options(headers: {
            'Content-Type': 'application/json'
          }));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Saved Successfully!')));
      loadAllCustomers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Save Error!')));
    }
  }

  Future<void> handleSearchCustomer() async {
    try {
      final response = await _dio.get('$baseUrl/searchCustomer/${_customerIdController.text}');
      _customerNameController.text = response.data['name'];
      _customerAddressController.text = response.data['address'];
      _customerSalaryController.text = response.data['salary'];
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Search Error!')));
    }
  }

  Future<void> handleUpdateCustomer() async {
    final customer = {
      'id': _customerIdController.text,
      'name': _customerNameController.text,
      'address': _customerAddressController.text,
      'salary': _customerSalaryController.text
    };

    try {
      await _dio.put('$baseUrl/updateCustomer',
          data: customer,
          options: Options(headers: {
            'Content-Type': 'application/json'
          }));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Updated Successfully!')));
      loadAllCustomers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Update Error!')));
    }
  }

  Future<void> handleDeleteCustomer() async {
    try {
      await _dio.delete('$baseUrl/deleteCustomer/${_customerIdController.text}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Deleted Successfully!')));
      loadAllCustomers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Delete Error!')));
    }
  }

  Future<void> loadAllCustomers() async {
    try {
      final response = await _dio.get('$baseUrl/loadAllCustomers');
      setState(() {
        customers = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Load All Customers Error!')));
    }
  }

  @override
  void initState() {
    super.initState();
    loadAllCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _customerIdController,
              decoration: const InputDecoration(labelText: 'Customer ID'),
            ),
            TextField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: _customerAddressController,
              decoration: const InputDecoration(labelText: 'Customer Address'),
            ),
            TextField(
              controller: _customerSalaryController,
              decoration: const InputDecoration(labelText: 'Customer Salary'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton(onPressed: handleSaveCustomer, child: const Text('Save')),
                ElevatedButton(onPressed: handleSearchCustomer, child: const Text('Search')),
                ElevatedButton(onPressed: handleUpdateCustomer, child: const Text('Update')),
                ElevatedButton(onPressed: handleDeleteCustomer, child: const Text('Delete')),
                ElevatedButton(onPressed: loadAllCustomers, child: const Text('Load All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Text(customer['id']),
                      title: Text(customer['name']),
                      subtitle: Text(customer['address']),
                      trailing: Text(customer['salary']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
