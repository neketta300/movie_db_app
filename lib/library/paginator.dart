class PaginatorLoadResult<T> {
  final List<T> data;
  final int currentPage;
  final int totalPage;
  PaginatorLoadResult({
    required this.data,
    required this.currentPage,
    required this.totalPage,
  });
}

// создание нового типа с названием PaginatorLoad<T> - хранит в себе функцию
typedef PaginatorLoad<T> = Future<PaginatorLoadResult<T>> Function(int);

class Paginator<T> {
  final _data = <T>[];
  late int _currentPage;
  late int _totalPage;
  var _isLoadingInProgres = false;
  final PaginatorLoad<T> load;

  List<T> get data => _data;

  Paginator(this.load);
  // отчищаем пагинаттор
  Future<void> reset() async {
    _currentPage = 0;
    _totalPage = 1;
    _data.clear();
    await loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (_isLoadingInProgres || _currentPage >= _totalPage) return;
    _isLoadingInProgres = true;
    final nextPage = _currentPage + 1;

    try {
      final result = await load(nextPage);
      _data.addAll(result.data);
      _currentPage = result.currentPage;
      _totalPage = result.totalPage;

      _isLoadingInProgres = false;
    } catch (e) {
      print('ОШИБКА: $e');
      _isLoadingInProgres = false;
    }
  }
}
