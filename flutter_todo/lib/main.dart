import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: TodoPage()),
);

class TodoItem {
  const TodoItem(this.id, this.title);
  final int id;
  final String title;
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final todos = [
    const TodoItem(1, 'Повторить Navigator'),
    const TodoItem(2, 'Подготовить презентацию'),
  ];
  int nextId = 3;

  Future<void> openAddPage() async {
    final title = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (context) => const AddTodoPage()),
    );
    if (!mounted || title == null) return;
    setState(() {
      todos.add(TodoItem(nextId++, title));
    });
  }

  Future<void> deleteTodo(TodoItem todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text(todo.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      todos.removeWhere((item) => item.id == todo.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Список задач')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: todos.isEmpty
                  ? const Center(child: Text('Пока нет задач'))
                  : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return Slidable(
                          key: ValueKey(todo.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => deleteTodo(todo),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Удалить',
                              ),
                            ],
                          ),
                          child: ListTile(title: Text(todo.title)),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: openAddPage,
                  child: const Text('Добавить'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final controller = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    final title = controller.text.trim();
    if (title.isEmpty) {
      setState(() {
        errorText = 'Введите название';
      });
      return;
    }
    Navigator.of(context).pop<String>(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая задача')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Название',
                errorText: errorText,
              ),
              onSubmitted: (_) => save(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: save, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}
