import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  static void showToast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }
}
