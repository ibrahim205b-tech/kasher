
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/database_helper.dart';
import '../../../pos/presentation/providers/menu_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../../services/printer_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  List<BluetoothInfo> bluetoothDevices = [];
  BluetoothInfo? selectedBluetoothDevice;
  bool isScanningPrinters = false;

  @override
  void initState() {
    super.initState();
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    final saved = await PrinterService.instance.loadSavedDevice();
    if (saved != null && mounted) {
      setState(() => selectedBluetoothDevice = saved);
    }
    await _scanPrinters();
  }

  Future<void> _scanPrinters() async {
    if (!mounted) return;

    setState(() => isScanningPrinters = true);

    try {
      final isBtOn =
          await PrinterService.instance.isBluetoothEnabled();

      if (!isBtOn && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى تفعيل البلوتوث في الجهاز أولاً.',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
      }

      final devices =
          await PrinterService.instance.getBondedDevices();

      if (!mounted) return;

      setState(() {
        bluetoothDevices = devices;
        isScanningPrinters = false;

        if (devices.isNotEmpty) {
          final savedMac = selectedBluetoothDevice?.macAdress;

          selectedBluetoothDevice = devices.firstWhere(
            (device) => device.macAdress == savedMac,
            orElse: () => devices.first,
          );
        } else {
          selectedBluetoothDevice = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isScanningPrinters = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحميل الطابعات المقترنة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPrinterResult({
    required bool success,
    required String fallbackMessage,
  }) {
    if (!mounted) return;

    final error = PrinterService.instance.lastError;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? fallbackMessage
              : (error.isNotEmpty ? error : fallbackMessage),
        ),
        backgroundColor:
            success ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _connectPrinter() async {
    final device = selectedBluetoothDevice;

    if (device == null) {
      _showPrinterResult(
        success: false,
        fallbackMessage: 'اختر طابعة من قائمة الأجهزة المقترنة أولاً.',
      );
      return;
    }

    final connected =
        await PrinterService.instance.connect(device);

    _showPrinterResult(
      success: connected,
      fallbackMessage: connected
          ? 'تم الاتصال بالطابعة بنجاح.'
          : 'فشل الاتصال بالطابعة.',
    );
  }

  Future<void> _testPrinter(restaurantInfo) async {
    final ok = await PrinterService.instance
        .printTestReceipt(restaurantInfo);

    _showPrinterResult(
      success: ok,
      fallbackMessage: ok
          ? 'تم إرسال أمر اختبار الطباعة.'
          : 'فشل اختبار الطباعة.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;

    final nameCtrl =
        TextEditingController(text: restaurantInfo.name);
    final addressCtrl =
        TextEditingController(text: restaurantInfo.address);
    final phoneCtrl =
        TextEditingController(text: restaurantInfo.phone);
    final currencyCtrl =
        TextEditingController(text: restaurantInfo.currency);
    final footerCtrl =
        TextEditingController(text: restaurantInfo.invoiceFooter);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('الإعدادات والهوية البصرية والطابعة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'اللون المميز (Accent Color)',
              subtitle:
                  'اختر اللون الذي يزين الأزرار والعناصر النشطة.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppAccentColor.values.map((accent) {
                final isSelected =
                    themeState.accentColor == accent;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(themeSettingsProvider.notifier)
                        .setAccentColor(accent);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accent.lightBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? accent.color
                            : AppColors.borderLight,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: accent.color,
                          radius: 20,
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          accent.nameArabic,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionHeader(
              title: 'إعدادات الطابعة الحرارية',
              subtitle:
                  'ربط طابعة البلوتوث واختبار الطباعة الفورية.',
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppColors.borderLight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (bluetoothDevices.isEmpty) ...[
                      const Text(
                        'اقرن الطابعة من إعدادات البلوتوث في الجهاز، '
                        'ثم اضغط زر التحديث.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child:
                              DropdownButtonFormField<BluetoothInfo>(
                            value: selectedBluetoothDevice,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'الأجهزة المقترنة',
                              border: OutlineInputBorder(),
                            ),
                            items: bluetoothDevices.map((device) {
                              return DropdownMenuItem<BluetoothInfo>(
                                value: device,
                                child: Text(
                                  '${device.name} (${device.macAdress})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedBluetoothDevice = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'تحديث الطابعات',
                          onPressed: isScanningPrinters
                              ? null
                              : _scanPrinters,
                          icon: isScanningPrinters
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'حجم الورق:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('58mm'),
                          selected:
                              restaurantInfo.paperWidth == '58mm',
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color:
                                restaurantInfo.paperWidth == '58mm'
                                    ? Colors.white
                                    : AppColors.textDark,
                          ),
                          onSelected: (value) {
                            if (value) {
                              ref
                                  .read(restaurantInfoProvider.notifier)
                                  .updateInfo(
                                    restaurantInfo.copyWith(
                                      paperWidth: '58mm',
                                    ),
                                  );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('56mm'),
                          selected:
                              restaurantInfo.paperWidth == '56mm',
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color:
                                restaurantInfo.paperWidth == '56mm'
                                    ? Colors.white
                                    : AppColors.textDark,
                          ),
                          onSelected: (value) {
                            if (value) {
                              ref
                                  .read(restaurantInfoProvider.notifier)
                                  .updateInfo(
                                    restaurantInfo.copyWith(
                                      paperWidth: '56mm',
                                    ),
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          icon: const Icon(
                            Icons.bluetooth_connected_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'الاتصال وحفظ إعدادات الطابعة',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _connectPrinter,
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.print_rounded),
                          label: const Text('اختبار الطباعة'),
                          onPressed: () =>
                              _testPrinter(restaurantInfo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionHeader(
              title: 'بيانات المطعم وتخصيص الفاتورة',
              subtitle:
                  'عدّل البيانات التي تظهر على الفاتورة المطبوعة.',
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppColors.borderLight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم المطعم',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: currencyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'العملة المستخدمة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: footerCtrl,
                      decoration: const InputDecoration(
                        labelText: 'رسالة أسفل الفاتورة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('إظهار العنوان في الفاتورة'),
                      value: restaurantInfo.showAddress,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        ref
                            .read(restaurantInfoProvider.notifier)
                            .updateInfo(
                              restaurantInfo.copyWith(
                                showAddress: value,
                              ),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text(
                        'إظهار رقم الهاتف في الفاتورة',
                      ),
                      value: restaurantInfo.showPhone,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        ref
                            .read(restaurantInfoProvider.notifier)
                            .updateInfo(
                              restaurantInfo.copyWith(
                                showPhone: value,
                              ),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text(
                        'إظهار رسالة التذييل أسفل الفاتورة',
                      ),
                      value: restaurantInfo.showFooter,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        ref
                            .read(restaurantInfoProvider.notifier)
                            .updateInfo(
                              restaurantInfo.copyWith(
                                showFooter: value,
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () async {
                          final updated = restaurantInfo.copyWith(
                            name: nameCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            currency: currencyCtrl.text.trim(),
                            invoiceFooter: footerCtrl.text.trim(),
                          );

                          await ref
                              .read(restaurantInfoProvider.notifier)
                              .updateInfo(updated);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تم حفظ بيانات المطعم والفاتورة بنجاح.',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'حفظ بيانات المطعم والفاتورة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionHeader(
              title: 'إدارة قاعدة البيانات',
              subtitle:
                  'إعادة تحميل البيانات التجريبية أو مسح قاعدة البيانات.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('إعادة تحميل البيانات التجريبية'),
                  onPressed: () async {
                    await DatabaseHelper.instance.reloadDemoData();
                    await ref
                        .read(menuNotifierProvider.notifier)
                        .loadMenu();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم استعادة البيانات التجريبية بنجاح.',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('مسح جميع البيانات'),
                  onPressed: () async {
                    await DatabaseHelper.instance.clearAllData();
                    await ref
                        .read(menuNotifierProvider.notifier)
                        .loadMenu();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم مسح جميع البيانات.'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
