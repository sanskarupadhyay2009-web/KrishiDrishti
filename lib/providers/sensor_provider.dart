import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enhanced Sensor Data Model
class SensorData {
  final double moisture;
  final double ph;
  final double temperature;
  final DateTime timestamp;
  final int signalStrength; // RSSI value

  SensorData({
    required this.moisture,
    required this.ph,
    required this.temperature,
    required this.signalStrength,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      moisture: (json['moisture'] as num?)?.toDouble() ?? 0.0,
      ph: (json['ph'] as num?)?.toDouble() ?? 7.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
      signalStrength: json['signal'] as int? ?? -100,
    );
  }

  Map<String, dynamic> toJson() => {
        'moisture': moisture,
        'ph': ph,
        'temperature': temperature,
        'timestamp': timestamp.toIso8601String(),
        'signal': signalStrength,
      };

  @override
  String toString() =>
      'SensorData(moisture: $moisture%, pH: $ph, temp: ${temperature}°C, signal: ${signalStrength}dBm)';
}

/// BLE Status enumeration
enum BleStatus {
  unknown,
  unavailable,
  unauthorized,
  turningOn,
  on,
  turningOff,
  off,
}

/// Enhanced Sensor Provider with improved ESP32 detection
class SensorProvider extends ChangeNotifier {
  // BLE & Configuration
  bool _isDebugMode = true;
  BleStatus _bleStatus = BleStatus.unknown;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _sensorCharacteristic;

  // Sensor state
  SensorData? _currentData;
  List<SensorData> _dataHistory = [];
  String _statusMessage = 'Initializing...';
  bool _isScanning = false;
  List<BluetoothDevice> _discoveredDevices = [];
  Map<String, int> _deviceSignalStrengths = {}; // RSSI tracking

  // Timers
  Timer? _mockTimer;
  StreamSubscription<BluetoothAdapterState>? _bleStatusSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  // Configuration
  static const String TARGET_DEVICE_NAME = 'KrishiDrishti';
  static const String FALLBACK_DEVICE_NAME = 'ESP32';
  static const Duration SCAN_TIMEOUT = Duration(seconds: 15);
  static const int HISTORY_LIMIT = 100;

