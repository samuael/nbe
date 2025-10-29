import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';

class OpenDepositsWidget extends StatelessWidget {
  final double? remainingBalance;
  final double? increaseTotal;

  const OpenDepositsWidget(
      {required this.remainingBalance, this.increaseTotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Open Remaining Balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (remainingBalance != null)
            Text(
              NumberFormat.currency(symbol: 'Birr ', decimalDigits: 2)
                  .format(remainingBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (remainingBalance == null)
            const ShimmerSkeleton(width: 250, height: 30),
          if (increaseTotal != null)
            Text(
              "+${NumberFormat('#,##0.##').format(increaseTotal)} Birr",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
