import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Center(
            child: Dock(
              items: const [
                Icons.person,
                Icons.message,
                Icons.call,
                Icons.camera,
                Icons.photo,
              ],
              builder: (e) {
                return Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        Colors.primaries[e.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(e, color: Colors.white)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Dock of the re-order-able [items].
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<IconData> items;
  final Widget Function(IconData) builder;

  @override
  State<Dock> createState() => _DockState();
}

/// State of the [Dock] used to manipulate the [_items].

class _DockState extends State<Dock> {
  late final List<IconData> _items = widget.items.toList();
  ValueNotifier isDragging = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDragging,
      builder: (context, __, ___) {
        return DragTarget<IconData>(
          builder: (context, candidateItems, rejectedItems) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black12,
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _items.map(_item).toList(),
              ),
            );
          },
          onLeave: (data) {
            isDragging.value = true;
          },
          onAcceptWithDetails: (data) {
            isDragging.value = false;
          },
          onWillAcceptWithDetails: (data) {
            isDragging.value = false;
            return true;
          },
        );
      },
    );
  }

  Widget _item(IconData item) => Draggable<IconData>(
        data: item,
        dragAnchorStrategy: childDragAnchorStrategy,
        childWhenDragging: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: isDragging.value ? 0 : 48,
          height: 48,
          margin: isDragging.value
              ? EdgeInsets.zero
              : const EdgeInsets.only(right: 16),
        ),
        maxSimultaneousDrags: 1,
        onDragEnd: (details) {
          isDragging.value = false;
        },
        feedback: widget.builder(item),
        child: widget.builder(item),
      );
}
