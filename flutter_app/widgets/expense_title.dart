import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseTile({Key? key, required this.expense, required this.onEdit, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${df.format(expense.date)} • ${expense.note}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('₹${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit, tooltip: 'Edit expense'),
        IconButton(icon: const Icon(Icons.delete), onPressed: onDelete, tooltip: 'Delete expense', color: Theme.of(context).colorScheme.error),
      ]),
    );
  }
}
