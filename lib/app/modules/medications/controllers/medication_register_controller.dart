import 'package:dia_vision/app/repositories/medicacao_prescrita_repository.dart';
import 'package:dia_vision/app/repositories/medication_repository.dart';
import 'package:dia_vision/app/model/medicacao_prescrita.dart';
import 'package:dia_vision/app/shared/utils/date_utils.dart';
import 'package:dia_vision/app/model/medicamento.dart';
import 'package:dia_vision/app/app_controller.dart';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import 'medications_controller.dart';

part 'medication_register_controller.g.dart';

class MedicationRegisterController = _MedicationRegisterControllerBase
    with _$MedicationRegisterController;

abstract class _MedicationRegisterControllerBase with Store, DateUtils {
  final IMedicacaoPrescritaRepository _medicacaoPrescritaRepository;
  final IMedicamentoRepository _medicamentoRepository;
  final MedicationsController _medicationsController;
  final AppController _appController;

  _MedicationRegisterControllerBase(
    this._medicacaoPrescritaRepository,
    this._medicationsController,
    this._medicamentoRepository,
    this._appController,
  );

  @observable
  String medicoPrescritor;
  @observable
  String nome;
  @observable
  String dataFinal;
  @observable
  String dataInicial;
  @observable
  Tuple2<String, int> posologia;
  @observable
  String dosagem;
  @observable
  String efeitosColaterais;
  @observable
  String horarioInicial;
  @observable
  ObservableList<String> horarios = ObservableList<String>();
  String horario;

  @observable
  bool isSearching = false;
  @observable
  bool isLoading = false;
  @observable
  List<Medicamento> medicamentos = [];

  List<String> nomesMedicamentos = [];
  Medicamento medicamentoSelecionado;
  MedicacaoPrescrita _medicacaoPrescrita;
  List<Medicamento> medicamentosBase = [];

  final List<Tuple2<String, int>> horariosList = [
    Tuple2("1 em 1 hora", 1),
    Tuple2("2 em 2 horas", 2),
    Tuple2("4 em 4 horas", 4),
    Tuple2("6 em 6 horas", 6),
    Tuple2("8 em 8 horas", 8),
    Tuple2("12 em 12 horas", 12),
    Tuple2("24 em 24 horas", 24),
    Tuple2("Personalizado", 0),
  ];

  @computed
  bool get isNomeValid => nome != null && nome.length > 3;
  @computed
  bool get isEdicao => _medicacaoPrescrita != null;

  @action
  void setNome(String newNome) => nome = newNome;
  @action
  void setMedicoPrescritor(String newMedicoPrescritor) =>
      medicoPrescritor = newMedicoPrescritor;
  @action
  void setEfeitosColaterais(String newEfeitosColaterais) =>
      efeitosColaterais = newEfeitosColaterais;
  @action
  void setHorarioInicial(String newHorarioInicial) =>
      horarioInicial = newHorarioInicial;
  @action
  void setDataInicial(String newDataInicial) => dataInicial = newDataInicial;
  @action
  void setDataFinal(String newDataFinal) => dataFinal = newDataFinal;
  @action
  void setPosologia(String newPosologia) => posologia = horariosList
      .firstWhere((e) => e.value1 == newPosologia, orElse: () => null);
  @action
  void setDosagem(String newDosagem) => dosagem = newDosagem;

  void init(MedicacaoPrescrita medicacao) {
    _medicacaoPrescrita = medicacao;
    if (medicacao != null) {
      setNome(medicacao.nome);
      if (medicacao.dataFinal != null)
        setDataFinal(UtilData.obterDataDDMMAAAA(medicacao.dataFinal));
      if (medicacao.dataInicial != null)
        setDataInicial(UtilData.obterDataDDMMAAAA(medicacao.dataInicial));
      setHorarioInicial(medicacao.horarioInicial);
      if (medicacao.horarios?.isNotEmpty == true) {
        horarios.addAll(medicacao.horarios.split(', '));
      }
      posologia = horariosList.firstWhere(
          (e) => e.value2 == medicacao.posologia,
          orElse: () => null);
      setMedicoPrescritor(medicacao.medicoPrescritor);
      setDosagem(medicacao.dosagem?.toString());
      setEfeitosColaterais(medicacao.efeitosColaterais);
    }
  }

  Future<void> getData(Function(String) onError) async {
    isSearching = true;
    try {
      final result = await _medicamentoRepository.getByText(nome, limit: 200);
      result.fold((l) => onError(l.message), (r) {
        medicamentos = r;
        medicamentosBase = r;
      });
    } catch (e) {
      onError(e.toString());
      isSearching = false;
    }
    isSearching = false;
  }

  Future<List<Medicamento>> getSuggestions(Function(String) onError) async {
    if (isNomeValid && (nome.length == 4 || medicamentosBase?.length == 200))
      await getData(onError);

    if (medicamentosBase?.isNotEmpty == true) {
      nomesMedicamentos = medicamentosBase
          .map((e) => e.nomeComercial + " -- " + e.nomeSubstancia)
          .toList();

      final fuse = Fuzzy(nomesMedicamentos);
      final result = fuse.search(
          nome, medicamentosBase.length < 5 ? medicamentosBase.length : 5);

      medicamentos = result
          .map((r) => medicamentosBase.firstWhere(
              (element) => (element.nomeComercial == r.item.split(" -- ")[0])))
          .toList();
    }

    return medicamentos;
  }

  Future<void> save(Function(String) onError, void Function() onSuccess) async {
    isLoading = true;

    try {
      if (isNomeValid) {
        final medicacaoPrescrita = MedicacaoPrescrita(
          nome: nome,
          medicoPrescritor: medicoPrescritor,
          medicamento: medicamentoSelecionado,
          efeitosColaterais: efeitosColaterais,
        );

        print(horarios.toString().replaceAll('[', '').replaceAll(']', ''));
        print([].toString().replaceAll('[', '').replaceAll(']', ''));

        final user = await _appController.currentUser();
        medicacaoPrescrita.paciente = user.paciente;
        medicacaoPrescrita.objectId = _medicacaoPrescrita?.objectId;
        medicacaoPrescrita.horarioInicial = horarioInicial;

        final dDosagem = dosagem != null ? double.tryParse(dosagem) : null;
        final dDataInicial =
            dataInicial != null ? getDateTime(dataInicial) : null;
        final dDataFinal = dataFinal != null ? getDateTime(dataFinal) : null;
        if (dDosagem != null) medicacaoPrescrita.dosagem = dDosagem;
        if (posologia != null) medicacaoPrescrita.posologia = posologia.value2;
        if (dataInicial != null) medicacaoPrescrita.dataInicial = dDataInicial;
        if (dataFinal != null) medicacaoPrescrita.dataFinal = dDataFinal;
        if (horarios.isNotEmpty)
          medicacaoPrescrita.horarios =
              horarios.toString().replaceAll('[', '').replaceAll(']', '');

        final result =
            await _medicacaoPrescritaRepository.save(medicacaoPrescrita, user);
        result.fold((l) => onError(l.message), (r) {
          final idx = _medicationsController.medicacoes
              .indexWhere((e) => e.objectId == r.objectId);
          idx == -1
              ? _medicationsController.medicacoes.insert(0, r)
              : _medicationsController.medicacoes[idx] = r;
          onSuccess();
        });
      }
    } catch (e) {
      onError(e.toString());
    }

    isLoading = false;
  }
}