import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

//please fill the following with your test merchant account

String username = ""; // Merchant Account username
String password = "";  // Merchant Account password
String grantType = "";
String orderId = "344";
String transactionPin = ""; // Merchant Account MPIN
String amount = "10";
String languageCode = "en";
String basicToken = "Basic TUVSQ0hBTlRfUEFZTUVOVF9HQVRFV0FZOk1lcmNoYW50R2F0ZXdheUBBZG1pbiMxMjM=";

Future<Map<String, dynamic>> fetchData() async {
  http.Response response = await http.post(
      Uri.parse("https://uatgw1.nasswallet.com/payment/transaction/login"),
      headers: <String, String>{
        "authorization": basicToken,
        "Content-Type": "application/json"
      },
      body: jsonEncode(<String, Object>{
        "data": {
          "username": username,
          "password": password,
          "grantType": grantType
        }
      }));
  // print('Login Response ' + response.body);
  if (response.statusCode == 200) {
    Map responseJson = json.decode(response.body);
    if(responseJson['responseCode'] == 0) {
      String accessToken = responseJson['data']['access_token'];
      http.Response initResponse = await http.post(
          Uri.parse("https://uatgw1.nasswallet.com/payment/transaction/initTransaction"),
          headers: <String, String>{
            "authorization": "Bearer $accessToken",
            "Content-Type": "application/json"
          },
          body: jsonEncode(<String, Object>{
            "data": {
              "userIdentifier": username,
              "transactionPin": transactionPin,
              "orderId": orderId,
              "amount": amount,
              "languageCode": languageCode
            }
          }));
      // print('initTransaction ' + initResponse.body);
      if (initResponse.statusCode == 200) {
        return json.decode(initResponse.body);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to init transaction');
      }
    } else{
      throw Exception(responseJson['message']);
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to generate token');
  }
}

class PaymentGateway extends StatefulWidget {
  const PaymentGateway({ Key? key, required this.title }) : super(key: key);
  final String title;

  @override
  _PaymentGatewayState createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway> {
  Future<Map<String, dynamic>>? apiResponse;

  @override
  void initState() {
    super.initState();
    apiResponse = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: apiResponse,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // print(snapshot.data);
              String transactionId = snapshot.data?['data']['transactionId'];
              String token = snapshot.data?['data']['token'];
              String url =
                  "https://uatcheckout1.nasswallet.com/payment-gateway?id=$transactionId&token=$token&userIdentifier=$username";
              // print(url);
              return WebView(
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}