import 'package:flutter/material.dart';
import '../../../../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text("Atox", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Welcome to ATOX",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            const Text(
              "ATOX is a revolutionary digital platform designed to help users earn daily income through simple tasks like watching ads, while also providing seamless VTU services for airtime and data top-ups.",
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              "Our Mission",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "To empower individuals across Nigeria by providing a reliable and sustainable stream of passive income, right from their smartphones.",
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text("Version 1.0.0", style: TextStyle(color: AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }
}
