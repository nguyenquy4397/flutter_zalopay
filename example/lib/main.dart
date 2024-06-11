import 'package:flutter/material.dart';
import 'package:flutter_zalopay_example/theme_data.dart';

import 'config.dart';
import 'dashboard.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: myTheme,
      home: const Dashboard(
        title: AppConfig.appName,
        version: AppConfig.version,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
