import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../theme.dart';
import 'pairing_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = MqttService.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paramètres',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsTile(
            icon: Icons.watch_outlined,
            title: 'Code du bracelet',
            value: mqtt.pairingCode ?? '—',
          ),
          _SettingsTile(
            icon: Icons.dns_outlined,
            title: 'Broker MQTT',
            value: MqttService.broker,
          ),
          const _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Chiffrement',
            value: 'Non (démo Wokwi)',
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                mqtt.disconnectAndReset();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const PairingScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.link_off, color: AppColors.coral),
              label: const Text(
                'Dissocier le bracelet',
                style: TextStyle(color: AppColors.coral),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.coral),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13.5, color: AppColors.navy),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
