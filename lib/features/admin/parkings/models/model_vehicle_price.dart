class VehiclePricing {
  String type;
  int slots;
  int balanceSlots;
  double hour;
  double day;
  double month;

  VehiclePricing({
    required this.type,
    required this.slots,
    required this.balanceSlots,
    required this.hour,
    required this.day,
    required this.month,
  });

  factory VehiclePricing.empty() => VehiclePricing(
    type: 'Two Wheeler',
    slots: 0,
    balanceSlots: 0,
    hour: 0,
    day: 0,
    month: 0,
  );

  factory VehiclePricing.fromJson(Map<String, dynamic> json) {
    return VehiclePricing(
      type: json['type'] ?? '',
      slots: json['slots'] ?? 0,
      balanceSlots: json['balance_slots'] ?? json['slots'] ?? 0,
      hour: (json['rate_per_hour'] as num).toDouble(),
      day: (json['rate_per_day'] as num).toDouble(),
      month: (json['rate_per_month'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'slots': slots,
      'balance_slots': balanceSlots,
      'rate_per_hour': hour,
      'rate_per_day': day,
      'rate_per_month': month,
    };
  }
}
