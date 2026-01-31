import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/http_service.dart';
import '../domain/home_feed_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final http = ref.watch(httpServiceProvider);
  return HomeRepository(http);
});

class HomeRepository {
  final HttpService _http;
  HomeRepository(this._http);

  Future<HomeFeed> getHome() async {
    final res = await _http.get('/home');
    return HomeFeed.fromJson(Map<String, dynamic>.from(res.data));
  }
}

