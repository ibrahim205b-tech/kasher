
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

  void _setError(String message, [Object? error, StackTrace? stack]) {
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
      // تحقق من صلاحية البلوتوث بالطريقة التي توفرها المكتبة.
      final pluginPermission =
          await PrintBluetoothThermal.isPermissionBluetoothGranted;

      if (!pluginPermission) {
        // اطلب الصلاحيات المناسبة لإصدار أندرويد.
        final statuses = await <Permission>[
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetooth,
        ].request();

        final connectStatus = statuses[Permission.bluetoothConnect];
        final legacyStatus = statuses[Permission.bluetooth];

        if (connectStatus?.isPermanentlyDenied == true ||
            connectStatus?.isRestricted == true ||
            legacyStatus?.isPermanentlyDenied == true) {
          _setError(
            'صلاحية البلوتوث مرفوضة نهائياً. '
            'افتح إعدادات التطبيق وفعّل صلاحية الأجهزة القريبة.',
          );
          return false;
        }

        // أعد الفحص بعد طلب الصلاحيات.
        final permissionGranted =
            await PrintBluetoothThermal.isPermissionBluetoothGranted;

        if (!permissionGranted) {
          _setError(
            'صلاحية البلوتوث غير ممنوحة. '
            'افتح إعدادات التطبيق واسمح للأجهزة القريبة.',
          );
          return false;
        }
      }

      return true;
    } catch (e, st) {
      _setError('تعذر فحص صلاحيات البلوتوث', e, st);
      return false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e, st) {
      _setError('تعذر فحص حالة البلوتوث', e, st);
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
        name: (name == null || name.trim().isEmpty)
            ? 'الطابعة المحفوظة'
            : name,
        macAdress: mac.trim(),
      );

      return _selectedDevice;
    } catch (e, st) {
      _setError('تعذر تحميل الطابعة المحفوظة', e, st);
      return null;
    }
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    _errorMessage = '';

    if (!await requestPermissions()) {
      return <BluetoothInfo>[];
    }

    if (!await isBluetoothEnabled()) {
      _setError('البلوتوث مطفأ. شغّله من إعدادات الهاتف ثم أعد المحاولة.');
      return <BluetoothInfo>[];
    }

    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      debugPrint('[PrinterService] Paired devices: ${devices.length}');
      return devices;
    } catch (e, st) {
      _setError('تعذر قراءة الطابعات المقترنة', e, st);
      return <BluetoothInfo>[];
    }
  }

  Future<bool> connect(BluetoothInfo device) {
    final active = _connecting;
    if (active != null) return active;

    final future = _connectInternal(device);
    _connecting = future;

    return future.whenComplete(() {
      _connecting = null;
    });
  }

  Future<bool> _connectInternal(BluetoothInfo device) async {
    _errorMessage = '';

    if (!await requestPermissions()) return false;

    final mac = device.macAdress.trim();

    if (mac.isEmpty) {
      _setError('عنوان الطابعة فارغ. اختر الطابعة من قائمة الأجهزة المقترنة.');
      return false;
    }

    if (!await isBluetoothEnabled()) {
      _setError('البلوتوث مطفأ. شغّله ثم حاول الاتصال بالطابعة.');
      return false;
    }

    try {
      debugPrint(
        '[PrinterService] Connecting to ${device.name}, address: $mac',
      );

      final alreadyConnected =
          await PrintBluetoothThermal.connectionStatus;

      if (!alreadyConnected) {
        final connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: mac,
        );

        debugPrint('[PrinterService] Connect result: $connected');

        if (!connected) {
          _setError(
            'فشل اتصال المكتبة بالطابعة ${device.name}. '
            'تحقق من اقترانها، وأغلق أي تطبيق آخر يستخدم الطابعة، '
            'ثم أعد المحاولة.',
          );
          return false;
        }
      }

      final verified = await PrintBluetoothThermal.connectionStatus;

      if (!verified) {
        _setError(
          'لم يتم تأكيد الاتصال بالطابعة بعد محاولة الاتصال. أعد المحاولة.',
        );
        return false;
      }

      _selectedDevice = device;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefMacKey, mac);
      await prefs.setString(_prefNameKey, device.name);

      _errorMessage = '';
      debugPrint('[PrinterService] Connection verified and device saved.');
      return true;
    } catch (e, st) {
      _setError('حدث استثناء أثناء الاتصال بالطابعة: $e', e, st);
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      debugPrint('[PrinterService] Disconnected.');
    } catch (e, st) {
      _setError('تعذر فصل اتصال الطابعة', e, st);
    }
  }

  Future<bool> _ensureConnected() async {
    if (_selectedDevice == null) {
      await loadSavedDevice();
    }

    if (_selectedDevice == null) {
      _setError(
        'لم تُحدَّد طابعة بعد. افتح إعدادات الطابعة واختر جهازاً مقترناً.',
      );
      return false;
    }

    if (!await requestPermissions()) return false;

    if (!await isBluetoothEnabled()) {
      _setError('البلوتوث مطفأ. شغّله ثم أعد الطباعة.');
      return false;
    }

    try {
      if (await PrintBluetoothThermal.connectionStatus) {
        return true;
      }
    } catch (e, st) {
      _setError('تعذر التحقق من اتصال الطابعة', e, st);
      return false;
    }

    return connect(_selectedDevice!);
  }

  Future<bool> _writeReceipt(List<int> bytes) async {
    if (bytes.isEmpty) {
      _setError('لا توجد بيانات لإرسالها إلى الطابعة.');
      return false;
    }

    if (!await _ensureConnected()) return false;

    try {
      final result = await PrintBluetoothThermal.writeBytes(bytes);

      if (!result) {
        _setError(
          'الاتصال موجود لكن المكتبة لم تؤكد إرسال بيانات الطباعة. '
          'تحقق من الورق والطابعة ثم أعد المحاولة.',
        );
        return false;
      }

      _errorMessage = '';
      debugPrint('[PrinterService] Print data sent successfully.');
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
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final List<int> bytes = <int>[];

      bytes.addAll(generator.text(
        info.name,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ));

      if (info.showAddress && info.address.isNotEmpty) {
        bytes.addAll(generator.text(
          info.address,
          styles: const PosStyles(align: PosAlign.center),
        ));
      }

      if (info.showPhone && info.phone.isNotEmpty) {
        bytes.addAll(generator.text(
          'تلفون: ${info.phone}',
          styles: const PosStyles(align: PosAlign.center),
        ));
      }

      bytes.addAll(generator.text(
        'تاريخ الطباعة: ${DateFormatter.formatDateTime(invoice.createdAt)}',
        styles: const PosStyles(align: PosAlign.center),
      ));

      bytes.addAll(generator.text(
        'رقم الفاتورة: ${invoice.invoiceNumber}',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ));

      bytes.addAll(generator.hr());

      bytes.addAll(generator.row(<PosColumn>[
        PosColumn(
          text: 'الصنف',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'العدد',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ),
        PosColumn(
          text: 'الإجمالي',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
          ),
        ),
      ]));

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

        bytes.addAll(generator.row(<PosColumn>[
          PosColumn(text: lineName, width: 6),
          PosColumn(
            text: '${item.quantity}',
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: CurrencyFormatter.format(
              item.lineTotal,
              currency: info.currency,
            ),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]));

        if (item.extrasText != null && item.extrasText!.isNotEmpty) {
          bytes.addAll(generator.text(
            '  * ${item.extrasText}',
            styles: const PosStyles(fontType: PosFontType.fontB),
          ));
        }
      }

      bytes.addAll(generator.hr());

      bytes.addAll(generator.row(<PosColumn>[
        PosColumn(
          text: 'عدد الأصناف:',
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
      ]));

      if (invoice.discount > 0) {
        bytes.addAll(generator.row(<PosColumn>[
          PosColumn(text: 'الخصم:', width: 6),
          PosColumn(
            text: '-${CurrencyFormatter.format(invoice.discount, currency: info.currency)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]));
      }

      bytes.addAll(generator.row(<PosColumn>[
        PosColumn(
          text: 'المجموع النهائي:',
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
      ]));

      bytes.addAll(generator.hr());

      if (info.showFooter && info.invoiceFooter.isNotEmpty) {
        bytes.addAll(generator.text(
          info.invoiceFooter,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ));
      }

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      return _writeReceipt(bytes);
    } catch (e, st) {
      _setError('تعذر تجهيز الفاتورة للطباعة', e, st);
      return false;
    }
  }

  Future<bool> printTestReceipt(RestaurantInfo info) async {
    final testInvoice = Invoice(
      id: 'test_id',
      invoiceNumber: '${info.invoicePrefix}0000',
      createdAt: DateTime.now(),
      subtotal: 10000.0,
      discount: 0.0,
      grandTotal: 10000.0,
      items: [],
    );

    return printInvoice(invoice: testInvoice, info: info);
  }

  Future<bool> printSalarySlip({
    required Employee employee,
    required RestaurantInfo info,
  }) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final List<int> bytes = <int>[];

      bytes.addAll(generator.text(
        info.name,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      ));

      bytes.addAll(generator.text(
        '*** كشف تسديد راتب ***',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ));

      bytes.addAll(generator.text(
        'التاريخ: ${DateFormatter.formatDateTime(DateTime.now())}',
        styles: const PosStyles(align: PosAlign.center),
      ));

      bytes.addAll(generator.hr());
      bytes.addAll(generator.text('اسم الموظف: ${employee.name}'));
      bytes.addAll(generator.text('الوظيفة: ${employee.role}'));
      bytes.addAll(generator.text('نوع الراتب: ${employee.payType.nameArabic}'));

      bytes.addAll(generator.text(
        'المبلغ المصروف: ${CurrencyFormatter.format(employee.salary, currency: info.currency)}',
        styles: const PosStyles(bold: true),
      ));

      bytes.addAll(generator.hr());
      bytes.addAll(generator.text('توقيع المستلم: ....................'));
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      return _writeReceipt(bytes);
    } catch (e, st) {
      _setError('تعذر تجهيز كشف الراتب للطباعة', e, st);
      return false;
    }
  }
}