  // Getters
  bool get isDebugMode => _isDebugMode;
  BleStatus get bleStatus => _bleStatus;
  SensorData? get currentData => _currentData;
  List<SensorData> get dataHistory => List.unmodifiable(_dataHistory);
  String get statusMessage => _statusMessage;
  bool get isScanning => _isScanning;
  List<BluetoothDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);
  bool get isConnected => _connectedDevice != null;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  String get connectionStatus => isConnected
      ? 'BLE Connected: ${_connectedDevice?.platformName} (${_deviceSignalStrengths[_connectedDevice?.remoteId.toString()] ?? -100}dBm)'
      : 'Debug Mode: Mock Data Active';
  int get connectedDeviceSignal =>
      _deviceSignalStrengths[_connectedDevice?.remoteId.toString()] ?? -100;

  // Singleton
  static final SensorProvider _instance = SensorProvider._internal();

  factory SensorProvider() {
    return _instance;
  }

  SensorProvider._internal() {
    _initBle();
  }

  /// Initialize BLE and request permissions
  Future<void> _initBle() async {
    try {
      // Request permissions
      await _requestBluetoothPermissions();

      _bleStatusSubscription = FlutterBluePlus.adapterState.listen((state) {
        _bleStatus = _mapBleAdapterState(state);
        _statusMessage = 'BLE: ${_bleStatus.name}';
        debugPrint('[BLE] Status: $_statusMessage');
        notifyListeners();
      });

      // Start with mock data if in debug mode
      if (_isDebugMode) {
        _startMockDataGeneration();
      }

      _statusMessage = 'Ready';
      debugPrint('[Sensor] Initialization complete');
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Init Error: $e';
      debugPrint('[Error] $_statusMessage');
      notifyListeners();
    }
  }

  /// Request Bluetooth and location permissions
  Future<void> _requestBluetoothPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      debugPrint('[Permissions] ${permission.toString()}: ${status.name}');
    }
  }

  /// Map BLE adapter state
  BleStatus _mapBleAdapterState(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return BleStatus.unknown;
      case BluetoothAdapterState.unavailable:
        return BleStatus.unavailable;
      case BluetoothAdapterState.unauthorized:
        return BleStatus.unauthorized;
      case BluetoothAdapterState.turningOn:
        return BleStatus.turningOn;
      case BluetoothAdapterState.on:
        return BleStatus.on;
      case BluetoothAdapterState.turningOff:
        return BleStatus.turningOff;
      case BluetoothAdapterState.off:
        return BleStatus.off;
    }
  }

  /// Toggle debug mode
  void toggleDebugMode(bool debug) {
    _isDebugMode = debug;

    if (debug) {
      _stopCharacteristicListener();
      _startMockDataGeneration();
      _statusMessage = 'Debug Mode: Mock Data Active';
      debugPrint('[Debug] Mock data enabled');
    } else {
      _mockTimer?.cancel();
      _mockTimer = null;
      _statusMessage = 'Live BLE Mode: Scan for devices';
      debugPrint('[Debug] Live BLE mode enabled');
    }

    notifyListeners();
  }

  /// Enhanced scan for ESP32 devices with better filtering
  Future<void> scanForDevices() async {
    if (_isScanning) {
      _statusMessage = 'Already scanning...';
      notifyListeners();
      return;
    }

    try {
      _isScanning = true;
      _discoveredDevices.clear();
      _deviceSignalStrengths.clear();
      _statusMessage = 'Scanning for KrishiDrishti Sensor...';
      notifyListeners();

      if (!(await FlutterBluePlus.isSupported)) {
        _statusMessage = 'BLE not supported on this device';
        _isScanning = false;
        notifyListeners();
        return;
      }

      // Check if Bluetooth is on
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        _statusMessage = 'Please enable Bluetooth first';
        _isScanning = false;
        notifyListeners();
        return;
      }

      await FlutterBluePlus.startScan(
        timeout: SCAN_TIMEOUT,
        allowDuplicates: false,
      );

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (var result in results) {
            final device = result.device;
            final name = device.platformName.isEmpty
                ? device.remoteId.toString()
                : device.platformName;

            // Enhanced filtering for KrishiDrishti devices
            if (_isKrishiDrishtiDevice(name, device)) {
              if (!_discoveredDevices.any((d) => d.remoteId == device.remoteId)) {
                _discoveredDevices.add(device);
                _deviceSignalStrengths[device.remoteId.toString()] =
                    result.rssi;
                debugPrint(
                    '[BLE] Found: $name (RSSI: ${result.rssi}dBm)');
              } else {
                // Update signal strength for already discovered device
                _deviceSignalStrengths[device.remoteId.toString()] =
                    result.rssi;
              }
              _statusMessage =
                  'Found ${_discoveredDevices.length} device(s)...';
              notifyListeners();
            }
          }
        },
      );

      // Wait for scan to complete
      await Future.delayed(SCAN_TIMEOUT);
      await FlutterBluePlus.stopScan();

      _isScanning = false;
      if (_discoveredDevices.isEmpty) {
        _statusMessage =
            'No KrishiDrishti devices found. Ensure sensor is powered on and advertising.';
      } else {
        _statusMessage =
            'Scan complete. Found ${_discoveredDevices.length} device(s).';
      }
      debugPrint('[BLE] $_statusMessage');
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Scan Error: $e';
      _isScanning = false;
      debugPrint('[Error] $_statusMessage');
      notifyListeners();
    }
  }

  /// Check if device is a KrishiDrishti sensor
  bool _isKrishiDrishtiDevice(String name, BluetoothDevice device) {
    final nameLower = name.toLowerCase();

    // Primary check: device name
    if (nameLower.contains(TARGET_DEVICE_NAME.toLowerCase())) {
      return true;
    }

    // Fallback checks
    if (nameLower.contains(FALLBACK_DEVICE_NAME.toLowerCase())) {
      return true;
    }

    // Generic ESP32 checks
    if (nameLower.contains('esp32') ||
        nameLower.contains('esp-32') ||
        nameLower.contains('sensor')) {
      return true;
    }

    // By RSSI: If device is relatively close (> -80dBm), it's likely our sensor
    final rssi = _deviceSignalStrengths[device.remoteId.toString()] ?? -100;
    if (rssi > -80 && (nameLower.contains('device') || name.startsWith('Unknown'))) {
      return true; // Give unknown devices nearby a chance
    }

    return false;
  }

  /// Connect to a discovered BLE device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _statusMessage = 'Connecting to ${device.platformName}...';
      notifyListeners();

      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _statusMessage = 'Connected. Discovering services...';
      notifyListeners();

      // Discover services
      final services = await device.discoverServices();

      // Find characteristic that notifies
      bool found = false;
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.notify || char.properties.read) {
            _sensorCharacteristic = char;
            await _listenToCharacteristic(char);
            found = true;
            break;
          }
        }
        if (found) break;
      }

      if (!found) {
        _statusMessage =
            'Warning: No suitable characteristic found. Manual configuration may be needed.';
      } else {
        _statusMessage =
            'Connected and listening for sensor data...';
      }

      debugPrint('[BLE] $_statusMessage');
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Connection Error: $e';
      debugPrint('[Error] $_statusMessage');
      notifyListeners();
    }
  }

  /// Listen to sensor characteristic updates
  Future<void> _listenToCharacteristic(BluetoothCharacteristic characteristic) async {
    try {
      _characteristicSubscription?.cancel();

      // Set notify if supported
      if (characteristic.properties.notify) {
        try {
          await characteristic.setNotifyValue(true);
        } catch (e) {
          debugPrint('[BLE] Could not enable notify: $e');
        }
      }

      _characteristicSubscription = characteristic.onValueReceived.listen(
        (data) {
          _parseAndUpdateSensorData(data);
        },
        onError: (error) {
          _statusMessage = 'Listener error: $error';
          debugPrint('[Error] $_statusMessage');
        },
      );

      debugPrint('[BLE] Listening to characteristic');
    } catch (e) {
      _statusMessage = 'Listener setup error: $e';
      debugPrint('[Error] $_statusMessage');
    }
  }

  /// Parse JSON payload from ESP32 and update sensor data
  void _parseAndUpdateSensorData(List<int> data) {
    try {
      final jsonString = String.fromCharCodes(data);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final rssi = _deviceSignalStrengths[_connectedDevice?.remoteId.toString()] ??
          -100;

      _currentData = SensorData.fromJson({...json, 'signal': rssi});
      _dataHistory.add(_currentData!);

      // Maintain history limit
      if (_dataHistory.length > HISTORY_LIMIT) {
        _dataHistory.removeAt(0);
      }

      _statusMessage =
          'Data: ${_currentData.toString()}';
      debugPrint('[Data] $_statusMessage');
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Parse Error: $e';
      debugPrint('[Error] $_statusMessage');
      notifyListeners();
    }
  }

  /// Disconnect from device
  Future<void> disconnectDevice() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _stopCharacteristicListener();
        _connectedDevice = null;
        _sensorCharacteristic = null;
        _statusMessage = 'Disconnected';
        debugPrint('[BLE] $_statusMessage');
        notifyListeners();
      }
    } catch (e) {
      _statusMessage = 'Disconnect Error: $e';
      debugPrint('[Error] $_statusMessage');
      notifyListeners();
    }
  }

  /// Stop listening to characteristic
  void _stopCharacteristicListener() {
    try {
      _characteristicSubscription?.cancel();
      if (_sensorCharacteristic != null && _sensorCharacteristic!.properties.notify) {
        _sensorCharacteristic!.setNotifyValue(false);
      }
    } catch (e) {
      debugPrint('[Warning] Could not stop listener cleanly: $e');
    }
  }

  /// Generate realistic mock sensor data
  void _startMockDataGeneration() {
    _mockTimer?.cancel();

    double mockMoisture = 35.0;
    double mockPH = 6.5;
    double mockTemp = 28.0;

    _mockTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Add realistic sine wave fluctuation
      final elapsed = DateTime.now().millisecondsSinceEpoch.toDouble();

      mockMoisture = 35.0 + 15.0 * sin(elapsed / 5000);
      mockMoisture = mockMoisture.clamp(20.0, 50.0);

      mockPH = 6.5 + 0.5 * sin(elapsed / 7000);
      mockPH = mockPH.clamp(6.0, 7.5);

      mockTemp = 28.0 + 4.0 * sin(elapsed / 6000);
      mockTemp = mockTemp.clamp(24.0, 35.0);

      _currentData = SensorData(
        moisture: double.parse(mockMoisture.toStringAsFixed(1)),
        ph: double.parse(mockPH.toStringAsFixed(1)),
        temperature: double.parse(mockTemp.toStringAsFixed(1)),
        signalStrength: -50, // Strong mock signal
      );

      _dataHistory.add(_currentData!);
      if (_dataHistory.length > HISTORY_LIMIT) {
        _dataHistory.removeAt(0);
      }

      notifyListeners();
    });

    debugPrint('[Mock] Data generation started');
  }

  /// Clear sensor history
  void clearHistory() {
    _dataHistory.clear();
    debugPrint('[Sensor] History cleared');
    notifyListeners();
  }

  /// Get average sensor values from history
  Map<String, double> getAverageValues(int lastReadings) {
    if (_dataHistory.isEmpty) {
      return {'moisture': 0, 'ph': 0, 'temperature': 0};
    }

    final readings = _dataHistory.skip(_dataHistory.length - lastReadings);
    double avgMoisture = 0;
    double avgPh = 0;
    double avgTemp = 0;

    for (var reading in readings) {
      avgMoisture += reading.moisture;
      avgPh += reading.ph;
      avgTemp += reading.temperature;
    }

    final count = readings.length;
    return {
      'moisture': avgMoisture / count,
      'ph': avgPh / count,
      'temperature': avgTemp / count,
    };
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _bleStatusSubscription?.cancel();
    _scanSubscription?.cancel();
    _characteristicSubscription?.cancel();
    try {
      _connectedDevice?.disconnect();
    } catch (e) {
      debugPrint('[Warning] Error disconnecting during dispose: $e');
    }
    super.dispose();
  }
}
