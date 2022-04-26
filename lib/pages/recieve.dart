import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RecievePage extends StatelessWidget {
  final String? walletAddress;

  const RecievePage({
    Key? key,
    required this.walletAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Addresss"),
      ),
      body: Center(
        child: QrImage(
          data: walletAddress.toString(),
        ),
      ),
    );
  }
}
