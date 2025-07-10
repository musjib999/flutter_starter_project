import 'package:get_it/get_it.dart';
import '../../data/source/local/app_local_data.dart';
import '../../data/source/local/local_data.dart';
import '../../data/source/local/token_storage.dart';
import '../../data/source/remote/remote_data.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<RemoteData>(() => RemoteData());
  locator.registerLazySingleton<LocalData>(() => LocalData());
  locator.registerLazySingleton<AppLocalData>(() => AppLocalData());
  locator.registerLazySingleton<TokenStorage>(() => TokenStorage());
}
