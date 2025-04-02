import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';
import 'payment_methods_dialog.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final double amount;
  final String movieTitle;
  final VoidCallback onConfirm;

  const PaymentConfirmationDialog({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.movieTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TVFocusable(
                  id: 'confirmation-dialog-close',
                  downId: 'payment-summary',
                  rightId: 'payment-summary',
                  autofocus: true,
                  onSelect: () {
                    Navigator.of(context).pop();
                  },
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm Payment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            TVFocusable(
              id: 'payment-summary',
              upId: 'confirmation-dialog-close',
              downId: 'cancel-button',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Method:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  paymentMethod.color.withOpacity(0.2),
                              child: Icon(paymentMethod.icon,
                                  color: paymentMethod.color, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              paymentMethod.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Content:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          movieTitle,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TVFocusable(
                  id: 'cancel-button',
                  upId: 'payment-summary',
                  rightId: 'confirm-button',
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('CANCEL'),
                  ),
                ),
                TVFocusable(
                  id: 'confirm-button',
                  upId: 'payment-summary',
                  leftId: 'cancel-button',
                  onSelect: () {
                    Navigator.of(context).pop(true);
                    onConfirm();
                  },
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    child: const Text('CONFIRM'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required PaymentMethod paymentMethod,
    required double amount,
    required String movieTitle,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PaymentConfirmationDialog(
        paymentMethod: paymentMethod,
        amount: amount,
        movieTitle: movieTitle,
        onConfirm: onConfirm,
      ),
    );
  }
}
