import 'package:ethers/ethers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:snwallet/const.dart';
import 'package:snwallet/generated/gift.g.dart';
import 'package:web3dart/web3dart.dart';

class GiftTokenController extends GetxController {
  // gift contract
  late String abiCode;
  late DeployedContract contract;

  final String giftContractAddress = "0xE557638C01f783b9124A5F354bC256229f1ea431";
  late EthereumAddress contractAddr;
  late Gift gift;
  late Web3Client ethClient;

  GiftTokenController() {
    readContract();
  }

  readContract() async {
    // get abi
    abiCode = await rootBundle.loadString('lib/generated/gift.abi.json');

    // get contract
    contractAddr = EthereumAddress.fromHex(giftContractAddress);
    contract = DeployedContract(ContractAbi.fromJson(abiCode, 'Gift'), contractAddr);

    // connect to contract
    ethClient = Web3Client(rpcUrl, Client());
    gift = Gift(address: contractAddr, client: ethClient);
  }

  // Future<List<dynamic>> callBalanceOf({required String address}) async {
  //   return await ethClient.call(contract: contract, function: balanceOf, params: [EthereumAddress.fromHex(address)]);
  // }

  Future<BigInt> callBalanceOf({required String address}) async {
    return await gift.balanceOf(EthereumAddress.fromHex(address));
  }

  Future<String> callApprove(EthereumAddress spender, Credentials credentials, String amount) async {
    return await gift.approve(
      spender,
      ethers.utils.parseEther(amount),
      credentials: credentials,
    );
  }
}
