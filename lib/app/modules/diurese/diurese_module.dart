import 'package:dia_vision/app/modules/home/domain/entities/module.dart';
import 'package:dia_vision/app/repositories/diurese_repository.dart';
import 'package:dia_vision/app/shared/utils/strings.dart';

import 'controllers/diurese_register_controller.dart';
import 'controllers/diurese_controller.dart';
import 'pages/diurese_register_page.dart';
import 'pages/diurese_page.dart';

import 'package:flutter_modular/flutter_modular.dart';

class DiureseModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => DiureseRepository()),
        Bind((i) => DiureseController(i(), i())),
        Bind((i) => DiureseRegisterController(i(), i(), i())),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(kidney.routeName, child: (_, args) => DiuresePage()),
        ModularRouter("/$REGISTER",
            child: (_, args) => DiureseRegisterPage(args.data)),
      ];
}