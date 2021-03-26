import 'package:dia_vision/app/modules/home/domain/entities/module.dart';
import 'package:dia_vision/app/shared/utils/color_utils.dart';
import 'package:dia_vision/app/shared/utils/date_utils.dart';
import 'package:dia_vision/app/shared/utils/strings.dart';
import 'package:dia_vision/app/model/glicemia.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class GlicemiaWidget extends StatelessWidget with DateUtils {
  final Glicemia _glicemia;

  const GlicemiaWidget(this._glicemia);

  String getFullString(String fieldName, String text) {
    if (text?.isNotEmpty != true) return null;
    return "$fieldName: $text.";
  }

  @override
  Widget build(BuildContext context) {
    final subtitleContents = [
      getFullString("Valor (mg/dL)", _glicemia.valor?.toString()),
      getFullString("Horário", _glicemia.horario.displayTitle),
    ];
    subtitleContents.removeWhere((e) => e == null);

    String stringToSpeak = subtitleContents.toString();
    stringToSpeak = stringToSpeak.length > 1
        ? stringToSpeak.substring(1, stringToSpeak.length - 1)
        : stringToSpeak;

    return InkWell(
      onTap: () => Modular.to.pushNamed(
        "${glicemy.routeName}/$REGISTER",
        arguments: _glicemia,
      ),
      onLongPress: () => Modular.get<FlutterTts>().speak(stringToSpeak),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ColorUtils.colors[
              _glicemia.horario?.displayTitle.toString().hashCode %
                  ColorUtils.colors.length],
        ),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        margin: EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color(0xFF01215e),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  "Dia: " + (getDataBrFromDate(_glicemia.createdAt) ?? ""),
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subtitleContents
                      .map((e) => buildSubtitlesText(e))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSubtitlesText(String text) {
    return Text(
      text,
      maxLines: 2,
      style: TextStyle(
        fontSize: 18,
        color: Colors.white70,
      ),
    );
  }
}