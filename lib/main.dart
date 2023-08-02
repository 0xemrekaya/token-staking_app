import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/accounts.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaya Token Staking Dapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  late Credentials credentials;
  final rpcUrl = dotenv.env['LOCALHOST_RPC_URL']; //Ganache server url address
  final privateKey = dotenv.env['PRIVATE_KEY']; // Ganache server Account 1 private key
  final privateKey2 = dotenv.env['PRIVATE_KEY2']; //Ganache server Account 2 private key
  List<Accounts> accounts = [];
  late Accounts currentAccount;
  late Accounts account1;
  late Accounts account2;
  String? txText;
  BigInt? userBalance;
  TextEditingController _transferController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  @override
  void initState() {
    loadContract();
    _initWeb3();
    super.initState();
  }

  // 0x4F36Cd68f45D45a6E5574a41Bd2B9c83841c999f contract address
  Future<void> _initWeb3() async {
    httpClient = Client();
    ethClient = Web3Client(
      rpcUrl.toString(),
      httpClient,
    );
    createAccount();
    currentAccount = account1;
    credentials = EthPrivateKey.fromHex(currentAccount.accountPrivateKey.toString());
  }

  Future<DeployedContract> loadContract() async {
    String EmreABI = await rootBundle.loadString("assets/emre_abi.json");
    final abiJson = jsonDecode(EmreABI);
    final abi = jsonEncode(abiJson["abi"]);
    String contractAddress = "0x877a6146d765333442BFdB48a1B461df163f585e"; //deployed contract
    final contract = DeployedContract(ContractAbi.fromJson(abi, "Emre"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<BigInt> getBalance() async {
    var address = credentials.address;
    var result = await query("balanceOf", [address]);
    return result[0] as BigInt;
  }

  Future<List<dynamic>> query(String funcName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunc = contract.function(funcName);
    final result = await ethClient.call(contract: contract, function: ethFunc, params: args);
    return result;
  }

  // Transfer fonksiyonunu kullanmak için işlev
  Future<void> transferTokens(String address, String _amount) async {
    final contract = await loadContract();
    final contractFunction = contract.function('transfer');
    int amount = int.parse(_amount);
    EthereumAddress receiver = EthereumAddress.fromHex(address);
    BigInt bigIntNumber = BigInt.from(amount) * BigInt.from(10).pow(18);
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          from: credentials.address,
          contract: contract,
          function: contractFunction,
          parameters: [receiver, bigIntNumber],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
  }

  Future<void> sendEther(String address, String _amount) async {
    int amount = int.parse(_amount);
    EthereumAddress receiver = EthereumAddress.fromHex(address);
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction(
          to: receiver,
          value: EtherAmount.fromInt(EtherUnit.ether, amount),
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
  }

  void createAccount() {
    account1 = Accounts(accountName: "Emre", accountPrivateKey: privateKey.toString());
    account2 = Accounts(accountName: "Emre 2", accountPrivateKey: privateKey2.toString());
  }

  void hesapDegistir(Accounts acc) {
    currentAccount = acc;
    credentials = EthPrivateKey.fromHex(currentAccount.accountPrivateKey.toString());
    setState(() {});
    print("Hesap değiştirildi! " + currentAccount.accountName.toString());
  }

  String _formatInt(BigInt balance) {
    // Convert the balance to decimal
    final balanceDecimal = balance / BigInt.from(10).pow(18);
    // Format the balance with desired decimal places (e.g., 2 decimal places)
    return balanceDecimal.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    accounts = [account1, account2];
    return Scaffold(
        appBar: AppBar(),
        floatingActionButton: SizedBox(
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(accounts[index].accountName),
                        subtitle: Text(accounts[index].accountPrivateKey.replaceAll("a", '*')),
                        onTap: () {
                          hesapDegistir(accounts[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              );
            },
            tooltip: "Hesap Değiştir",
            child: const Icon(Icons.swap_horiz),
          ),
        ),
        body: Column(
          children: [
            FutureBuilder<BigInt>(
              future: getBalance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error.toString()}'));
                } else {
                  final balance = snapshot.data;
                  final formattedBalance = _formatInt(balance!); // Assuming 18 decimals for ETH
                  return Center(
                      child: Column(
                    children: [
                      Text(
                        "Current account name: ${currentAccount.accountName}",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Balance of Emre token: $formattedBalance',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ));
                }
              },
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: TextFormField(
                    controller: _transferController,
                    decoration: InputDecoration(
                        hintText: 'Eth Address...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                        hintText: 'Amount: ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                      onPressed: () {
                        transferTokens(_transferController.text, _amountController.text);
                      },
                      child: Icon(Icons.send_outlined)),
                ),
                Text(txText.toString()),
              ],
            )
          ],
        ));
  }
}
