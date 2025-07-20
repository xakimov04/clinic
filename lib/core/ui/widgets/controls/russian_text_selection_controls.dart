import 'package:flutter/material.dart';

class RussianContextMenu {
  static Widget build(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final value = editableTextState.textEditingValue;
    final hasSelection = !value.selection.isCollapsed;

    // Material kontekst-menyu anchor nuqtalari
    final anchors = editableTextState.contextMenuAnchors;
    final Offset anchorAbove = anchors.primaryAnchor;
    final Offset anchorBelow = anchors.secondaryAnchor ?? anchorAbove;

    return TextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      children: [
        if (hasSelection)
          TextSelectionToolbarTextButton(
            padding: const EdgeInsets.all(8),
            onPressed: () {
              editableTextState.copySelection(SelectionChangedCause.toolbar);
              editableTextState.hideToolbar();
            },
            child: const Text('Копировать'),
          ),
        // 🛠 Правильно: передаём только enum, не String
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8),
          onPressed: () {
            editableTextState.pasteText(SelectionChangedCause.toolbar);
            editableTextState.hideToolbar();
          },
          child: const Text('Вставить'),
        ),
        if (hasSelection)
          TextSelectionToolbarTextButton(
            padding: const EdgeInsets.all(8),
            onPressed: () {
              editableTextState.cutSelection(SelectionChangedCause.toolbar);
              editableTextState.hideToolbar();
            },
            child: const Text('Вырезать'),
          ),
        if (hasSelection)
          TextSelectionToolbarTextButton(
            padding: const EdgeInsets.all(8),
            onPressed: () {
              editableTextState.selectAll(SelectionChangedCause.toolbar);
              editableTextState.hideToolbar();
            },
            child: const Text('Выбрать всё'),
          ),
      ],
    );
  }
}
