
import 'dart:async';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../invoices/data/models/invoice.dart';
import '../data/models/restaurant_info.dart';
import '../../employees/data/models/employee.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class PrinterService {
  static final PrinterService instance = PrinterService._internal();

  BluetoothInfo? _selectedDevice;

  static const String _prefMacKey = 'saved_printer_mac';
  static const String _prefNameKey = 'saved_printer_name';

  Future<bool>? _connecting;

  PrinterService._internal();

  BluetoothInfo? get selectedDevice => _selectedDevice;

  String _errorMessage = '';

  String get lastError => _errorMessage;

  void _setError(
    String message, [
    Object? error,
    StackTrace? stack,
  ]) {
    _errorMessage = message;
    debugPrint('[PrinterService] $message');

    if (error != null) {
      debugPrint('[PrinterService] Details: $error');
    }

    if (stack != null) {
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final granted =
          await PrintBluetoothThermal.isPermissionBluetoothGranted;

      if (granted) return true;

      final statuses = await <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetooth,
      ].request();

      final connectStatus = statuses[Permission.bluetoothConnect];

      if (connectStatus?.isPermanentlyDenied == true ||
          connectStatus?.isRestricted == true) {
        _setError(
          'صلاحية البلوتوث مرفوضة. افتح إعدادات التطبيق '
          'وفعّل صلاحية الأجهزة القريبة.',
        );
        return false;
      }

      final permissionGranted =
          await PrintBluetoothThermal.isPermissionBluetoothGranted;

      if (!permissionGranted) {
        _setError(
          'صلاحية البلوتوث غير ممنوحة. '
          'اسمح للتطبيق بالوصول إلى الأجهزة القريبة.',
        );
        return false;
      }

      return true;
    } catch (e, st) {
      _setError('تعذر فحص صلاحيات البلوتوث: $e', e, st);
      return false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e, st) {
      _setError('تعذر فحص حالة البلوتوث: $e', e, st);
      return false;
    }
  }

  Future<BluetoothInfo?> loadSavedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mac = prefs.getString(_prefMacKey);
      final name = prefs.getString(_prefNameKey);

      if (mac == null || mac.trim().isEmpty) {
        _selectedDevice = null;
        return null;
      }

      _selectedDevice = BluetoothInfo(
        name: name == null || name.trim().isEmpty
            ? 'الطابعة المحفوظة'
            : name,
        macAdress: mac.trim(),
      );

      return _selectedDevice;
    } catch (e, st) {
      _setError('تعذر تحميل الطابعة المحفوظة: $e', e, st);
      return null;
    }
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    _errorMessage = '';

    if (!await requestPermissions()) {
      return <BluetoothInfo>[];
    }

    if (!await isBluetoothEnabled()) {
      _setError('البلوتوث مطفأ. شغّله ثم أعد المحاولة.');
      return <BluetoothInfo>[];
    }

    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;

      debugPrint(
        '[PrinterService] Paired devices: ${devices.length}',
      );

      return devices;
    } catch (e, st) {
      _setError('تعذر قراءة الطابعات المقترنة: $e', e, st);
      return <BluetoothInfo>[];
    }
  }

  Future<bool> connect(BluetoothInfo device) {
    final active = _connecting;

    if (active != null) {
      return active;
    }

    final future = _connectInternal(device);
    _connecting = future;

    return future.whenComplete(() {
      _connecting = null;
    });
  }

  Future<bool> _connectInternal(BluetoothInfo device) async {
    _errorMessage = '';

    if (!await requestPermissions()) {
      return false;
    }

    final mac = device.macAdress.trim();

    if (mac.isEmpty) {
      _setError(
        'عنوان الطابعة فارغ. اختر الطابعة من الأجهزة المقترنة.',
      );
      return false;
    }

    if (!await isBluetoothEnabled()) {
      _setError('البلوتوث مطفأ. شغّله ثم حاول الاتصال.');
      return false;
    }

    try {
      debugPrint(
        '[PrinterService] Connecting to ${device.name}, MAC: $mac',
      );

      var connected = await PrintBluetoothThermal.connectionStatus;

      if (!connected) {
        connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: mac,
        );

        debugPrint(
          '[PrinterService] Connect result: $connected',
        );
      }

      if (!connected) {
        _setError(
          'تعذر إنشاء اتصال بالطابعة ${device.name}. '
          'تأكد من الاقتران وأغلق أي تطبيق آخر يستخدم الطابعة.',
        );
        return false;
      }

      final verified =
          await PrintBluetoothThermal.connectionStatus;

      if (!verified) {
        _setError(
          'أعادت المكتبة نجاح الاتصال، لكن فحص الاتصال اللاحق فشل.',
        );
        return false;
      }

      _selectedDevice = device;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefMacKey, mac);
      await prefs.setString(_prefNameKey, device.name);

      _errorMessage = '';

      debugPrint(
        '[PrinterService] Connection verified and device saved.',
      );

      return true;
    } catch (e, st) {
      _setError('حدث خطأ أثناء الاتصال بالطابعة: $e', e, st);
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      debugPrint('[PrinterService] Disconnected.');
    } catch (e, st) {
      _setError('تعذر فصل اتصال الطابعة: $e', e, st);
    }
  }

  Future<bool> _ensureConnected() async {
    if (_selectedDevice == null) {
      await loadSavedDevice();
    }

    final device = _selectedDevice;

    if (device == null) {
      _setError(
        'لم تُحدَّد طابعة محفوظة. افتح إعدادات الطابعة '
        'واختر Printer001 ثم اضغط الاتصال وحفظ الإعدادات.',
      );
      return false;
    }

    if (!await requestPermissions()) {
      return false;
    }

    if (!await isBluetoothEnabled()) {
      _setError('البلوتوث مطفأ. شغّله ثم أعد الطباعة.');
      return false;
    }

    try {
      final connected =
          await PrintBluetoothThermal.connectionStatus;

      if (connected) {
        return true;
      }
    } catch (e, st) {
      debugPrint(
        '[PrinterService] Connection status check failed: $e',
      );
    }

    debugPrint(
      '[PrinterService] Connection lost; reconnecting before print.',
    );

    return connect(device);
  }

  Future<bool> _writeReceipt(List<int> bytes) async {
    if (bytes.isEmpty) {
      _setError('بيانات الطباعة فارغة؛ لا يوجد شيء لإرساله.');
      return false;
    }

    if (!await _ensureConnected()) {
      if (_errorMessage.isEmpty) {
        _setError('تعذر الاتصال بالطابعة قبل إرسال البيانات.');
      }
      return false;
    }

    try {
      final result = await PrintBluetoothThermal.writeBytes(bytes);

      if (!result) {
        _setError(
          'الاتصال بالطابعة موجود، لكن المكتبة لم تؤكد إرسال '
          'البيانات. تحقق من تشغيل الطابعة والورق ثم أعد المحاولة.',
        );
        return false;
      }

      _errorMessage = '';

      debugPrint(
        '[PrinterService] Print data sent successfully '
        '(${bytes.length} bytes).',
      );

      return true;
    } catch (e, st) {
      _setError('فشل إرسال بيانات الطباعة: $e', e, st);
      return false;
    }
  }

  Future<bool> printInvoice({
    required Invoice invoice,
    required RestaurantInfo info,
  }) async {
    try {
      debugPrint('[PrinterService] Preparing invoice for printing.');

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final List<int> bytes = <int>[];

      bytes.addAll(
        generator.text(
          info.name,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      );

      if (info.showAddress && info.address.isNotEmpty) {
        bytes.addAll(
          generator.text(
            info.address,
            styles: const PosStyles(
              align: PosAlign.center,
            ),
          ),
        );
      }

      if (info.showPhone && info.phone.isNotEmpty) {
        bytes.addAll(
          generator.text(
            'Phone: ${info.phone}',
            styles: const PosStyles(
              align: PosAlign.center,
            ),
          ),
        );
      }

      bytes.addAll(
        generator.text(
          'Date: ${DateFormatter.formatDateTime(invoice.createdAt)}',
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
      );

      bytes.addAll(
        generator.text(
          'Invoice: ${invoice.invoiceNumber}',
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ),
      );

      bytes.addAll(generator.hr());

      bytes.addAll(
        generator.row(<PosColumn>[
          PosColumn(
            text: 'Item',
            width: 6,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: 'Qty',
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
            ),
          ),
          PosColumn(
            text: 'Total',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
              bold: true,
            ),
          ),
        ]),
      );

      bytes.addAll(generator.hr());

      var totalItemsCount = 0;

      for (final item in invoice.items) {
        totalItemsCount += item.quantity;

        var lineName = item.itemName;

        if (item.sizeName != null) {
          lineName += ' (${item.sizeName})';
        }

        if (item.flavorName != null) {
          lineName += ' - ${item.flavorName}';
        }

        bytes.addAll(
          generator.row(<PosColumn>[
            PosColumn(
              text: lineName,
              width: 6,
            ),
            PosColumn(
              text: '${item.quantity}',
              width: 2,
              styles: const PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: CurrencyFormatter.format(
                item.lineTotal,
                currency: info.currency,
              ),
              width: 4,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
          ]),
        );

        if (item.extrasText != null &&
            item.extrasText!.isNotEmpty) {
          bytes.addAll(
            generator.text(
              '  * ${item.extrasText}',
              styles: const PosStyles(
                fontType: PosFontType.fontB,
              ),
            ),
          );
        }
      }

      bytes.addAll(generator.hr());

      bytes.addAll(
        generator.row(<PosColumn>[
          PosColumn(
            text: 'Item count:',
            width: 6,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: '$totalItemsCount',
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
              bold: true,
            ),
          ),
        ]),
      );

      if (invoice.discount > 0) {
        bytes.addAll(
          generator.row(<PosColumn>[
            PosColumn(
              text: 'Discount:',
              width: 6,
            ),
            PosColumn(
              text: '-${CurrencyFormatter.format(invoice.discount, currency: info.currency)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
          ]),
        );
      }

      bytes.addAll(
        generator.row(<PosColumn>[
          PosColumn(
            text: 'Grand total:',
            width: 6,
            styles: const PosStyles(
              bold: true,
              height: PosTextSize.size2,
            ),
          ),
          PosColumn(
            text: CurrencyFormatter.format(
              invoice.grandTotal,
              currency: info.currency,
            ),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size2,
            ),
          ),
        ]),
      );

      bytes.addAll(generator.hr());

      if (info.showFooter && info.invoiceFooter.isNotEmpty) {
        bytes.addAll(
          generator.text(
            info.invoiceFooter,
            styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
            ),
          ),
        );
      }

      bytes.addAll(generator.feed(3));

      debugPrint(
        '[PrinterService] Invoice prepared: ${bytes.length} bytes.',
      );

      return _writeReceipt(bytes);
    } catch (e, st) {
      _setError('تعذر تجهيز الفاتورة للطباعة: $e', e, st);
      return false;
    }
  }

  Future<bool> printTestReceipt(RestaurantInfo info) async {
    try {
      _errorMessage = '';

      final bytes = <int>[
        0x1B, 0x40,
        0x1B, 0x61, 0x01,
        ...'AL HAJJI RESTAURANT\n'.codeUnits,
        ...'PRINTER TEST\n'.codeUnits,
        ...'--------------------------\n'.codeUnits,
        ...'Bluetooth test: 1234567890\n'.codeUnits,
        ...'Paper width: 58mm\n'.codeUnits,
        0x0A,
        0x0A,
        0x0A,
        0x1B, 0x61, 0x00,
      ];

      debugPrint('[PrinterService] Starting raw printer test.');

      return await _writeReceipt(bytes);
    } catch (e, st) {
      _setError('فشل اختبار الطباعة: $e', e, st);
      return false;
    }
  }

  Future<bool> printSalarySlip({
    required Employee employee,
    required RestaurantInfo info,
  }) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final List<int> bytes = <int>[];

      bytes.addAll(
        generator.text(
          info.name,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      );

      bytes.addAll(
        generator.text(
          'Salary Payment Receipt',
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ),
      );

      bytes.addAll(
        generator.text(
          'Date: ${DateFormatter.formatDateTime(DateTime.now())}',
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
      );

      bytes.addAll(generator.hr());
      bytes.addAll(generator.text('Employee: ${employee.name}'));
      bytes.addAll(generator.text('Role: ${employee.role}'));
      bytes.addAll(
        generator.text(
          'Salary type: ${employee.payType.nameArabic}',
        ),
      );

      bytes.addAll(
        generator.text(
          'Paid amount: ${CurrencyFormatter.format(employee.salary, currency: info.currency)}',
          styles: const PosStyles(bold: true),
        ),
      );

      bytes.addAll(generator.hr());
      bytes.addAll(
        generator.text('Recipient signature: ....................'),
      );
      bytes.addAll(generator.feed(3));

      return _writeReceipt(bytes);
    } catch (e, st) {
      _setError('تعذر تجهيز كشف الراتب للطباعة: $e', e, st);
      return false;
    }
  }
}
