import 'package:employee_prediction/Models/employee_data.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

const String baseUrl = 'http://127.0.0.1:5000';

class EmployeeProvider extends ChangeNotifier {
  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;

  List<String> _employeeIds = [];
  String? _selectedEmployeeId;
  List<String> _filteredEmployeeIds = [];

  List<String> get employeeIds => _employeeIds;
  List<String> get filteredEmployeeIds => _filteredEmployeeIds;
  String? get selectedEmployeeId => _selectedEmployeeId;

  EmployeeProvider() {
    fetchEmployeeIds();
    fetchAllEmployeeData();
    // Fetch employee data on initialization
  }

// New method to fetch employees within a distance
  Future<void> fetchEmployeesWithinDistance(double distance) async {
    try {
      final url = '$baseUrl/employee_within_distance?distance=$distance';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if employee_ids exist and are not null
        if (data.containsKey('employee_ids') && data['employee_ids'] != null) {
          final List<dynamic> ids = data['employee_ids'] as List<dynamic>;

          // Check if the list is empty and handle it
          if (ids.isNotEmpty) {
            _filteredEmployeeIds = ids.map((id) => id.toString()).toList();

            notifyListeners(); // Notify the UI of changes
          } else {
            throw Exception(
                'No employees found within the specified distance.');
          }
        } else {
          throw Exception('Invalid response: Missing employee_ids');
        }
      } else {
        throw Exception('Failed to fetch filtered employee IDs');
      }
    } catch (e) {
      print('Error fetching filtered employee IDs: $e');
      throw Exception('Failed to fetch filtered employee IDs: $e');
    }
  }

  Future<List<LatLng>> fetchAllLatLngForEmployee(String employeeId) async {
    try {
      // Fetch employee data from the backend for the given employeeId
      final response = await http
          .get(Uri.parse('$baseUrl/employee_locations?employeeid=$employeeId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Extract the list of locations from the 'locations' field
        final List<dynamic> locations = data['locations'];

        // Convert the locations into a list of LatLng objects
        return locations
            .map((location) => LatLng(
                  location[0]?.toDouble() ?? 0.0, // Latitude
                  location[1]?.toDouble() ?? 0.0, // Longitude
                ))
            .toList();
      } else {
        throw Exception('Failed to fetch location data for employee');
      }
    } catch (e) {
      print('Error fetching employee locations: $e');
      return [];
    }
  }

  // Method to fetch employee IDs
  Future<void> fetchEmployeeIds() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/employee_ids'));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> ids = data['employee_ids'] as List<dynamic>;
        _employeeIds = ids.map((id) => id.toString()).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch employee IDs');
      }
    } catch (e) {
      print('Error fetching employee IDs: $e');
      throw Exception('Failed to fetch employee IDs: $e');
    }
  }

  // Method to fetch all employee data
  Future<void> fetchAllEmployeeData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/employee_data'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _employees = data.map((json) => Employee.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch employee data');
      }
    } catch (e) {
      print('Error fetching employee data: $e');
      throw Exception('Failed to fetch employee data: $e');
    }
  }

  void setSelectedEmployeeId(String employeeId) {
    _selectedEmployeeId = employeeId;
    _selectedEmployee = _employees.firstWhere(
      (employee) => employee.employeeId == int.parse(employeeId),
    );
    notifyListeners();
  }

  List<LatLng> getAllEmployeePoints() {
    return _employees
        .map((e) => LatLng(
              e.employeeLatitude,
              e.employeeLongitude,
            ))
        .toList();
  }

  // Method to fetch predicted location for a specific employee
  Future<Map<String, double>?> fetchPredictedLatLng(String employeeId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/predict_location?employeeid=$employeeId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        double predictedLatitude =
            data['predicted_latitude']?.toDouble() ?? 0.0;
        double predictedLongitude =
            data['predicted_longitude']?.toDouble() ?? 0.0;
        return {
          'predictedLatitude': predictedLatitude,
          'predictedLongitude': predictedLongitude,
        };
      } else {
        print('Failed to load predicted location: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching predicted location: $e');
      return null;
    }
  }
}
