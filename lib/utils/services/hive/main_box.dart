import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tddboilerplate/utils/utils.dart';

enum ActiveTheme {
  light(ThemeMode.light),
  dark(ThemeMode.dark),
  system(ThemeMode.system);

  final ThemeMode mode;

  const ActiveTheme(this.mode);
}

enum MainBoxKeys {
  token,
  fcm,
  language,
  theme,
  locale,
  isLogin,
  tokenData,
}

mixin class MainBoxMixin {
  static late Box? mainBox;
  static const _boxName = 'flutter_auth_app';

  static Future<void> initHive(String prefixBox) async {
    // Initialize hive (persistent database)
    await Hive.initFlutter();

    //check if the adapter is already registered
    //if not checked will be return error to integration test
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserLoginEntityAdapter());
    }

    mainBox = await Hive.openBox("$prefixBox$_boxName");
  }

  Future<void> addData<T>(MainBoxKeys key, T value) async {
    await mainBox?.put(key.name, value);
  }

  Future<void> removeData(MainBoxKeys key) async {
    await mainBox?.delete(key.name);
  }

  T getData<T>(MainBoxKeys key) => mainBox?.get(key.name) as T;

  Future<void> logoutBox() async {
    /// Clear the box
    removeData(MainBoxKeys.isLogin);
    removeData(MainBoxKeys.token);
    removeData(MainBoxKeys.tokenData);
  }

  Future<void> closeBox({bool isUnitTest = false}) async {
    try {
      if (mainBox != null) {
        await mainBox?.close();
        await mainBox?.deleteFromDisk();
      }
    } catch (e, stackTrace) {
      if (!isUnitTest) {
        FirebaseCrashLogger().nonFatalError(error: e, stackTrace: stackTrace);
      }
    }
  }
}
