import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sliver_expandable/sliver_expandable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
            title: Text('Title'),
            centerTitle: false,
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              title: Text('Before expandable item no. $index'),
            ),
            childCount: 5,
          )),
          AnimatedSliverExpandable(
            headerBuilder: (context, animation, onToggle) => ListTile(
              onTap: onToggle,
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
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              title: Text('After expandable item no. $index'),
            ),
            childCount: 5,
          )),
        ],
      ),
    );
  }
}
