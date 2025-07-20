import 'package:clinic/core/di/modules/appointment_module.dart';
import 'package:clinic/core/di/modules/news_module.dart';
import 'modules/receptions_module.dart';

import 'export/di_export.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await registerCoreModule();

  await registerAuthModule();
  await registerProfileModule();
  await registerHomeModule();
  await registerChatModule();
  await registerMessageModule();
  await registerAppointmentModule();
  await registerNewsModule();
  await registerReceptionsModule();
}
