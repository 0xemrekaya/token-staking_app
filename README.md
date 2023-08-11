# Flutter- Emre Token Staking App

## Project Description
This project includes a Solidity smart contract written in the Solidity language and a user interface built with Flutter. The Solidity smart contract is used to manage the Emre Token, perform staking operations, and distribute rewards. The Flutter application allows users to manage their accounts, stake Emre Tokens, and claim rewards.

## Photos from app
![MicrosoftTeams-image](https://github.com/emrekaya035/token-staking_app/assets/72754835/e12d8610-ad55-49fa-b401-3262966c323e)
![MicrosoftTeams-image (1)](https://github.com/emrekaya035/token-staking_app/assets/72754835/030950e7-43ed-4824-a7eb-4c093033dcb2)
![MicrosoftTeams-image (2)](https://github.com/emrekaya035/token-staking_app/assets/72754835/26884cd5-dc50-4af1-ac7c-72df6140059a)

## Requirements
*  Ensure that you have Flutter and Dart SDK installed.
*  You'll need an Ethereum development environment to test the Solidity smart contract on the Ethereum network.

## Usage
The Emre Token Staking Dapp provides a user-friendly interface to interact with the Ethereum blockchain, allowing you to perform various actions related to the Emre Token and its staking mechanism. Follow these steps to navigate through the app and make the most out of its features:

### Account Management
Account Selection: Upon launching the app, you'll be prompted to choose between different accounts. Select an account to proceed. You can easily switch between different accounts using the account swap button on the top-right corner of the screen.

Balance Check: After selecting an account, you'll see the balance of Emre Tokens associated with that account. This balance represents the amount of tokens you currently possess.

### Token Transfers
Transfer Tokens: To send Emre Tokens to another Ethereum address, click on the "Transfer" tab. Enter the recipient's Ethereum address and the amount of tokens you wish to transfer. Confirm the transfer by clicking the "Send" button. A confirmation dialog will appear, providing you with details about the transaction, including gas fees. Review the information and proceed to confirm the transfer.
Staking Operations
Stake Tokens: The "Stake" tab allows you to participate in the token staking process. Enter the desired amount of Emre Tokens you want to stake and click the "Stake Tokens" button. This action locks your tokens in the staking contract, making you eligible to earn rewards over time. Confirm the transaction in the following dialog.

Stake Approval: Before staking, you'll need to approve the staking contract to spend a certain amount of your tokens. This approval is a one-time process. Click on the "approve tokens" button in the "Stake" tab, enter the desired amount, and confirm the approval.

Reward Claim: As you stake tokens, you accumulate rewards over time. To claim your rewards, click on the "Get Reward" button in the "Wallet" tab. The rewards you've earned will be transferred to your account. You can claim rewards periodically or let them accumulate over time.

Withdraw Staked Tokens: If you decide to end your staking, you can click the "Withdraw All Staked Tokens" button in the "Wallet" tab. This action will release your staked tokens, and you'll no longer earn rewards. Confirm the withdrawal in the displayed dialog.

### Reward Information
Total Staked Token Supply: In the "Wallet" tab, you can view the total supply of staked tokens. This value represents the sum of tokens staked by all participants.

Staked Token Balance: You can also check your individual staked token balance in the "Wallet" tab. This balance represents the tokens you've currently staked.

Earned Tokens: The app provides real-time information about the tokens you've earned through staking. The "Wallet" tab displays the accumulated rewards that you can claim.

Reward Rate and Reward Per Token: The app displays graphical representations of the reward rate and reward per token in the "Wallet" tab. These graphs provide insights into the distribution of rewards.

### Changing Staking Duration and Reward Amount
Set Duration: As an account with certain privileges (e.g., owner), you have the ability to set the duration for which rewards will be distributed. Use the "Set duration" feature in the "Wallet" tab to adjust the staking duration.

Set Reward Amount: Similarly, you can adjust the reward amount to be distributed by using the "Set reward" feature in the "Wallet" tab. This allows you to control the rate at which rewards are distributed among participants.

Remember that all transactions on the Ethereum blockchain involve gas fees, and these fees may vary depending on network congestion and other factors. Make sure to review transaction details and confirmations before proceeding.

### Conclusion
For more technical details and developer insights, refer to the relevant sections of the README and the provided smart contract and Flutter app code.
