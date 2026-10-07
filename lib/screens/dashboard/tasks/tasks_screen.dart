import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/constants.dart';
import '../../../utils/currency_formatter.dart';
import '../../../services/database_service.dart';
import '../../../models/purchase_model.dart';
import '../../../providers/user_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _loading = true;
  List<PurchaseModel> _activePlans = [];
  Map<String, int> _adProgress = {};

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dbService = DatabaseService();
    final purchases = await dbService.getUserPurchases(user.uid);

    final active = purchases
        .where(
          (p) => p.expiresAt == null || p.expiresAt!.isAfter(DateTime.now()),
        )
        .toList();

    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    Map<String, int> progressMap = {};

    for (var plan in active) {
      final progress = await dbService.getAdProgress(
        user.uid,
        plan.productId,
        todayKey,
      );
      progressMap[plan.productId] = progress['adsWatched'] as int? ?? 0;
    }

    if (mounted) {
      setState(() {
        _activePlans = active;
        _adProgress = progressMap;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _activePlans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Active Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Purchase a plan to start earning',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchTasks,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _activePlans.length,
                itemBuilder: (context, index) {
                  final plan = _activePlans[index];
                  final watched = _adProgress[plan.productId] ?? 0;
                  final totalAds = plan.ads ?? 20;
                  final earningPerAd = (plan.dailyIncome ?? 750) / totalAds;
                  final isDone = watched >= totalAds;
                  final progressPct = (watched / totalAds).clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDone
                            ? Colors.green.shade200
                            : Colors.blue.shade100,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isDone ? "✅" : "📺",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      plan.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? Colors.green.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isDone
                                        ? "Completed Today"
                                        : "Active — Watching",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDone
                                          ? Colors.green.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Daily Income",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(
                                    (plan.dailyIncome ?? 0).toDouble(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ads Watched Today",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              "$watched / $totalAds",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progressPct,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDone
                                ? Colors.green.shade500
                                : Colors.blue.shade500,
                          ),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Earned: ${CurrencyFormatter.format(watched * earningPerAd.toDouble())}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            Text(
                              "Remaining: ${CurrencyFormatter.format((totalAds - watched) * earningPerAd.toDouble())}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                "Per Ad",
                                CurrencyFormatter.format(earningPerAd),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatItem("Total Ads", "$totalAds"),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatItem(
                                "Left Today",
                                "${(totalAds - watched).clamp(0, 999)}",
                                textColor: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isDone
                                ? null
                                : () {
                                    // TODO: Open ad viewer / plan screen
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDone
                                  ? Colors.grey.shade100
                                  : Colors.blue.shade600,
                              foregroundColor: isDone
                                  ? Colors.grey.shade500
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isDone)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                if (!isDone)
                                  const Text(
                                    "📺",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  isDone
                                      ? "All Done for Today!"
                                      : "Start Watching Ads",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildStatItem(String title, String value, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
