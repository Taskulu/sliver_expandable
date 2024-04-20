import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:sliver_expandable/sliver_expandable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliver Expandable Demo',
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          const SliverAppBar(
            expandedHeight: 160,
            stretch: true,
            pinned: true,
            centerTitle: false,
            title: Text('Title'),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) =>
                ListTile(title: Text('Before expandable item no. $index')),
            childCount: 5,
          )),
          AnimatedSliverExpandable(
            expanded: _expanded,
            headerBuilder: (context, animation) => ColoredBox(
              color: Colors.deepPurpleAccent,
              child: ListTile(
                onTap: () => setState(() => _expanded = !_expanded),
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
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    ListTile(title: Text('Expandable item no. $index')),
                childCount: 5,
              ),
            ),
          ),
          const StickyExpandableList(),
          SliverSafeArea(
            top: false,
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  ListTile(title: Text('After expandable item no. $index')),
              childCount: 10,
            )),
          ),
        ],
      ),
    );
  }
}

class StickyExpandableList extends StatefulWidget {
  const StickyExpandableList({super.key});

  @override
  State<StickyExpandableList> createState() => _StickyExpandableListState();
}

class _StickyExpandableListState extends State<StickyExpandableList>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250));
  late final _animation =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  bool _expandable = false;

  @override
  Widget build(BuildContext context) => SliverStickyHeader(
        header: ColoredBox(
          color: Colors.deepOrangeAccent,
          child: ListTile(
            onTap: () {
              _expandable = !_expandable;
              _controller.animateTo(_expandable ? 1 : 0);
            },
            title: const Text('Sticky Expandable'),
            trailing: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Transform.rotate(
                angle: (_animation.value - 0.5) * pi,
                child: child,
              ),
              child: const Icon(Icons.chevron_left),
            ),
          ),
        ),
        sliver: SliverExpandable(
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  ListTile(title: Text('Expandable item no. $index')),
              childCount: 10,
            ),
          ),
          animation: _animation,
        ),
      );
}
