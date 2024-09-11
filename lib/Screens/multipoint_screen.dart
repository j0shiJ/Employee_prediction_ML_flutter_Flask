import 'package:employee_prediction/Providers/Employee_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MultipointScreen extends StatelessWidget {
  final List<LatLng> points;

  const MultipointScreen({Key? key, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final employee = employeeProvider.selectedEmployee;
    if (employee == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Employee Plot'),
        ),
        body: const Center(
          child: Text('No Employee Selected'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('All Point Map'),
        ),
        body: FlutterMap(
          options: MapOptions(
            initialCenter:
                LatLng(employee.employeeLatitude, employee.employeeLongitude),
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.osm.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
                markers: points
                    .map(
                      (point) => Marker(
                        point: point,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.location_on),
                          color: Colors.grey,
                          iconSize: 45,
                        ),
                      ),
                    )
                    .toList())
          ],
        ),
      );
    }
  }
}
