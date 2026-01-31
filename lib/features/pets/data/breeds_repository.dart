import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';
import '../domain/breed_model.dart';

final breedsRepositoryProvider = Provider<BreedsRepository>((ref) {
  final http = ref.watch(httpServiceProvider);
  return BreedsRepository(http);
});

class BreedsRepository {
  final HttpService _http;
  BreedsRepository(this._http);

  Future<List<DogBreed>> listBreeds({String? q}) async {
    final res = await _http.get(
      '/dicts/dog-breeds',
      queryParameters: q == null || q.isEmpty ? null : {'q': q},
    );
    final data = Map<String, dynamic>.from(res.data);
    final list = (data['data'] as List).cast<Map<String, dynamic>>();
    return list.map(DogBreed.fromJson).toList();
  }
}

