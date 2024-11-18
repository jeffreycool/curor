import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/stats_controller.dart';

class StatsView extends GetView<StatsController> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('statistics'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsSection(),
              const SizedBox(height: 24),
              _buildWeeklyStatsSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'total_statistics'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
                'total_notes'.tr, controller.statistics['notes'] ?? 0),
            _buildStatItem('total_categories'.tr,
                controller.statistics['categories'] ?? 0),
            _buildStatItem('total_tags'.tr, controller.statistics['tags'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'weekly_stats'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...controller.weeklyStats.entries.map((entry) {
              final date = entry.key;
              final count = entry.value;
              return ListTile(
                title: Text(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                ),
                trailing: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
