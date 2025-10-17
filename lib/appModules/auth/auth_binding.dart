import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    print("dependecies called");
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
