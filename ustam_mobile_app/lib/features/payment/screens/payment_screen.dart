import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentScreen extends ConsumerWidget {
  final String jobId;
  
  const PaymentScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme'),
      ),
      body: const Center(
        child: const Text('Ödeme Ekranı - Geliştiriliyor'),
      ),
    );
  }
}