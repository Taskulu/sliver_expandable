# Sliver Expandable

Sliver Expandable lets expand and collapse any Sliver in Flutter.

<img src="https://raw.githubusercontent.com/Taskulu/sliver_expandable/master/screenshots/1.webp" width="300" />

## Getting started

1. Add it to your `pubspec.yaml`:

```yaml
sliver_expandable: ^1.1.0
```

2. Use it:

```dart
AnimatedSliverExpandable(
  expanded: _expanded,
  headerBuilder: (context, animation) => ListTile(
    onTap: () => setState(() => _expanded = !_expanded),
    tileColor: Colors.amber,
    title: const Text('Expandable'),
    trailing: AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.rotate(
        angle: (animation.value - 0.5) * pi,
        child: child,
      ),
      child: const Icon(Icons.chevron_left),
    ),
  ),
  sliver: SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) => ListTile(
        title: Text('Expandable item no. $index'),
      ),
      childCount: 5,
    ),
  ),
),
```