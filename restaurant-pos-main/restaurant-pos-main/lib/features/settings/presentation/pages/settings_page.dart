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
    if (saved != null) {
      setState(() => selectedBluetoothDevice = saved);
    }
    await _scanPrinters();
  }

  Future<void> _scanPrinters() async {
    setState(() => isScanningPrinters = true);
    final isBtOn = await PrinterService.instance.isBluetoothEnabled();
    if (!isBtOn && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى تفعيل البلوتوث في التابلت/الجهاز أولاً'),
          backgroundColor: AppColors.warning,
        ),
      );
    }

    final devices = await PrinterService.instance.getBondedDevices();
    setState(() {
      bluetoothDevices = devices;
      isScanningPrinters = false;
      if (devices.isNotEmpty) {
        // preserve saved device if it's in list, else pick first
        final savedMac = selectedBluetoothDevice?.macAdress;
        final match = devices.firstWhere(
          (d) => d.macAdress == savedMac,
          orElse: () => devices.first,
        );
        selectedBluetoothDevice = match;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeSettingsProvider);
    final restaurantInfo = ref.watch(restaurantInfoProvider);
    final primaryColor = themeState.accentColor.color;

    final nameCtrl = TextEditingController(text: restaurantInfo.name);
    final addressCtrl = TextEditingController(text: restaurantInfo.address);
    final phoneCtrl = TextEditingController(text: restaurantInfo.phone);
    final currencyCtrl = TextEditingController(text: restaurantInfo.currency);
    final footerCtrl = TextEditingController(text: restaurantInfo.invoiceFooter);

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
            // 1. Accent Color Selector
            _buildSectionHeader(
              title: 'اللون المميز (Accent Color)',
              subtitle: 'اختر اللون الذي يزين الأزرار والشريط السفلي والعناصر النشطة (مع بقاء الخلفية أبيض نقي)',
            ),
            const SizedBox(height: 12),
            Row(
              children: AppAccentColor.values.map((accent) {
                final isSelected = themeState.accentColor == accent;
                return GestureDetector(
                  onTap: () {
                    ref.read(themeSettingsProvider.notifier).setAccentColor(accent);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accent.lightBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? accent.color : AppColors.borderLight,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: accent.color,
                          radius: 20,
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          accent.nameArabic,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

            // 2. Bluetooth Printer Configuration
            _buildSectionHeader(
              title: 'إعدادات الطابعة الحرارية (Bluetooth Thermal Printer)',
              subtitle: 'ربط طابعة البلوتوث بعرض 56mm أو 58mm واختبار الطباعة الفورية',
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (bluetoothDevices.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.amber),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'خطوات الربط:\n1. قم باقتران الطابعة أولاً من إعدادات البلوتوث الخاصة بالتابلت/الجهاز.\n2. تأكد من تفعيل البلوتوث والموقع (Location).\n3. اضغط على زر التحديث 🔄 أعلى اليمين لاستيراد الطابعة.',
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<BluetoothInfo>(
                            value: selectedBluetoothDevice,
                            decoration: const InputDecoration(
                              labelText: 'الأجهزة المقترنة (Bluetooth Devices)',
                              border: OutlineInputBorder(),
                            ),
                            items: bluetoothDevices.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text('${d.name} (${d.macAdress})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => selectedBluetoothDevice = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: isScanningPrinters
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh_rounded),
                          onPressed: _scanPrinters,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Text('حجم ورق الطباعة: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('58mm (الافتراضي)'),
                          selected: restaurantInfo.paperWidth == '58mm',
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: restaurantInfo.paperWidth == '58mm' ? Colors.white : AppColors.textDark,
                          ),
                          onSelected: (val) {
                            if (val) {
                              ref.read(restaurantInfoProvider.notifier).updateInfo(
                                    restaurantInfo.copyWith(paperWidth: '58mm'),
                                  );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('56mm'),
                          selected: restaurantInfo.paperWidth == '56mm',
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: restaurantInfo.paperWidth == '56mm' ? Colors.white : AppColors.textDark,
                          ),
                          onSelected: (val) {
                            if (val) {
                              ref.read(restaurantInfoProvider.notifier).updateInfo(
                                    restaurantInfo.copyWith(paperWidth: '56mm'),
                                  );
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          icon: const Icon(Icons.bluetooth_connected_rounded, color: Colors.white),
                          label: const Text('الاتصال وحفظ إعدادات الطابعة', style: TextStyle(color: Colors.white)),
                          onPressed: () async {
                            if (selectedBluetoothDevice != null) {
                              final connected = await PrinterService.instance
                                  .connect(selectedBluetoothDevice!);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(connected
                                        ? 'تم الاتصال بالطابعة بنجاح ✓'
                                        : 'فشل الاتصال بالطابعة، تحقق من الاقتران'),
                                    backgroundColor:
                                        connected ? AppColors.success : AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.print_rounded),
                          label: const Text('زر اختبار الطباعة (Test Print)'),
                          onPressed: () async {
                            final ok = await PrinterService.instance
                                .printTestReceipt(restaurantInfo);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'تم إرسال أمر اختبار الطباعة'
                                      : 'لم يتم الاتصال بالطابعة بعد'),
                                  backgroundColor:
                                      ok ? AppColors.success : AppColors.warning,
                                ),
                              );
                            }
                          },
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

            // 3. Restaurant & Thermal Invoice Info Form
            _buildSectionHeader(
              title: 'بيانات المطعم وتخصيص الفاتورة الحرارية',
              subtitle: 'تعديل البيانات التي تظهر أعلى وأسفل الفاتورة الحرارية المطبوعة دون الحاجة لتحديث التطبيق',
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'اسم المطعم', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: currencyCtrl,
                      decoration: const InputDecoration(labelText: 'العملة المستخدمة (مثال: د.ع / ر.س / USD)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: footerCtrl,
                      decoration: const InputDecoration(labelText: 'الرسالة أسفل الفاتورة (تذييل الفاتورة)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('إظهار العنوان في الفاتورة'),
                      value: restaurantInfo.showAddress,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        ref.read(restaurantInfoProvider.notifier).updateInfo(
                              restaurantInfo.copyWith(showAddress: val),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('إظهار رقم الهاتف في الفاتورة'),
                      value: restaurantInfo.showPhone,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        ref.read(restaurantInfoProvider.notifier).updateInfo(
                              restaurantInfo.copyWith(showPhone: val),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('إظهار رسالة التذييل أسفل الفاتورة'),
                      value: restaurantInfo.showFooter,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        ref.read(restaurantInfoProvider.notifier).updateInfo(
                              restaurantInfo.copyWith(showFooter: val),
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        onPressed: () async {
                          final updated = restaurantInfo.copyWith(
                            name: nameCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            currency: currencyCtrl.text.trim(),
                            invoiceFooter: footerCtrl.text.trim(),
                          );
                          await ref.read(restaurantInfoProvider.notifier).updateInfo(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم حفظ بيانات المطعم والتطبيق بنجاح ✓'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text('حفظ بيانات المطعم والفاتورة', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // 4. Data Control & Reset Demo Data
            _buildSectionHeader(
              title: 'إدارة قاعدة البيانات والنسخ الاحتياطي',
              subtitle: 'تحميل البيانات التجريبية للاستعراض أو مسح القاعدة وإعادة التهيئة',
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('إعادة تحميل البيانات التجريبية (Demo Data)'),
                  onPressed: () async {
                    await DatabaseHelper.instance.reloadDemoData();
                    await ref.read(menuNotifierProvider.notifier).loadMenu();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إعادة استعادة البيانات التجريبية بنجاح ✓'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('مسح جميع البيانات'),
                  onPressed: () async {
                    await DatabaseHelper.instance.clearAllData();
                    await ref.read(menuNotifierProvider.notifier).loadMenu();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم مسح جميع البيانات بنجاح'),
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

  Widget _buildSectionHeader({required String title, required String subtitle}) {
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
