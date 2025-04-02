import 'package:flutter/material.dart';
import 'package:simple_tv_navigation/simple_tv_navigation.dart';
import '../widgets/payment_methods_dialog.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final String movieTitle;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.paymentMethod,
    required this.movieTitle,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = true;
  String _status = "Processing payment...";

  @override
  void initState() {
    super.initState();
    _simulatePaymentProcess();
  }

  void _simulatePaymentProcess() async {
    // Simulate payment processing time
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _status = "Verifying payment information...";
      });
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _status = "Completing transaction...";
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Payment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: _processing ? _buildProcessingView() : _buildCompletedView(),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return TVFocusable(
      autofocus: true,
      id: "payment-processing-view",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.red,
            strokeWidth: 5,
          ),
          const SizedBox(height: 30),
          Text(
            _status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Please do not close this page",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          widget.paymentMethod.color.withOpacity(0.2),
                      child: Icon(widget.paymentMethod.icon,
                          color: widget.paymentMethod.color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.paymentMethod.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${widget.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            "Payment Successful!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Thank you for your purchase",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          widget.paymentMethod.color.withOpacity(0.2),
                      child: Icon(widget.paymentMethod.icon,
                          color: widget.paymentMethod.color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.paymentMethod.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${widget.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Transaction ID: TRX-293847561",
                  style: TextStyle(color: Colors.white70),
                ),
                const Text(
                  "Date: 2023-07-15 14:30:25",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TVFocusable(
            id: "back-to-movie-button",
            autofocus: true,
            onSelect: () {
              Navigator.of(context).pop();
            },
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("BACK TO MOVIE"),
            ),
          ),
        ],
      ),
    );
  }
}
