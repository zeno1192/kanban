import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

const appTitle = 'clasroom ToDo';

final _lanes = <({String title, String label, Color color})>[
  (title: '📝 未着手 (To Do)', label: '未着手', color: Colors.blue.shade50),
  (title: '🔨 作業中 (Doing)', label: '作業中', color: Colors.orange.shade50),
  (title: '✅ 完了 (Done)', label: '完了', color: Colors.green.shade50),
  (title: '☠️諦めた', label: '諦めた', color: Colors.grey.shade50),
];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;
  const KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();
  final boardScrollController = ScrollController();

  void add() {
    widget.vm.add(input.text);
    input.clear();
  }

  Future<void> edit(Task t) async {
    var text = t.title;
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('タスクを編集'),
        content: TextFormField(
          initialValue: text,
          autofocus: true,
          onChanged: (v) => text = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, text),
            child: Text('保存'),
          ),
        ],
      ),
    );
    if (result != null) widget.vm.rename(t, result);
  }

  Widget taskCard(Task t) {
    final s = t.status;
    final buttons = Wrap(spacing: 4, children: [
      if (s > 0)
        TextButton(
          onPressed: () => widget.vm.move(t, s - 1),
          child: Text('← ${_lanes[s - 1].label}へ'),
        ),
      if (s < _lanes.length - 1)
        FilledButton(
          onPressed: () => widget.vm.move(t, s + 1),
          child: Text('${_lanes[s + 1].label}へ →'),
        ),
      if (s + 1 < Task.abandonedStatus)
        TextButton(
          onPressed: () => widget.vm.move(t, Task.abandonedStatus),
          child: const Text('諦める'),
        ),
    ]);
     return Card(child: ListTile(
      title: Text(t.title),
      subtitle: buttons,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => edit(t),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline),
          onPressed: () => widget.vm.remove(t),
        ),
      ]),
    ));
  }

  Widget lane(int s) {
    final cards = [
      for (final t in widget.vm.tasks)
        if (t.status == s) taskCard(t),
    ];
    return SizedBox(
      width: 300,
      child: Card(
        color: _lanes[s].color,
        child: Column(children: [
          ListTile(
            title: Text(_lanes[s].title),
            trailing: Text('${cards.length}件'),
          ),
          Expanded(child: ListView(children: cards)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    boardScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: input,
      decoration: InputDecoration(
        labelText: '新しいタスク',
        hintText: '例：レポートを書く',
        border: OutlineInputBorder(),
      ),
    );
    final button = ValueListenableBuilder(
      valueListenable: input,
      builder: (context, value, child) => FilledButton.icon(
        onPressed: value.text.isEmpty ? null : add,
        icon: Icon(Icons.add),
        label: Text('未着手に追加'),
      ),
    );
    final entry = Card(child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(children: [
        field,
        Align(alignment: Alignment.centerRight, child: button),
      ]),
    ));
    final board = Scrollbar(
      controller: boardScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListenableBuilder(
        listenable: widget.vm,
        builder: (context, child) => ListView.builder(
          controller: boardScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _lanes.length,
          itemBuilder: (context, status) => lane(status),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(appTitle)),
      body: Column(children: [
        entry,
        Expanded(child: board),
      ]),
    );
  }
}
