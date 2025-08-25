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
    final result = await networkManager.fetchData(url: "employees-client-v2/");
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

    if (data == null) return [];

    return _parseReceptionInfoData(data);
  }

  List<ReceptionInfoModel> _parseReceptionInfoData(dynamic data) {
    try {
      if (data is List) {
        return data
            .where((item) => item != null)
            .map((json) =>
                ReceptionInfoModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Agar data Map bo'lsa - uni List ichiga o'rab qaytarish
      if (data is Map<String, dynamic>) {
        return [ReceptionInfoModel.fromJson(data)];
      }

      // Boshqa data type'lar uchun bo'sh list
      return [];
    } catch (e) {
      // Parsing xatoligi bo'lsa, log qilib bo'sh list qaytarish
      print('Error parsing reception info data: $e');
      return [];
    }
  }
}
