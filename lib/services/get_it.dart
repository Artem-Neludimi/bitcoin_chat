import 'package:get_it/get_it.dart';

import '../models/user.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<User>(User());
}
