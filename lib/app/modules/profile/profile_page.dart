import '../../../app/shared/components/back_arrow_button.dart';
import '../..//shared/utils/route_enum.dart';

import 'components/profile_menu.dart';
import 'components/profile_pic.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String title;
  const ProfilePage({Key key, this.title = "Profile"}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  BackArrowButton(),
                ],
              ),
              SizedBox(height: 20),
              ProfilePic(),
              SizedBox(height: 40),
              ProfileMenu(
                text: "Meus dados",
                icon: "assets/icons/User Icon.svg",
                onPressed: () => Modular.to
                    .pushNamed(RouteEnum.profile.name + RouteEnum.my_data.name),
              ),
              ProfileMenu(
                text: "Notificações",
                icon: "assets/icons/Bell.svg",
                onPressed: () {},
              ),
              ProfileMenu(
                text: "Preferências",
                icon: "assets/icons/Settings.svg",
                onPressed: () {},
              ),
              ProfileMenu(
                text: "Sair",
                icon: "assets/icons/Log out.svg",
                onPressed: () =>
                    Modular.to.pushReplacementNamed(RouteEnum.auth.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
