// lib/providers/sensor_provider.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_data.dart';

class SensorProvider extends ChangeNotifier {
  SensorData _currentData = SensorData(
    timestamp: DateTime.now(),
    nitrogen: 20,
    phosphorus: 15,
    potassium: 25,
    moisture: 35,
    ph: 6.8,
    temperature: 26.0,
  );
  bool _isConnected = false;
  final List<SensorData> _history = [];
  bool _isDebugMode = true;
  String _statusMessage = 'Initializing';
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;
  BluetoothDevice? _connectedDevice;
  List<ScanResult> _discoveredResults = [];
  Timer? _mockTimer;

  SensorProvider() {
    _addToHistory(_currentData);
    _startDebugMode();
  }

  SensorData get currentData => _currentData;
  bool get isConnected => _isConnected;
  bool get isDebugMode => _isDebugMode;
  String get statusMessage => _statusMessage;
  List<SensorData> get history => List.unmodifiable(_history);

  void toggleDebugMode(bool enabled) {
    _isDebugMode = enabled;
    if (_isDebugMode) {
      _stopBleConnection();
      _startDebugMode();
    } else {
      _stopMockMode();
      scanForSensor();
    }
    notifyListeners();
  }

  Future<void> scanForSensor() async {
    if (_isDebugMode) {
      _statusMessage = 'Switching to BLE scan';
      _isDebugMode = false;
    }
    _stopMockMode();
    await _startBleScan();
    notifyListeners();
  }

  List<ScanResult> get discoveredResults => List.unmodifiable(_discoveredResults);

  Future<bool> _ensureBlePermissions() async {
    if (!Platform.isAndroid) return true;

    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (scanStatus.isGranted && connectStatus.isGranted && locationStatus.isGranted) {
      return true;
    }

    _statusMessage = 'Required BLE permissions not granted';
    notifyListeners();
    return false;
  }

  void _startDebugMode() {
    _statusMessage = 'Mocking Active';
    _isConnected = false;
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final random = Random();
      _currentData = SensorData(
        timestamp: DateTime.now(),
        nitrogen: 10 + random.nextDouble() * 50,
        phosphorus: 10 + random.nextDouble() * 45,
        potassium: 10 + random.nextDouble() * 50,
        moisture: 20 + random.nextDouble() * 30,
        ph: 6.0 + random.nextDouble() * 1.5,
        temperature: 20 + random.nextDouble() * 10,
      );
      _addToHistory(_currentData);
      notifyListeners();
    });
  }

  void _stopMockMode() {
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  Future<void> _startBleScan() async {
    _statusMessage = 'Scanning for KrishiDrishti Sensor';
    notifyListeners();

    try {
      final ok = await _ensureBlePermissions();
      if (!ok) return;

      _scanSubscription?.cancel();
      _discoveredResults.clear();
      notifyListeners();

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _discoveredResults = results;
        notifyListeners();
      }, onError: (error) {
        _statusMessage = 'Scan failed';
        notifyListeners();
      });
    } catch (error) {
      _statusMessage = 'Scan error';
      notifyListeners();
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _scanSubscription?.cancel();
      _connectedDevice = device;
      _statusMessage = 'Connecting to sensor';
      notifyListeners();

      await device.connect(timeout: const Duration(seconds: 12), autoConnect: false);
      _isConnected = true;
      _statusMessage = 'BLE Connected';
      notifyListeners();

      final services = await device.discoverServices();
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.notify || characteristic.properties.read) {
            await characteristic.setNotifyValue(true);
            _notificationSubscription = characteristic.lastValueStream.listen((bytes) {
              _handleCharacteristicUpdate(bytes);
            });
          }
        }
      }
    } catch (error) {
      _statusMessage = 'Connection error';
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await _connectToDevice(device);
  }

  void _handleCharacteristicUpdate(List<int> bytes) {
    try {
      final payload = utf8.decode(bytes);
      final json = jsonDecode(payload) as Map<String, dynamic>;
      _currentData = SensorData.fromJson(json);
      _addToHistory(_currentData);
      _statusMessage = 'BLE Connected';
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Invalid sensor data';
      debugPrint('Sensor parse error: $e');
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _stopMockMode();
    _scanSubscription?.cancel();
    _notificationSubscription?.cancel();
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
      _connectedDevice = null;
    }
    _isConnected = false;
    _statusMessage = 'Disconnected';
    notifyListeners();
  }

  void _stopBleConnection() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _connectedDevice = null;
    _isConnected = false;
    FlutterBluePlus.stopScan();
  }

  void _addToHistory(SensorData data) {
    _history.insert(0, data);
    if (_history.length > 20) {
      _history.removeLast();
    }
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _scanSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
