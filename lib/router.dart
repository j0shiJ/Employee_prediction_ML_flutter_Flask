import 'package:employee_prediction/Screens/Employee_screen.dart';
import 'package:employee_prediction/Screens/employeecounter_screen.dart';
import 'package:employee_prediction/Screens/home_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case EmployeeScreen.routeName:
        // Extract arguments and pass them to EmployeeScreen
        final employeeId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => EmployeeScreen(employeeId: employeeId ?? ''),
        );
      case EmployeeCounterScreen.routeName:
        return MaterialPageRoute(builder: (_) => EmployeeCounterScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}
