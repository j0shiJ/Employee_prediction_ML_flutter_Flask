import 'dart:convert';

import 'package:employee_prediction/Providers/Employee_provider.dart';
import 'package:employee_prediction/Screens/multipoint_screen.dart';
import 'package:employee_prediction/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
// Update the import path

class EmployeeScreen extends StatefulWidget {
  final String employeeId;
  static const String routeName = '/employee';
  EmployeeScreen({required this.employeeId});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List listofPoints = [];
  List<LatLng> points = [];
  List<LatLng> employeeLocations = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchEmployeeLocations();
  }

  void _fetchEmployeeLocations() async {
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    final locations =
        await employeeProvider.fetchAllLatLngForEmployee(widget.employeeId);
    // print("Fetched Employee Locations in Widget: $locations");
    setState(() {
      employeeLocations = locations;
    });
    // print("Fetched Employee Locations: $employeeLocations");
  }

  void navigateToMultiPointMapScreen(
      BuildContext context, List<LatLng> points) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultipointScreen(points: points),
      ),
    );
  }

  getCoordinates(String startPoint, String endPoint) async {
    var response = await http.get(getRouteUrl(startPoint, endPoint));
    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listofPoints = data['features'][0]['geometry']['coordinates'];
        points = listofPoints
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final employee = employeeProvider.selectedEmployee;

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Employee Plot'),
                Text('Total history locations: ${employeeLocations.length}'),
              ],
            )
          ],
        ),
        body: Center(
          child: FloatingActionButton(
            backgroundColor: Colors.grey,
            onPressed: () => navigateToMultiPointMapScreen(
                context, employeeProvider.getAllEmployeePoints()),
            child: const Icon(
              Icons.map,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    String startPoint = employee.employeeLongitude.toString() +
        "," +
        employee.employeeLatitude.toString();
    String endPoint = '';

    return Scaffold(body:
        Consumer<EmployeeProvider>(builder: (context, employeeProvider, child) {
      return FutureBuilder(
          future: employeeProvider.fetchPredictedLatLng(widget.employeeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final predictedData = snapshot.data!;
              String endPoint = predictedData['predictedLongitude'].toString() +
                  "," +
                  predictedData['predictedLatitude'].toString();

              // Create LatLng objects for start and predicted locations
              LatLng employeeLatLng = LatLng(
                employee.employeeLatitude,
                employee.employeeLongitude,
              );
              LatLng predictedLatLng = LatLng(
                predictedData['predictedLatitude']!,
                predictedData['predictedLongitude']!,
              );

              return Scaffold(
                appBar: AppBar(
                  backgroundColor:
                      Colors.blueAccent, // Change the background color
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5), // Add some spacing
                      Text(
                        'Tracking location history',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 15.0), // Add right padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Employee ID: ${employee.employeeId}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                              height: 5), // Add spacing between the two texts
                          Text(
                            'Total history locations: ${employeeLocations.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                body: FlutterMap(
                    options: MapOptions(
                      initialCenter: employeeLatLng,
                      initialZoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.osm.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(markers: [
                        ...employeeLocations
                            .map(
                              (location) => Marker(
                                point: location,
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.push_pin),
                                  color: Colors.yellow,
                                  iconSize: 25,
                                ),
                              ),
                            )
                            .toList(),
                        Marker(
                          point: employeeLatLng,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.location_on),
                            color: Colors.green,
                            iconSize: 25,
                          ),
                        ),
                        Marker(
                          point: predictedLatLng,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.location_on),
                            color: Colors.red,
                            iconSize: 25,
                          ),
                        ),
                      ]),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                              points: points,
                              color: Colors.green,
                              strokeWidth: 5)
                        ],
                      ),
                    ]),
                floatingActionButton: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'TagForThisButton-1',
                      onPressed: () => getCoordinates(startPoint, endPoint),
                      backgroundColor: Colors.blueAccent,
                      child: const Icon(
                        Icons.route,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FloatingActionButton(
                      heroTag: 'TagForThisButton-2',
                      onPressed: () => navigateToMultiPointMapScreen(
                        context,
                        employeeProvider.getAllEmployeePoints(),
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text('no data available'));
            }
          });
    }));
  }

  Future<Map<String, double>?> _fetchEmployeeDetails(
      EmployeeProvider provider) async {
    return await provider.fetchPredictedLatLng(widget.employeeId);
  }
}
