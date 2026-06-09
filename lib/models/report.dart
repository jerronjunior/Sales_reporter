class Report {
  final String month;
  final double revenue;
  final int orders;

  const Report({
    required this.month,
    required this.revenue,
    required this.orders,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        month: json['month'] as String,
        revenue: (json['revenue'] as num).toDouble(),
        orders: json['orders'] as int,
      );
}
