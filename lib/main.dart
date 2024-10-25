import 'package:employee_prediction/Providers/Employee_provider.dart';
import 'package:employee_prediction/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employee Plot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/home',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
