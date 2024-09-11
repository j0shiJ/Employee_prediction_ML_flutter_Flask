class Employee {
  final double employeeLatitude;
  final double employeeLongitude;
  final int employeeId;
  final double latitude;
  final double longitude;
  final String shiftDate;

  Employee({
    required this.employeeLatitude,
    required this.employeeLongitude,
    required this.employeeId,
    required this.latitude,
    required this.longitude,
    required this.shiftDate,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeLatitude: json['employee_latitude'],
      employeeLongitude: json['employee_longitude'],
      employeeId: json['employeeid'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      shiftDate: json['shift_date'],
    );
  }
}
