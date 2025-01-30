import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerificationPill extends StatelessWidget {
  final bool isVerified;
  final String verificationType;

  const VerificationPill({
    required this.isVerified,
    required this.verificationType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isVerified
          ? null
          : () {
              context.push('/profile/verify/$verificationType');
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isVerified
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.pending,
              size: 16,
              color: isVerified ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              isVerified ? 'Verified' : 'Verify',
              style: TextStyle(
                color: isVerified ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
