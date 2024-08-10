class LeaseAgreement {
  final String id; // Unique identifier for the lease agreement
  final String tenantName; // Name of the tenant
  final String propertyAddress; // Address of the property
  final DateTime startDate; // Lease start date
  final DateTime endDate; // Lease end date
  final double monthlyRent; // Monthly rent amount
  final List<String> documents; // List of document URLs

  // Constructor to initialize the LeaseAgreement object
  LeaseAgreement({
    required this.id,
    required this.tenantName,
    required this.propertyAddress,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.documents,
  });
}
