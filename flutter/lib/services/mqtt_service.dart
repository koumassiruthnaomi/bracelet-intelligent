import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class LogEntry {
  final String topic;
  final String message;
  final DateTime time;
  LogEntry(this.topic, this.message, this.time);
}

/// Service MQTT partagé par toute l'app (singleton).
/// Se connecte au même broker que le sketch ESP32 (Wokwi).
class MqttService extends ChangeNotifier {
  MqttService._internal();
  static final MqttService instance = MqttService._internal();

  static const String broker = 'test.mosquitto.org';
  static const int port = 1883;
  static const List<String> topics = [
    'ruth/iot/temperature',
    'ruth/iot/humidity',
    'ruth/iot/alerte',
    'ruth/iot/camera',
    'ruth/iot/gps',
  ];

  MqttServerClient? _client;
  MqttConnectionState connectionState = MqttConnectionState.disconnected;

  String? temperature;
  String? humidity;
  DateTime? lastUpdate;

  bool alertActive = false;
  Timer? _alertTimer;

  final List<LogEntry> log = [];
  String? pairingCode;

  Future<void> connect(String code) async {
    pairingCode = code;

    final clientId = 'flutter_bracelet_${Random().nextInt(100000)}';
    _client = MqttServerClient.withPort(broker, clientId, port);
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      _client!.disconnect();
      rethrow;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      for (final t in topics) {
        _client!.subscribe(t, MqttQos.atLeastOnce);
      }
      _client!.updates!.listen(_onMessage);
    }
  }

  void _onConnected() {
    connectionState = MqttConnectionState.connected;
    notifyListeners();
  }

  void _onDisconnected() {
    connectionState = MqttConnectionState.disconnected;
    notifyListeners();
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );
    final topic = messages[0].topic;
    final now = DateTime.now();

    log.insert(0, LogEntry(topic, payload, now));
    if (log.length > 30) log.removeLast();

    if (topic == 'ruth/iot/temperature') {
      temperature = _extractNumber(payload);
      lastUpdate = now;
    } else if (topic == 'ruth/iot/humidity') {
      humidity = _extractNumber(payload);
      lastUpdate = now;
    } else if (topic == 'ruth/iot/alerte') {
      alertActive = true;
      _alertTimer?.cancel();
      _alertTimer = Timer(const Duration(seconds: 8), () {
        alertActive = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  String _extractNumber(String payload) {
    final match = RegExp(r'-?\d+[.,]?\d*').firstMatch(payload);
    return match?.group(0)?.replaceAll(',', '.') ?? payload;
  }

  void disconnectAndReset() {
    _client?.disconnect();
    connectionState = MqttConnectionState.disconnected;
    temperature = null;
    humidity = null;
    log.clear();
    pairingCode = null;
    notifyListeners();
  }
}
