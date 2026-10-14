class RestaurantInfo {
  final String name;
  final String address;
  final String phone;
  final String? logoPath;
  final String currency;
  final String invoiceFooter;
  final String paperWidth; // '56mm' or '58mm'
  final bool showLogo;
  final bool showAddress;
  final bool showPhone;
  final bool showFooter;
  final String invoicePrefix; // e.g. INV-

  RestaurantInfo({
    this.name = 'مطعم الفخامة والتذوق',
    this.address = 'بغداد - الكرادة - الشارع العام',
    this.phone = '07700000000',
    this.logoPath,
    this.currency = 'د.ع',
    this.invoiceFooter = 'شكراً لزيارتكم! نرجو رؤيتكم مجدداً',
    this.paperWidth = '58mm',
    this.showLogo = true,
    this.showAddress = true,
    this.showPhone = true,
    this.showFooter = true,
    this.invoicePrefix = 'INV-',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'logo_path': logoPath,
      'currency': currency,
      'invoice_footer': invoiceFooter,
      'paper_width': paperWidth,
      'show_logo': showLogo ? 1 : 0,
      'show_address': showAddress ? 1 : 0,
      'show_phone': showPhone ? 1 : 0,
      'show_footer': showFooter ? 1 : 0,
      'invoice_prefix': invoicePrefix,
    };
  }

  factory RestaurantInfo.fromMap(Map<String, dynamic> map) {
    return RestaurantInfo(
      name: (map['name'] as String?) ?? 'مطعم الفخامة والتذوق',
      address: (map['address'] as String?) ?? 'بغداد - الكرادة - الشارع العام',
      phone: (map['phone'] as String?) ?? '07700000000',
      logoPath: map['logo_path'] as String?,
      currency: (map['currency'] as String?) ?? 'د.ع',
      invoiceFooter: (map['invoice_footer'] as String?) ?? 'شكراً لزيارتكم! نرجو رؤيتكم مجدداً',
      paperWidth: (map['paper_width'] as String?) ?? '58mm',
      showLogo: (map['show_logo'] as int?) != 0,
      showAddress: (map['show_address'] as int?) != 0,
      showPhone: (map['show_phone'] as int?) != 0,
      showFooter: (map['show_footer'] as int?) != 0,
      invoicePrefix: (map['invoice_prefix'] as String?) ?? 'INV-',
    );
  }

  RestaurantInfo copyWith({
    String? name,
    String? address,
    String? phone,
    String? logoPath,
    String? currency,
    String? invoiceFooter,
    String? paperWidth,
    bool? showLogo,
    bool? showAddress,
    bool? showPhone,
    bool? showFooter,
    String? invoicePrefix,
  }) {
    return RestaurantInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logoPath: logoPath ?? this.logoPath,
      currency: currency ?? this.currency,
      invoiceFooter: invoiceFooter ?? this.invoiceFooter,
      paperWidth: paperWidth ?? this.paperWidth,
      showLogo: showLogo ?? this.showLogo,
      showAddress: showAddress ?? this.showAddress,
      showPhone: showPhone ?? this.showPhone,
      showFooter: showFooter ?? this.showFooter,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
    );
  }
}
