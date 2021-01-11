import '../../shared/utils/route_enum.dart';

import 'package:flutter_modular/flutter_modular.dart';

import 'home_bloc.dart';
import 'home_page.dart';

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => HomeBloc()),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(RouteEnum.home.name, child: (_, args) => HomePage()),
      ];
}
