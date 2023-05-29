import 'package:bitcoin_chat/services/api/chat_repository.dart';
import 'package:get_it/get_it.dart';

import '../models/user.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<ChatRepository>(ChatRepository());
  getIt.registerSingleton<User>(User());
}
