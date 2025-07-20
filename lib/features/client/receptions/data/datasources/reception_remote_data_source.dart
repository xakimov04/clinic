import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/receptions/data/models/reception_client_model.dart';
import 'package:clinic/features/client/receptions/data/models/reception_info_model.dart';
import 'package:clinic/features/client/receptions/data/models/reception_list_model.dart';

abstract class ReceptionRemoteDataSource {
  Future<List<ReceptionClientModel>> getReceptionsClient();
  Future<List<ReceptionListModel>> getReceptionsList(String id);
  Future<List<ReceptionInfoModel>> getReceptionsInfo(String id);
}

class ReceptionRemoteDataSourceImpl implements ReceptionRemoteDataSource {
  final NetworkManager networkManager;

  ReceptionRemoteDataSourceImpl(this.networkManager);

  @override
  Future<List<ReceptionClientModel>> getReceptionsClient() async {
    final result = await networkManager.fetchData(url: "employees-client/");
    final data = result['data'];

    if (data == null || data is! List) return [];

    return data.map((json) => ReceptionClientModel.fromJson(json)).toList();
  }

  @override
  Future<List<ReceptionListModel>> getReceptionsList(String id) async {
    final result =
        await networkManager.fetchData(url: "reception-list/?employee_id=$id");
    final data = result['data'];

    if (data == null || data is! List) return [];

    return data.map((json) => ReceptionListModel.fromJson(json)).toList();
  }

  @override
  Future<List<ReceptionInfoModel>> getReceptionsInfo(String id) async {
    final result =
        await networkManager.fetchData(url: "reception-info/?guid=$id");
    final data = result['data'];

    if (data == null || data is! List) return [];

    return data.map((json) => ReceptionInfoModel.fromJson(json)).toList();
  }
}
