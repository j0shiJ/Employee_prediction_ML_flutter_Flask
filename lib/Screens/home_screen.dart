import 'package:employee_prediction/Providers/Employee_provider.dart';
import 'package:employee_prediction/Screens/Employee_screen.dart';
import 'package:employee_prediction/Screens/employeecounter_screen.dart';
// Import the EmployeeCounterScreen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch employee IDs once when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployeeIds();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    // Filter the employee IDs based on the search query
    final filteredEmployeeIds = searchQuery.isEmpty
        ? employeeProvider.employeeIds
        : employeeProvider.employeeIds
            .where((id) => id.contains(searchQuery))
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent, // Set a background color
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home Screen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5), // Add some spacing between the texts
            Text(
              'Select or search an Employee ID',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 15.0), // Add padding to the right
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Employees: ${employeeProvider.employeeIds.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Consumer<EmployeeProvider>(
          builder: (context, employeeProvider, child) {
            return FutureBuilder(
              future: Future.value(employeeProvider.employeeIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    employeeProvider.employeeIds.isEmpty) {
                  return const Center(child: Text('No employee IDs found'));
                } else {
                  return Container(
                    padding: const EdgeInsets.all(11),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            DropdownButton<String>(
                              hint: const Text('Select Employee ID'),
                              value: employeeProvider.selectedEmployeeId,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  employeeProvider
                                      .setSelectedEmployeeId(newValue);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmployeeScreen(
                                        employeeId: newValue,
                                      ),
                                    ),
                                  );
                                }
                              },
                              items: filteredEmployeeIds.map((id) {
                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(id),
                                );
                              }).toList(),
                            ),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  labelText: 'Search Employee ID',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                  if (filteredEmployeeIds.contains(value)) {
                                    employeeProvider
                                        .setSelectedEmployeeId(value);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmployeeScreen(
                                          employeeId: value,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Employee ID not found in the list'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 20), // Add space before the button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              EmployeeCounterScreen.routeName,
                            );
                          },
                          child: const Text('Go to Employee Counter'),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
