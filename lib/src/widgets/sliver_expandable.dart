import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_expandable/src/rendering/render_sliver_expandable.dart';

typedef SliverExpandableHeaderBuilder = Widget Function(
    BuildContext context, Animation<double> animation, VoidCallback onToggle);

class AnimatedSliverExpandable extends StatefulWidget {
  final Widget sliver;
  final SliverExpandableHeaderBuilder headerBuilder;
  final Duration duration;
  final Curve curve;
  final double translationOffset;

  const AnimatedSliverExpandable({
    super.key,
    required this.headerBuilder,
    required this.sliver,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.translationOffset = 200,
  });

  @override
  State<AnimatedSliverExpandable> createState() =>
      _AnimatedSliverExpandableState();
}

class _AnimatedSliverExpandableState extends State<AnimatedSliverExpandable>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this);

  void _onToggle() {
    if (controller.status == AnimationStatus.completed ||
        controller.status == AnimationStatus.forward) {
      controller.animateBack(0, duration: widget.duration);
    } else {
      controller.animateTo(1, duration: widget.duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final curvedAnimation =
        CurvedAnimation(curve: widget.curve, parent: controller);
    return SliverExpandable(
      animation: curvedAnimation,
      header: widget.headerBuilder(context, curvedAnimation, _onToggle),
      sliver: widget.sliver,
    );
  }
}

class WithStateAnimatedSliverExpandable extends StatefulWidget {
  final Widget sliver;
  final Duration duration;
  final Curve curve;
  final double translationOffset;
  final bool collapsed;

  const WithStateAnimatedSliverExpandable({
    super.key,
    required this.sliver,
    required this.collapsed,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.translationOffset = 200,
  });

  @override
  State<WithStateAnimatedSliverExpandable> createState() =>
      _WithStateAnimatedSliverExpandableState();
}

class _WithStateAnimatedSliverExpandableState
    extends State<WithStateAnimatedSliverExpandable>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this);

  void _onCollapsedChange() {
    if (widget.collapsed) {
      controller.animateTo(1, duration: widget.duration);
    } else {
      controller.animateBack(0, duration: widget.duration);
    }
  }

  @override
  void didUpdateWidget(covariant WithStateAnimatedSliverExpandable oldWidget) {
    if (oldWidget.collapsed != widget.collapsed) _onCollapsedChange();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      curve: widget.curve,
      parent: controller,
    );

    return SliverExpandable(
      animation: curvedAnimation,
      header: const SizedBox(),
      sliver: widget.sliver,
    );
  }
}

class SliverExpandable extends RenderObjectWidget {
  final Animation<double> animation;
  final Widget? header;
  final Widget sliver;
  final double translationOffset;

  const SliverExpandable({
    super.key,
    this.header,
    required this.sliver,
    required this.animation,
    this.translationOffset = 200,
  });

  @override
  RenderSliver createRenderObject(BuildContext context) =>
      RenderSliverExpandable(
          animation: animation, maxTranslationOffset: translationOffset);

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverExpandable renderObject) {
    renderObject.animation = animation;
    renderObject.maxTranslationOffset = translationOffset;
  }

  @override
  RenderObjectElement createElement() => RenderSliverExpandableElement(this);
}

class RenderSliverExpandableElement extends RenderObjectElement {
  RenderSliverExpandableElement(super.widget);

  @override
  SliverExpandable get widget => super.widget as SliverExpandable;

  Element? _header;

  Element? _sliver;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_sliver != null) visitor(_sliver!);
  }

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
    if (child == _header) _header = null;
    if (child == _sliver) _sliver = null;
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _header = updateChild(_header, widget.header, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  void update(SliverExpandable newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _header = updateChild(_header, widget.header, 0);
    _sliver = updateChild(_sliver, widget.sliver, 1);
  }

  @override
  void insertRenderObjectChild(RenderObject child, int? slot) {
    final renderObject = this.renderObject as RenderSliverExpandable;
    if (slot == 0) renderObject.header = child as RenderBox;
    if (slot == 1) renderObject.sliver = child as RenderSliver;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, oldSlot, newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, slot) {
    final renderObject = this.renderObject as RenderSliverExpandable;
    if (renderObject.header == child) renderObject.header = null;
    if (renderObject.sliver == child) renderObject.sliver = null;
  }
}
