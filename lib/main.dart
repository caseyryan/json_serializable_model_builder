import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:lite_forms/lite_forms.dart';
import 'package:lite_forms/utils/lite_forms_configuration.dart';

import 'json_tree_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
    initializeLiteForms(
      config: LiteFormsConfiguration.thinFields(context),
    );
    initControllers({
      JsonTreeController:() => JsonTreeController(),
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Json Serializable Model Builder',
      theme: ThemeData(
        // primaryColor: Colors.red,
        // colorScheme: ColorScheme.fromSwatch(
        //   primarySwatch: Colors.deepOrange,
        // ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.lato(
            fontSize: 16.0,
          )
        ),
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      // themeMode: ThemeMode.dark,
      home: const JsonTreePage(),
    );
  }
}
