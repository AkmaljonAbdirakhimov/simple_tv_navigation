import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class PaymentMethodsDialog extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final Function(PaymentMethod) onPaymentMethodSelected;

  const PaymentMethodsDialog({
    super.key,
    required this.paymentMethods,
    required this.onPaymentMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TVFocusable(
                  id: 'payment-dialog-close',
                  downId: paymentMethods.isNotEmpty
                      ? 'payment-method-${paymentMethods[0].id}'
                      : null,
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
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              itemCount: paymentMethods.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return TVFocusable(
                  id: 'payment-method-${method.id}',
                  upId: index == 0
                      ? 'payment-dialog-close'
                      : 'payment-method-${paymentMethods[index - 1].id}',
                  downId: index == paymentMethods.length - 1
                      ? null
                      : 'payment-method-${paymentMethods[index + 1].id}',
                  onSelect: () {
                    onPaymentMethodSelected(method);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: method.color.withOpacity(0.2),
                      child: Icon(method.icon, color: method.color),
                    ),
                    title: Text(
                      method.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 16),
                    onTap: () {
                      onPaymentMethodSelected(method);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<PaymentMethod?> show(BuildContext context) async {
    final methods = [
      const PaymentMethod(
        id: 'credit_card',
        name: 'Credit Card',
        icon: Icons.credit_card,
        color: Colors.blue,
      ),
      const PaymentMethod(
        id: 'paypal',
        name: 'PayPal',
        icon: Icons.account_balance_wallet,
        color: Colors.indigo,
      ),
      const PaymentMethod(
        id: 'apple_pay',
        name: 'Apple Pay',
        icon: Icons.apple,
        color: Colors.grey,
      ),
      const PaymentMethod(
        id: 'google_pay',
        name: 'Google Pay',
        icon: Icons.g_mobiledata,
        color: Colors.green,
      ),
    ];

    return showDialog<PaymentMethod>(
      context: context,
      builder: (context) => PaymentMethodsDialog(
        paymentMethods: methods,
        onPaymentMethodSelected: (method) {
          Navigator.of(context).pop(method);
        },
      ),
    );
  }
}
