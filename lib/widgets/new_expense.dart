import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseData() {
    final enteredCost = double.tryParse(_costController.text);
    final costIsInvalid = enteredCost == null || enteredCost <= 0;
    if (_titleController.text.trim().isEmpty ||
        costIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ongeldige input'),
          content: const Text('check of alles correct is ingevuld'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('ok'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onAddExpense(Expense(
        title: _titleController.text,
        amount: enteredCost,
        date: _selectedDate!,
        category: _selectedCategory));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            maxLength: 50,
            decoration: const InputDecoration(
              label: Text('title'),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: _costController,
                  decoration: const InputDecoration(
                    prefixText: '€ ',
                    label: Text('cost'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'kies een datum'
                          : formatter.format(
                              _selectedDate!,
                            ),
                    ),
                    IconButton(
                        onPressed: _presentDatePicker,
                        icon: const Icon(
                          Icons.calendar_month,
                        )),
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              DropdownButton(
                value: _selectedCategory,
                items: Category.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category.name.toUpperCase(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submitExpenseData,
                child: const Text('Save expense'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
