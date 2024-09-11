import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:employee_prediction/Providers/employee_provider.dart';

class EmployeeCounterScreen extends StatefulWidget {
  @override
  _EmployeeCounterScreenState createState() => _EmployeeCounterScreenState();
}

class _EmployeeCounterScreenState extends State<EmployeeCounterScreen> {
  final TextEditingController _distanceController = TextEditingController();

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.blueAccent, // Set the background color similar to HomeScreen
        title: Column(
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
              'Enter distance to fetch employee IDs',
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
          children: [
            // Input field to take distance
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Distance (in meters)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                double? distance = double.tryParse(value);
                if (distance != null) {
                  employeeProvider.fetchEmployeesWithinDistance(distance);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid distance')),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            // Display the filtered employee IDs in a scrollable list
            Expanded(
              child: employeeProvider.filteredEmployeeIds.isNotEmpty
                  ? ListView.builder(
                      itemCount: employeeProvider.filteredEmployeeIds.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              'Employee ID: ${employeeProvider.filteredEmployeeIds[index]}'),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                          'No employees found within the specified distance'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
