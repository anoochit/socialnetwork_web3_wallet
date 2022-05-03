// get wallet from private key
import 'dart:developer';
//import 'dart:math' as math;

import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:snwallet/faucet.g.dart';
import 'package:web3dart/web3dart.dart';

import 'package:bip39/bip39.dart' as bip39;

import 'const.dart';

// connect to rpc server
const String rpcUrl = "http://10.0.2.2:7545";
const String wsUrl = 'ws://localhost:8545';

late EthereumAddress currentWallet;

final Web3Client ethClient = Web3Client(rpcUrl, Client());
final EthPrivateKey credentials = EthPrivateKey.fromHex(ethPrivateKey);

// get balance
Future<EtherAmount> getBalance() async {
  return await ethClient.getBalance(credentials.address);
}

// get wallet address
Future<EthereumAddress> getWalletAddress() async {
  return await credentials.extractAddress();
}

// send coin
Future<String> sendCoin({required String toAddress, required int amount}) async {
  var result = await ethClient.sendTransaction(
    credentials,
    Transaction(
      to: EthereumAddress.fromHex(toAddress),
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 100000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, BigInt.from(amount)),
    ),
  );

  log('transaction result = $result');

  return result;
}

// Faucet contract
late String abiCode;
late DeployedContract contract;
late ContractFunction withdrawFunction;

// faucet contract
const String faucetContractAddress = "0x0e664eaB0463697c4712D062E852E3c6c9c798dd";

// create contract connection
// var client = Web3Client(rpcUrl, Client(), socketConnector: () {
//   return IOWebSocketChannel.connect(wsUrl).cast<String>();
// });

final EthereumAddress contractAddr = EthereumAddress.fromHex(faucetContractAddress);

// our contact class
late Faucet faucet;

// read contract from abi
readContract() async {
  // get abi
  abiCode = await rootBundle.loadString('lib/faucet.abi.json');

  // get contract
  contract = DeployedContract(ContractAbi.fromJson(abiCode, 'Faucet'), contractAddr);

  // set contract function
  withdrawFunction = contract.function('withdraw');

  // connect to contract
  faucet = Faucet(address: contractAddr, client: ethClient);

  // listen for event
  faucet.withdrawalEvents().take(1).listen((event) {
    log('Sent 1 ETH to ${event.to}');
  });
}

callWithdraw() async {
  try {
    String result = await faucet.withdraw(credentials: credentials);

    log('transaction result = $result');
  } catch (e) {
    log('transaction result = $e');
  }
}

// create new wallet from mnemonic
EthPrivateKey createNewWallet() {
  // random mnemonic
  //var mnemonic = bip39.generateMnemonic();

  // use static mnemonic
  var mnemonic = "robot title put fiber injury resemble copper crop hockey angry manual purchase";
  log('mnemonic = $mnemonic');

  // create seed
  String seed = bip39.mnemonicToSeedHex(mnemonic);

  // create credentials from seed
  Chain chain = Chain.seed(seed);
  ExtendedKey privateKey = chain.forPath("m/44'/60'/0'/0/0");
  EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey.privateKeyHex()); //web3dart

  // show address
  //var address = await credentials.extractAddress();
  //log('address = ${address.hex}');

  return credentials;
}
