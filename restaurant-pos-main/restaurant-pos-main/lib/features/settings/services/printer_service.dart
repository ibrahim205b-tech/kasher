import 'dart:async';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
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

  PrinterService._internal();

  BluetoothInfo? get selectedDevice => _selectedDevice;

  /// Check and request Bluetooth & Location permissions
  Future<bool> requestPermissions() async {
    try {
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      // Check if critical permissions are granted
      final isGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? true;
      return isGranted;
    } catch (_) {
      return true;
    }
  }

  /// Check if Bluetooth is turned on
  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (_) {
      return false;
    }
  }

  /// Load saved device from SharedPreferences on launch
  Future<BluetoothInfo?> loadSavedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mac = prefs.getString(_prefMacKey);
      final name = prefs.getString(_prefNameKey);
      if (mac != null && mac.isNotEmpty) {
        _selectedDevice = BluetoothInfo(name: name ?? 'طابعة محفوطة', macAdress: mac);
        return _selectedDevice;
      }
    } catch (_) {}
    return null;
  }

  /// Get paired devices list with permission auto-request
  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      await requestPermissions();
      final bool btOn = await isBluetoothEnabled();
      if (!btOn) {
        return [];
      }
      final List<BluetoothInfo> devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      return [];
    }
  }

  /// Connect to selected device and save choice
  Future<bool> connect(BluetoothInfo device) async {
    try {
      await requestPermissions();
      final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: device.macAdress);
      if (result) {
        _selectedDevice = device;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefMacKey, device.macAdress);
        await prefs.setString(_prefNameKey, device.name);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (_) {}
  }

  /// Send ESC/POS formatted bytes to thermal printer
  Future<bool> printInvoice({
    required Invoice invoice,
    required RestaurantInfo info,
  }) async {
    if (_selectedDevice == null) {
      await loadSavedDevice();
    }

    final bool isConn = await PrintBluetoothThermal.connectionStatus;
    if (!isConn) {
      if (_selectedDevice != null) {
        final success = await connect(_selectedDevice!);
        if (!success) return false;
      } else {
        return false;
      }
    }

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = info.paperWidth == '56mm' ? PaperSize.mm58 : PaperSize.mm58;
      final generator = Generator(paperSize, profile);
      final List<int> bytes = [];

      // 1. Header
      bytes.addAll(generator.text(info.name, styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2)));
      
      if (info.showAddress && info.address.isNotEmpty) {
        bytes.addAll(generator.text(info.address, styles: const PosStyles(align: PosAlign.center)));
      }
      if (info.showPhone && info.phone.isNotEmpty) {
        bytes.addAll(generator.text('تلفون: ${info.phone}', styles: const PosStyles(align: PosAlign.center)));
      }

      bytes.addAll(generator.text('تاريخ الطباعة: ${DateFormatter.formatDateTime(invoice.createdAt)}', styles: const PosStyles(align: PosAlign.center)));
      bytes.addAll(generator.text('رقم الفاتورة: ${invoice.invoiceNumber}', styles: const PosStyles(align: PosAlign.center, bold: true)));
      bytes.addAll(generator.hr());

      // 2. Items Table
      bytes.addAll(generator.row([
        PosColumn(text: 'الصنف', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: 'العدد', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(text: 'الإجمالي', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]));
      bytes.addAll(generator.hr());

      int totalItemsCount = 0;
      for (final item in invoice.items) {
        totalItemsCount += item.quantity;
        String lineName = item.itemName;
        if (item.sizeName != null) lineName += ' (${item.sizeName})';
        if (item.flavorName != null) lineName += ' - ${item.flavorName}';

        bytes.addAll(generator.row([
          PosColumn(text: lineName, width: 6),
          PosColumn(text: '${item.quantity}', width: 2, styles: const PosStyles(align: PosAlign.center)),
          PosColumn(text: CurrencyFormatter.format(item.lineTotal, currency: info.currency), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]));

        if (item.extrasText != null && item.extrasText!.isNotEmpty) {
          bytes.addAll(generator.text('  * ${item.extrasText}', styles: const PosStyles(fontType: PosFontType.fontB)));
        }
      }

      bytes.addAll(generator.hr());
      // 3. Totals
      bytes.addAll(generator.row([
        PosColumn(text: 'عدد الأصناف:', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: '$totalItemsCount', width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]));

      if (invoice.discount > 0) {
        bytes.addAll(generator.row([
          PosColumn(text: 'الخصم:', width: 6),
          PosColumn(text: '-${CurrencyFormatter.format(invoice.discount, currency: info.currency)}', width: 6, styles: const PosStyles(align: PosAlign.right)),
        ]));
      }

      bytes.addAll(generator.row([
        PosColumn(text: 'المجموع النهائي:', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
        PosColumn(text: CurrencyFormatter.format(invoice.grandTotal, currency: info.currency), width: 6, styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size2)),
      ]));

      bytes.addAll(generator.hr());
      // 4. Footer Message
      if (info.showFooter && info.invoiceFooter.isNotEmpty) {
        bytes.addAll(generator.text(info.invoiceFooter, styles: const PosStyles(align: PosAlign.center, bold: true)));
      }

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      await PrintBluetoothThermal.writeBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Print Test Invoice
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
    return await printInvoice(invoice: testInvoice, info: info);
  }

  /// Print Employee Salary Pay Slip (كشف راتب موظف)
  Future<bool> printSalarySlip({
    required Employee employee,
    required RestaurantInfo info,
  }) async {
    if (_selectedDevice == null) {
      await loadSavedDevice();
    }

    final bool isConn = await PrintBluetoothThermal.connectionStatus;
    if (!isConn && _selectedDevice != null) {
      await connect(_selectedDevice!);
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final List<int> bytes = [];

      bytes.addAll(generator.text(info.name, styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2)));
      bytes.addAll(generator.text('*** كشف تسديد راتب ***', styles: const PosStyles(align: PosAlign.center, bold: true)));
      bytes.addAll(generator.text('التاريخ: ${DateFormatter.formatDateTime(DateTime.now())}', styles: const PosStyles(align: PosAlign.center)));
      bytes.addAll(generator.hr());
      bytes.addAll(generator.text('اسم الموظف: ${employee.name}'));
      bytes.addAll(generator.text('الوظيفة: ${employee.role}'));
      bytes.addAll(generator.text('نوع الراتب: ${employee.payType.nameArabic}'));
      bytes.addAll(generator.text('المبلغ المصروف: ${CurrencyFormatter.format(employee.salary, currency: info.currency)}', styles: const PosStyles(bold: true)));
      bytes.addAll(generator.hr());
      bytes.addAll(generator.text('توقيع المستلم: ....................'));
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      await PrintBluetoothThermal.writeBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }
}
