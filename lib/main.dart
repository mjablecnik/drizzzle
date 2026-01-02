import 'dart:io';

import 'package:drizzzle/app.dart';
import 'package:drizzzle/config/dependencies.dart';
import 'package:drizzzle/data/services/db_local/db_client.dart';
import 'package:drizzzle/data/services/db_local/db_singleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Drizzzle');
    setWindowMinSize(const Size(400, 300));
    setWindowMaxSize(Size.infinite);
    setWindowFrame(const Rect.fromLTWH(100, 100, 800, 1500));
  }
  final dbSingleton = DbSingleton();
  final db = await dbSingleton.database;
  final DbClient dbClient = DbClient(db: db);
  final pref = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: providers(dbClient, pref),
      child: const App(),
    ),
  );
}
