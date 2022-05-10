import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:snwallet/controllers/wallet_controller.dart';

class RecievePage extends StatelessWidget {
  RecievePage({
    Key? key,
  }) : super(key: key);

  final WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: QrImage(
          data: walletController.wallet.value,
        ),
      ),
    );
  }
}
