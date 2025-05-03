import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prime/providers/task_provider.dart' as provider;

class AddTaskScreen extends StatefulWidget {
  final String projectId;

  const AddTaskScreen({super.key, required this.projectId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('افزودن وظیفه جدید'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان وظیفه',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفا عنوان وظیفه را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'توضیحات',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: const Text('تاریخ سررسید'),
              subtitle: Text(
                '${_dueDate.year}/${_dueDate.month}/${_dueDate.day}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final taskProvider = context.read<provider.TaskProvider>();
                  taskProvider.addTask(
                    provider.Task(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      dueDate: _dueDate,
                      projectId: widget.projectId,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('افزودن وظیفه'),
            ),
          ],
        ),
      ),
    );
  }
}