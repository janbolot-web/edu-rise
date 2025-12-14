// Utilities to build flattened list of items (stage headers + module nodes)

enum ItemType { stageHeader, moduleNode }

class LessonTreeItem {
  final ItemType type;
  final int stageIndex;
  final int? moduleIndex;
  final int? nodeIndex;

  LessonTreeItem.stageHeader(this.stageIndex)
      : type = ItemType.stageHeader,
        moduleIndex = null,
        nodeIndex = null;

  LessonTreeItem.moduleNode({required this.stageIndex, required this.moduleIndex, required this.nodeIndex}) : type = ItemType.moduleNode;
}

class LessonTreeBuilder {
  // Accepts a subject object (domain entity or dynamic) and returns flattened items
  static List<LessonTreeItem> build(dynamic subject) {
    if (subject == null) return const [];
    final List<LessonTreeItem> items = [];
    int nodeCounter = 0;
    // Defensive: expect subject.stages as List
    final stages = subject.stages as List?;
    if (stages == null) return items;

    for (var si = 0; si < stages.length; si++) {
      items.add(LessonTreeItem.stageHeader(si));
      final mods = stages[si].modules as List?;
      if (mods == null) continue;
      for (var mi = 0; mi < mods.length; mi++) {
        items.add(LessonTreeItem.moduleNode(stageIndex: si, moduleIndex: mi, nodeIndex: nodeCounter));
        nodeCounter++;
      }
    }

    return items;
  }
}
