import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String gasFee;
  final String amount;
  final String receiverAddress;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog({super.key, 
    required this.gasFee,
    required this.amount,
    required this.receiverAddress,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gas Fee: $gasFee'),
            Text('Amount: $amount'),
            Text('Receiver Address: $receiverAddress'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: onConfirm,
                  child: const Text('Confirm'),
                ),
                ElevatedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}