import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseFormData {
  String category;
  double amount;
  DateTime date;
  String note;

  ExpenseFormData({
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });
}

class ExpenseForm extends StatefulWidget {
  final ExpenseFormData initial;
  final void Function(ExpenseFormData) onSave;
  final VoidCallback? onCancel;

  const ExpenseForm({
    Key? key,
    required this.initial,
    required this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late String _note;
  late double _amount;
  late DateTime _date;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _category = widget.initial.category;
    _note = widget.initial.note;
    _amount = widget.initial.amount;
    _date = widget.initial.date;
    _dateController = TextEditingController(text: DateFormat.yMd().format(_date));
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat.yMd().format(_date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(
          initialValue: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            hintText: 'e.g. Food',
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter a category' : null,
          onSaved: (v) => _category = v!.trim(),
        ),
        TextFormField(
          initialValue: _amount == 0 ? '' : _amount.toStringAsFixed(2),
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            final cleaned = v?.replaceAll(',', '') ?? '';
            if (cleaned.isEmpty) return 'Enter amount';
            final val = double.tryParse(cleaned);
            if (val == null || val <= 0) return 'Enter a valid amount';
            return null;
          },
          onSaved: (v) => _amount = double.parse(v!.replaceAll(',', '')),
        ),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Date'),
          onTap: _pickDate,
        ),
        TextFormField(
          initialValue: _note,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
          onSaved: (v) => _note = v?.trim() ?? '',
        ),
        const SizedBox(height: 12),
        Row(children: [
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSave(ExpenseFormData(
                    category: _category,
                    amount: _amount,
                    date: _date,
                    note: _note,
                  ));
                }
              },
              child: const Text('Save')),
          const SizedBox(width: 8),
          if (widget.onCancel != null)
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel'))
        ])
      ]),
    );
  }
}
