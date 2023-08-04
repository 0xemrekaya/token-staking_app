import 'dart:convert';
import 'dart:ffi';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/accounts.dart';
import 'package:flutter_application_1/confirmation_dialog_widget.dart';
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
  String? duration;
  String? rewards;
  String? stakeToken;
  String? approveToken;
  String txText = "";
  BigInt? userBalance;
  String? totalSupply;
  String? stakingRewardsRate;
  String? rewardPerToken;
  TextEditingController _transferController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  int currentIndex = 0;
  @override
  void initState() {
    loadEmreContract();
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

  Future<DeployedContract> loadEmreContract() async {
    String EmreABI = await rootBundle.loadString("assets/emre_abi.json");
    final abiJson = jsonDecode(EmreABI);
    final abi = jsonEncode(abiJson["abi"]);
    String contractAddress = "0x408A75B834DAA994dd9c421e095E0c527d16104B"; //deployed contract
    final contract = DeployedContract(ContractAbi.fromJson(abi, "Emre"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<DeployedContract> loadStakingRewardsContract() async {
    String StakingRewardsABI = await rootBundle.loadString("assets/StakingRewards_abi.json");
    final abiJson = jsonDecode(StakingRewardsABI);
    final abi = jsonEncode(abiJson["abi"]);
    String contractAddress = "0x4B0743c182838824ffF2469cB7a573cFBc069144"; //deployed contract
    final contract =
        DeployedContract(ContractAbi.fromJson(abi, "StakingRewards"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<BigInt> getBalance() async {
    var address = credentials.address;
    var result = await queryEmreContract("balanceOf", [address]);
    return result[0] as BigInt;
  }

  Future<BigInt> getStakedBalanceOf() async {
    var address = credentials.address;
    var result = await queryStakingRewardsContract("balanceOf", [address]);
    return result[0] as BigInt;
  }

  Future<BigInt> getEarned() async {
    var address = credentials.address;
    var result = await queryStakingRewardsContract("earned", [address]);
    return result[0] as BigInt;
  }

  Future<String> getRewardRate() async {
    var result = await queryStakingRewardsContract("rewardRate", []);
    var a = result[0] as BigInt;
    stakingRewardsRate = a.toString();
    return stakingRewardsRate!;
  }

  Future<String> rewardPerTokens() async {
    var result = await queryStakingRewardsContract("rewardPerToken", []);
    var a = result[0] as BigInt;
    rewardPerToken = a.toString();
    return rewardPerToken!;
  }

  Future<BigInt> getStakedTokenTotalSupply() async {
    var result = await queryStakingRewardsContract("totalSupply", []);
    return result[0] as BigInt;
  }

  Future<List<dynamic>> queryStakingRewardsContract(String funcName, List<dynamic> args) async {
    final contract = await loadStakingRewardsContract();
    final ethFunc = contract.function(funcName);
    final result = await ethClient.call(contract: contract, function: ethFunc, params: args);
    return result;
  }

  Future<void> getReward() async {
    final contract = await loadStakingRewardsContract();
    final contractFunction = contract.function('getReward');
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          from: credentials.address,
          contract: contract,
          function: contractFunction,
          parameters: [],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
    setState(() {});
  }

  Future<void> withdraw() async {
    final contract = await loadStakingRewardsContract();
    final contractFunction = contract.function('withdraw');
    final stakedToken = await getStakedBalanceOf();
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          from: credentials.address,
          contract: contract,
          function: contractFunction,
          parameters: [stakedToken],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
    setState(() {});
  }

  Future<void> stakeForApprove(String approveToken) async {
    final contract = await loadEmreContract();
    final contractFunction = contract.function('approve');
    EthereumAddress spender = EthereumAddress.fromHex("0x4B0743c182838824ffF2469cB7a573cFBc069144");
    int amount = int.parse(approveToken);
    BigInt bigIntNumber = BigInt.from(amount) * BigInt.from(10).pow(18);
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          from: credentials.address,
          contract: contract,
          function: contractFunction,
          parameters: [spender, bigIntNumber],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
    setState(() {});
  }

  Future<void> stakeTokens(String stakeToken) async {
    final contract = await loadStakingRewardsContract();
    final contractFunction = contract.function('stake');
    int amount = int.parse(stakeToken);
    BigInt bigIntNumber = BigInt.from(amount) * BigInt.from(10).pow(18);
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          from: credentials.address,
          contract: contract,
          function: contractFunction,
          parameters: [bigIntNumber],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
    setState(() {});
  }

  Future<void> setDurationOfStaking(String duration) async {
    int amount = int.parse(duration);
    BigInt bigIntNumber = BigInt.from(amount);
    final contract = await loadStakingRewardsContract();
    final contractFunction = contract.function('setRewardsDuration');
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          from: credentials.address,
          contract: contract,
          function: contractFunction,
          parameters: [bigIntNumber],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
    setState(() {});
  }

  Future<void> setNotifyRewardAmount(String rewards) async {
    int amount = int.parse(rewards);
    final contract = await loadStakingRewardsContract();
    final contractFunction = contract.function('notifyRewardAmount');
    BigInt bigIntNumber = BigInt.from(amount) * BigInt.from(10).pow(18);
    final response = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          from: credentials.address,
          contract: contract,
          function: contractFunction,
          parameters: [bigIntNumber],
          maxGas: 1000000,
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);
    txText = response;
    setState(() {});
  }

  Future<List<dynamic>> queryEmreContract(String funcName, List<dynamic> args) async {
    final contract = await loadEmreContract();
    final ethFunc = contract.function(funcName);
    final result = await ethClient.call(contract: contract, function: ethFunc, params: args);
    return result;
  }

  // Transfer fonksiyonunu kullanmak için işlev
  Future<void> transferTokens(String address, String _amount) async {
    final contract = await loadEmreContract();
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
    setState(() {});
  }

  Future<void> showConfirmationDialog(BuildContext context, String address, String _amount) async {
    String gasFee = "200000 wei"; // Replace with the actual gas fee
    String amount = _amount; // Assuming you have `_amount` variable defined in your code
    String receiverAddress = address; // Assuming you have `address` variable defined in your code

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          gasFee: gasFee,
          amount: amount,
          receiverAddress: receiverAddress,
          onConfirm: () {
            Navigator.of(context).pop(); // Close the bottom sheet
            transferTokens(address, _amount); // Call the transfer function
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close the bottom sheet
          },
        );
      },
    );
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
  String _formatDouble(BigInt balance) {
    // Convert the balance to decimal
    final balanceDecimal = balance / BigInt.from(10).pow(18);
    // Format the balance with desired decimal places (e.g., 2 decimal places)
    return balanceDecimal.toStringAsFixed(20);
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
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.send_outlined), label: "Transfer"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Wallet")
          ],
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
        ),
        body: currentIndex == 0 ? transfer(context) : wallet(context));
  }

  Column wallet(BuildContext context) {
    getRewardRate();
    rewardPerTokens();
    return Column(
      children: [
        Center(
          child: FutureBuilder<BigInt>(
            future: getStakedTokenTotalSupply(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error.toString()}'));
              } else {
                final balance = snapshot.data;
                final formattedBalance = _formatInt(balance!); // Assuming 18 decimals for ETH
                totalSupply = formattedBalance;
                return Center(
                    child: Column(
                  children: [
                    Text(
                      "Current account name: ${currentAccount.accountName}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Staked token total supply: $formattedBalance',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    FutureBuilder<BigInt>(
                      future: getStakedBalanceOf(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error.toString()}'));
                        } else {
                          final balance = snapshot.data;
                          final formattedBalance = _formatInt(balance!);
                          return Center(
                              child: Column(
                            children: [
                              Text(
                                "Your staked token: ${formattedBalance}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ));
                        }
                      },
                    ),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(

                              color: Colors.blue,
                              value: double.tryParse(stakingRewardsRate!),
                              title: '$stakingRewardsRate',
                              showTitle: true,
                            ),
                            PieChartSectionData(
                              color: Colors.green,
                              value: double.tryParse(rewardPerToken!),
                              title: '$rewardPerToken',
                              showTitle: true,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ));
              }
            },
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        FutureBuilder<BigInt>(
          future: getEarned(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else {
              final balance = snapshot.data;
              var a = _formatDouble(balance!);
              return Center(
                  child: Column(
                children: [
                  Text(
                    'Earned tokens: $a',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ));
            }
          },
        ),
        ElevatedButton(
            onPressed: () {
              getReward();
            },
            child: Text("Get Reward")),
        ElevatedButton(
            onPressed: () {
              withdraw();
            },
            child: Text("Withdraw All Staked Tokens"))
      ],
    );
  }

  SingleChildScrollView transfer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                        borderSide: const BorderSide(color: Colors.grey),
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
                        borderSide: const BorderSide(color: Colors.grey),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                    onPressed: () {
                      showConfirmationDialog(context, _transferController.text, _amountController.text);
                    },
                    child: const Icon(Icons.send_outlined)),
              ),
              Text(txText.toString()),
              Column(
                children: [
                  currentAccount == account1 ? setDurationRewards() : const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            approveToken = value;
                          },
                          decoration: InputDecoration(
                              hintText: 'Approve: ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.grey),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              stakeForApprove(approveToken!);
                            },
                            child: const Text("approve tokens")),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            stakeToken = value;
                          },
                          decoration: InputDecoration(
                              hintText: 'Stake: ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.grey),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                            onPressed: () {
                              stakeTokens(stakeToken!);
                            },
                            child: const Text("Stake tokens")),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Column setDurationRewards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 130,
              height: 50,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  duration = value;
                },
                decoration: InputDecoration(
                    hintText: 'Duration: ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    setDurationOfStaking(duration!);
                  },
                  child: const Text("Set duration")),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 130,
              height: 50,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  rewards = value;
                },
                decoration: InputDecoration(
                    hintText: 'Rewards: ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    setNotifyRewardAmount(rewards!);
                  },
                  child: const Text("Set reward")),
            ),
          ],
        ),
      ],
    );
  }
}
