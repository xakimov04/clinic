


import 'export/di_export.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //NOTE: Core modullarni ro'yxatga olish
  await registerCoreModule();

  //NOTE: Feature modullarni ro'yxatga olish
  await registerAuthModule();
  await registerProfileModule();
  await registerHomeModule();
  await registerChatModule();
  await registerMessageModule();
}
