import 'package:dia_vision/app/shared/preferences/preferencias_preferences.dart';
import 'package:dia_vision/app/shared/utils/string_utils.dart';
import 'package:dia_vision/app/shared/utils/strings.dart';
import 'package:dia_vision/app/app_controller.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mobx/mobx.dart';

part 'preferencias_controller.g.dart';

class PreferenciasController = _PreferenciasControllerBase
    with _$PreferenciasController;

abstract class _PreferenciasControllerBase with Store {
  final AwesomeNotifications _awesomeNotifications;
  final PreferenciasPreferences _preferences;
  final AppController _appController;

  _PreferenciasControllerBase(
    this._preferences,
    this._awesomeNotifications,
    this._appController,
  );

  @observable
  bool isLoading = false;
  @observable
  bool isDataReady = false;
  @observable
  bool alertarMedicacao = false;
  @observable
  bool alertarGlicemia = false;
  @observable
  bool alertarHipoHiperGlicemia = true;
  @observable
  String tempoLembrete = "10 min";
  @observable
  String valorMinimoGlicemia = "70";
  @observable
  String valorMaximoGlicemia = "120";
  @observable
  String? horarioGlicemia;
  @observable
  List<String> horarios = <String>[];
  String? horario;
  final idGlicemia = "glicemia".hashCode;

  @action
  void setAlertarMedicacao(bool newValue) {
    alertarMedicacao = newValue;
    _preferences.setAlertarMedicacao(newValue);
  }

  @action
  void setAlertarGlicemia(bool newValue) {
    alertarGlicemia = newValue;
    _preferences.setAlertarGlicemia(newValue);
  }

  @action
  void setAlertarHipoHiperGlicemia(bool newValue) {
    alertarHipoHiperGlicemia = newValue;
    _preferences.setAlertarHipoHiperGlicemia(newValue);
  }

  @action
  void setTempoLembrete(String? newValue) {
    tempoLembrete = newValue ?? tempoLembrete;
    _preferences.setTempoLembrete(tempoLembrete);
  }

  @action
  void addHorario() {
    if (horario != null) horarios.add(horario!);
    horarios = horarios.asObservable();
  }

  @action
  void removeHorario(String h) {
    horarios.remove(h);
    horarios = horarios.asObservable();
  }

  @action
  void setHorario(String newHorario) => horario = newHorario;
  @action
  void setHorarioGlicemia(String newHorarioGlicemia) =>
      horarioGlicemia = newHorarioGlicemia;
  @action
  void setValorMinimoGlicemia(String newValue) =>
      valorMinimoGlicemia = newValue;
  @action
  void setValorMaximoGlicemia(String newValue) =>
      valorMaximoGlicemia = newValue;

  Future<void> getData(Function(String) onError) async {
    isDataReady = false;

    try {
      alertarMedicacao =
          await _preferences.getAlertarMedicacao() ?? alertarMedicacao;
      alertarGlicemia =
          await _preferences.getAlertarGlicemia() ?? alertarGlicemia;
      alertarHipoHiperGlicemia =
          await _preferences.getAlertarHipoHiperGlicemia() ??
              alertarHipoHiperGlicemia;
      tempoLembrete = await _preferences.getTempoLembrete() ?? tempoLembrete;
      valorMinimoGlicemia =
          await _preferences.getValorMinimoGlicemia() ?? valorMinimoGlicemia;
      valorMaximoGlicemia =
          await _preferences.getValorMaximoGlicemia() ?? valorMaximoGlicemia;
      horarios = await _preferences.getHorariosGlicemia() ?? horarios;
    } catch (e) {
      onError(e.toString());
    }

    isDataReady = true;
  }

  Future<void> save(Function(String) onError, void Function() onSuccess) async {
    isLoading = true;

    try {
      await _preferences.setValorMaximoGlicemia(valorMaximoGlicemia);
      await _preferences.setValorMinimoGlicemia(valorMinimoGlicemia);
      await _preferences.setIsValorPadraoGlicemia(false);
      await _preferences.setHorariosGlicemia(horarios);
      enableNotification(onError);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    }

    isLoading = false;
  }

  Future<void> enableNotification(Function(String) onError) async {
    isLoading = true;
    if (horarios.length > 6) {
      onError('O limite máximo de horários para notificação é 6.');
    } else {
      final intTempoLembrete =
          int.tryParse(tempoLembrete.split(' ').elementAt(0));
      try {
        if (horarios.isNotEmpty == true && alertarGlicemia) {
          for (var i = 0; i < horarios.length; i++) {
            await _appController.createNotification(
              idGlicemia + i,
              title: "$tempoLembrete $toGlicemyRegisterTime",
              body: glicemyRegisterTime,
              notificationSchedule: NotificationAndroidCrontab(
                allowWhileIdle: true,
                initialDateTime: DateTime.now().toUtc(),
                crontabExpression:
                    "0 ${getCronHorario(i, horarios, intTempoLembrete)} * * ? *",
              ),
              tempoLembrete: tempoLembrete,
            );
          }
        }
      } catch (e) {
        onError(registerNotificationFail);
      }
    }
    isLoading = false;
  }

  Future<void> disableNotification(
      Function(String) onError, Function(String) onSuccess) async {
    isLoading = true;
    try {
      if (horarios.isNotEmpty == true && !alertarGlicemia) {
        for (var i = 0; i < 6; i++) {
          _awesomeNotifications.cancelSchedule(idGlicemia + i);
        }
        onSuccess(notificationSuccessDisabled);
      }
    } catch (e) {
      onError(deleteNotificationFail);
    }
    isLoading = false;
  }
}
