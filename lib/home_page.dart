import 'package:flutter/material.dart';
import 'package:nasswallet_flutter/payment_gateway.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                    const PaymentGateway(title: 'Flutter Payment Demo')),
            );
          },
          child: const Text('Make Payment', style: TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}