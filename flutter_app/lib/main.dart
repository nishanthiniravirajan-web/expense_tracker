// Main Flutter app implementing the expense tracker
import 'package:flutter/material.dart';
import 'models/expense.dart';
import 'widgets/expense_tile.dart';
import 'widgets/expense_form.dart';
import 'services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({Key? key}) : super(key: key);

  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final StorageService storage = StorageService();
  final uuid = const Uuid();
  String filterMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Pre-fill with a small sample for easy testing
    storage.add(Expense(id: uuid.v4(), category: 'Food', amount: 250.5, date: DateTime.now(), note: 'Lunch'));
    storage.add(Expense(id: uuid.v4(), category: 'Transport', amount: 120.0, date: DateTime.now(), note: 'Taxi'));
  }

  List<Expense> get _expenses => storage.getAll();

  double get monthlyTotal {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    // sum current month's values for demo; in production allow choosing month
    return _expenses.where((e) => e.date.year == year && e.date.month == month).fold(0.0, (s, e) => s + e.amount);
  }

  void _addExpense(ExpenseFormData data) {
    final newExpense = Expense(id: uuid.v4(), category: data.category, amount: data.amount, date: data.date, note: data.note);
    setState(() => storage.add(newExpense));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added')));
  }

  void _editExpense(String id, ExpenseFormData data) {
    final updated = Expense(id: id, category: data.category, amount: data.amount, date: data.date, note: data.note);
    setState(() => storage.update(id, updated));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense updated')));
  }

  void _deleteExpense(String id) {
    setState(() => storage.delete(id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted')));
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: SingleChildScrollView(
          child: ExpenseForm(
            initial: ExpenseFormData(category: '', amount: 0.0, date: DateTime.now(), note: ''),
            onSave: (d) {
              Navigator.of(context).pop();
              _addExpense(d);
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: SingleChildScrollView(
          child: ExpenseForm(
            initial: ExpenseFormData(category: expense.category, amount: expense.amount, date: expense.date, note: expense.note),
            onSave: (d) {
              Navigator.of(context).pop();
              _editExpense(expense.id, d);
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _expenses.toList()..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: isWide
              ? Row(children: [Expanded(child: _buildList()), SizedBox(width: 360, child: _buildSummary())])
              : Column(children: [Expanded(child: _buildList()), const SizedBox(height: 12), _buildSummary()]),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Add expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList() {
    final items = _expenses.toList()..sort((a, b) => b.date.compareTo(a.date));
    if (items.isEmpty) return const Center(child: Text('No expenses yet. Tap + to add.'));

    return Card(
      elevation: 2,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final e = items[index];
          return ExpenseTile(expense: e, onEdit: () => _showEditDialog(e), onDelete: () => _confirmDelete(e));
        },
      ),
    );
  }

  void _confirmDelete(Expense e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Remove "${e.category}" of ₹${e.amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteExpense(e.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final df = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Total this month', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(df.format(monthlyTotal), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Quick category totals
          const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ElevatedButton(onPressed: () => _quickAdd('Food'), child: const Text('Add Food')),
            ElevatedButton(onPressed: () => _quickAdd('Transport'), child: const Text('Add Transport')),
            ElevatedButton(onPressed: () => _quickAdd('Utilities'), child: const Text('Add Utilities')),
          ])
        ]),
      ),
    );
  }

  void _quickAdd(String category) {
    final now = DateTime.now();
    final prefilled = ExpenseFormData(category: category, amount: 0.0, date: now, note: '');
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Quick add — $category'),
        content: ExpenseForm(
          initial: prefilled,
          onSave: (d) {
            Navigator.of(c).pop();
            _addExpense(d);
          },
          onCancel: () => Navigator.of(c).pop(),
        ),
      ),
    );
  }
}

