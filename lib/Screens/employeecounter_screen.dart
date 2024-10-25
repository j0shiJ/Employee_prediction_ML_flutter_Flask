import 'package:employee_prediction/Providers/Employee_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeCounterScreen extends StatefulWidget {
  static const String routeName = '/employee_counter';

  @override
  _EmployeeCounterScreenState createState() => _EmployeeCounterScreenState();
}

class _EmployeeCounterScreenState extends State<EmployeeCounterScreen> {
  final TextEditingController _distanceController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<String>? _employeeList;

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees(double distance) async {
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await employeeProvider.fetchEmployeesWithinDistance(distance);

      setState(() {
        _employeeList = employeeProvider.filteredEmployeeIds;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to fetch employees: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.blueAccent, // Match the HomeScreen background color
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Counter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Enter a distance to fetch employees',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Distance (in meters)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final distance = double.tryParse(value);
                if (distance != null) {
                  _fetchEmployees(distance);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid distance'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(child: Text(_errorMessage!))
            else if (_employeeList != null && _employeeList!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _employeeList!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Employee ID: ${_employeeList![index]}'),
                    );
                  },
                ),
              )
            else
              const Center(child: Text('No employees found')),
          ],
        ),
      ),
    );
  }
}
