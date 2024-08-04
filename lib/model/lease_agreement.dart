class LeaseAgreement {
  final String id;
  final String tenantName;
  final String propertyAddress;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRent;

  LeaseAgreement({
    required this.id,
    required this.tenantName,
    required this.propertyAddress,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
  });
}
