import 'package:dia_vision/app/repositories/glicemia_repository.dart';
import 'package:dia_vision/app/shared/utils/date_utils.dart';
import 'package:dia_vision/app/app_controller.dart';
import 'package:dia_vision/app/model/glicemia.dart';

import 'package:mobx/mobx.dart';

import 'glicemia_controller.dart';

part 'glicemia_register_controller.g.dart';

class GlicemiaRegisterController = _GlicemiaRegisterControllerBase
    with _$GlicemiaRegisterController;

abstract class _GlicemiaRegisterControllerBase with Store, DateUtils {
  final IGlicemiaRepository _glicemiaRepository;
  final GlicemiaController _glicemiaController;
  final AppController _appController;

  _GlicemiaRegisterControllerBase(
    this._glicemiaRepository,
    this._glicemiaController,
    this._appController,
  );

  @observable
  String valor;
  @observable
  String horario;

  @observable
  bool isLoading = false;
  @observable
  List<Glicemia> glicemias = [];

  Glicemia _glicemia;

  @computed
  bool get isEdicao => _glicemia != null;

  @action
  void setValor(String newValue) => valor = newValue;
  @action
  void setHorario(String newValue) => horario = newValue;

  void init(Glicemia glicemia) {
    _glicemia = glicemia;
    if (glicemia != null) {
      setValor(glicemia.valor?.toString());
      setHorario(glicemia.horario?.displayTitle);
    }
  }

  Future<void> save(Function(String) onError, void Function() onSuccess) async {
    isLoading = true;

    try {
      final glicemia = Glicemia();
      glicemia.horario = horario != null
          ? HorarioType.values.firstWhere((e) => e.displayTitle == horario)
          : null;
      final user = await _appController.currentUser();
      glicemia.paciente = user.paciente;
      glicemia.objectId = _glicemia?.objectId;

      final dValor =
          valor != null ? num.tryParse(valor.replaceAll(',', '.')) : null;
      if (dValor != null) glicemia.valor = dValor;

      final result = await _glicemiaRepository.save(glicemia, user);
      result.fold((l) => onError(l.message), (r) {
        final idx = _glicemiaController.glicemias
            .indexWhere((e) => e.objectId == r.objectId);
        if (idx == -1) {
          _glicemiaController.glicemias.insert(0, r);
        } else {
          r.createdAt = _glicemiaController.glicemias[idx].createdAt;
          _glicemiaController.glicemias[idx] = r;
        }
        onSuccess();
      });
    } catch (e) {
      onError(e.toString());
    }

    isLoading = false;
  }
}