import 'package:dia_vision/app/modules/home/domain/entities/module.dart';
import 'package:dia_vision/app/shared/utils/color_utils.dart';
import 'package:dia_vision/app/shared/utils/date_utils.dart';
import 'package:dia_vision/app/shared/utils/strings.dart';
import 'package:dia_vision/app/model/avaliacao_pes.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class AvaliacaoPesWidget extends StatelessWidget with DateUtils {
  final AvaliacaoPes _avaliacaoPes;

  const AvaliacaoPesWidget(this._avaliacaoPes);

  String getFullString(String fieldName, String text) {
    if (text?.isNotEmpty != true) return null;
    return "$fieldName: $text";
  }

  String getStringFromBool(String fieldName, bool value) {
    if (value == null) return null;
    return "$fieldName ${value ? 'Sim' : 'Não'}.";
  }

  @override
  Widget build(BuildContext context) {
    final subtitleContents = [
      getStringFromBool("Possui calos?", _avaliacaoPes.calos),
      getStringFromBool(
          "Checa os pés antes de calçar?", _avaliacaoPes.checaAntesCalcar),
      getStringFromBool("Corta unhas?", _avaliacaoPes.cortaUnhas),
      getFullString("Última consulta",
          getDataBrFromDate(_avaliacaoPes.dataUltimaConsulta)),
      getStringFromBool("Estão hidratados?", _avaliacaoPes.hidratados),
      getStringFromBool("Estão lavados?", _avaliacaoPes.lavou),
      getFullString("Temperatura da lavagem",
          _avaliacaoPes.temperaturaLavagem?.toString()),
      getStringFromBool(
          "Possuem pontos vermelhos?", _avaliacaoPes.pontosVermelhos),
      getStringFromBool("Possuem rachaduras?", _avaliacaoPes.rachaduras),
      getStringFromBool("Secou?", _avaliacaoPes.secou),
      getStringFromBool(
          "Usa protetor solar nos pés?", _avaliacaoPes.usaProtetorSolarPes),
    ];
    subtitleContents.removeWhere((e) => e == null);

    String stringToSpeak = subtitleContents.toString();
    stringToSpeak = stringToSpeak.length > 1
        ? stringToSpeak.substring(1, stringToSpeak.length - 1)
        : stringToSpeak;

    return InkWell(
      onTap: () => Modular.to.pushNamed(
        "${feet.routeName}/$REGISTER",
        arguments: _avaliacaoPes,
      ),
      onLongPress: () => Modular.get<FlutterTts>().speak(stringToSpeak),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ColorUtils.colors[
              _avaliacaoPes.createdAt.hashCode % ColorUtils.colors.length],
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
                  "Dia: " + (getDataBrFromDate(_avaliacaoPes.createdAt) ?? ""),
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
