// Placeholder in-memory storage. Replace with localStorage / IndexedDB when needed.
import '../models/expense.dart';

class StorageService {
  final List<Expense> _list = [];
  List<Expense> getAll() => List.unmodifiable(_list);

  void add(Expense e) {
    _list.add(e);
  }

  void update(String id, Expense updated) {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx >= 0) _list[idx] = updated;
  }

  void delete(String id) {
    _list.removeWhere((e) => e.id == id);
  }
}
