import '../../models/ramayan_item.dart';
import '../../models/status_category.dart';
import '../../models/status_quote.dart';
import '../../services/firestore_service.dart';
import '../../services/status_service.dart';

/// RemoteDataSource wraps remote Firestore queries for categories, quotes, items,
/// and image URL configurations.
class RemoteDataSource {
  final StatusService _statusService;
  final FirestoreService _firestoreService;

  RemoteDataSource({
    StatusService? statusService,
    FirestoreService? firestoreService,
  })  : _statusService = statusService ?? StatusService(),
        _firestoreService = firestoreService ?? FirestoreService();

  Future<List<StatusCategory>> fetchCategories(String language) async {
    return await _statusService.fetchCategories(language, forceRefresh: true);
  }

  Future<List<StatusQuote>> fetchQuotes(String language,
      {String? categoryId}) async {
    return await _statusService.fetchQuotes(language,
        categoryId: categoryId, forceRefresh: true);
  }

  Future<List<String>> fetchImageUrls() async {
    return await _statusService.fetchImageUrls(forceRefresh: true);
  }

  Future<List<RamayanItem>> fetchRamayanItems(
      String language, String categoryId) async {
    return await _firestoreService.getCategoryItems(language, categoryId,
        forceRefresh: true);
  }
}
