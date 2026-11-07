import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/mqtt_service.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MqttService.instance,
      builder: (context, _) {
        final log = MqttService.instance.log;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Historique',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ),
          body: log.isEmpty
              ? Center(
                  child: Text(
                    'Aucune activité pour le moment.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: log.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.line),
                  itemBuilder: (context, i) {
                    final entry = log[i];
                    return ListTile(
                      leading: _iconForTopic(entry.topic),
                      title: Text(
                        entry.message,
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      subtitle: Text(
                        '${entry.topic} · ${DateFormat('dd/MM HH:mm:ss').format(entry.time)}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.muted,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _iconForTopic(String topic) {
    switch (topic) {
      case 'ruth/iot/alerte':
        return const Icon(Icons.warning_amber_rounded, color: AppColors.coral);
      case 'ruth/iot/camera':
        return const Icon(Icons.camera_alt_outlined, color: AppColors.teal);
      case 'ruth/iot/gps':
        return const Icon(Icons.location_on_outlined, color: AppColors.teal);
      case 'ruth/iot/temperature':
        return const Icon(Icons.thermostat, color: AppColors.muted);
      case 'ruth/iot/humidity':
        return const Icon(Icons.water_drop_outlined, color: AppColors.muted);
      default:
        return const Icon(Icons.circle, size: 8, color: AppColors.muted);
    }
  }
}
