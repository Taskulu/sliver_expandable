import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RenderSliverExpandable extends RenderSliver with RenderSliverHelpers {
  RenderSliverExpandable({
    required Animation<double> animation,
    required double maxTranslationOffset,
  }) : _maxTranslationOffset = maxTranslationOffset {
    this.animation = animation;
  }

  RenderBox? _header;

  RenderBox? get header => _header;

  set header(RenderBox? value) {
    if (_header != null) {
      dropChild(_header!);
    }
    _header = value;
    if (_header != null) {
      adoptChild(_header!);
    }
  }

  RenderSliver? _sliver;

  RenderSliver? get sliver => _sliver;

  set sliver(RenderSliver? value) {
    if (_sliver != null) {
      dropChild(_sliver!);
    }
    _sliver = value;
    if (_sliver != null) {
      adoptChild(_sliver!);
    }
  }

  Animation<double> get animation => _animation!;

  Animation<double>? _animation;

  set animation(Animation<double> value) {
    if (_animation == value) return;

    if (attached) _animation?.removeListener(markNeedsLayout);

    _animation = value;
    if (attached) animation.addListener(markNeedsLayout);

    markNeedsLayout();
  }

  double _maxTranslationOffset;

  double get maxTranslationOffset => _maxTranslationOffset;

  set maxTranslationOffset(double value) {
    if (value != maxTranslationOffset) {
      _maxTranslationOffset = value;
      markNeedsLayout();
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    animation.addListener(markNeedsLayout);
    if (header?.attached == false) header!.attach(owner);
    if (sliver?.attached == false) sliver!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    animation.removeListener(markNeedsLayout);
    if (header?.attached == true) header!.detach();
    if (sliver?.attached == true) sliver!.detach();
  }

  @override
  void redepthChildren() {
    if (header != null) redepthChild(header!);
    if (sliver != null) redepthChild(sliver!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (header != null) {
      visitor(header!);
    }
    if (sliver != null) {
      visitor(sliver!);
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  double get headerExtent {
    if (header == null) return 0;
    if (constraints.axis == Axis.vertical) return header!.size.height;
    return header!.size.width;
  }

  Offset get translationOffset {
    final currentOffset = (1 - animation.value) * _maxTranslationOffset;
    switch (constraints.axisDirection) {
      case AxisDirection.down:
        return Offset(0, -currentOffset);
      case AxisDirection.right:
        return Offset(-currentOffset, 0);
      case AxisDirection.up:
        return Offset(0, currentOffset);
      case AxisDirection.left:
        return Offset(currentOffset, 0);
    }
  }

  @override
  void performLayout() {
    assert(sliver != null);
    final boxConstraints = constraints.asBoxConstraints();
    header?.layout(boxConstraints, parentUsesSize: true);
    final resolvedHeaderExtent = headerExtent;
    final headerPaintExtent =
        calculatePaintOffset(constraints, from: 0, to: resolvedHeaderExtent);
    final headerCacheExtent =
        calculateCacheOffset(constraints, from: 0, to: resolvedHeaderExtent);
    sliver!.layout(
      constraints.copyWith(
        scrollOffset:
            math.max(0, constraints.scrollOffset - resolvedHeaderExtent),
        cacheOrigin:
            math.min(0, constraints.cacheOrigin + resolvedHeaderExtent),
        remainingPaintExtent:
            math.max(0, constraints.remainingPaintExtent - headerPaintExtent),
        remainingCacheExtent:
            math.max(0, constraints.remainingCacheExtent - headerCacheExtent),
        overlap: math.max(0, constraints.overlap - resolvedHeaderExtent),
        precedingScrollExtent:
            constraints.precedingScrollExtent + resolvedHeaderExtent,
      ),
      parentUsesSize: true,
    );
    final sliverGeometry = sliver!.geometry!;
    if (sliverGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(
          scrollOffsetCorrection: sliverGeometry.scrollOffsetCorrection);
      return;
    }

    final paintExtent = math.min(
      headerPaintExtent + (animation.value * sliverGeometry.paintExtent),
      constraints.remainingPaintExtent,
    );

    geometry = SliverGeometry(
      scrollExtent: resolvedHeaderExtent +
          (animation.value * sliverGeometry.scrollExtent),
      paintExtent: paintExtent,
      layoutExtent: math.min(
          headerPaintExtent + (animation.value * sliverGeometry.layoutExtent),
          paintExtent),
      cacheExtent: math.min(
          headerCacheExtent + (animation.value * sliverGeometry.cacheExtent),
          constraints.remainingCacheExtent),
      maxPaintExtent: resolvedHeaderExtent +
        (animation.value * sliverGeometry.maxPaintExtent),
      hitTestExtent:
          headerPaintExtent + animation.value * sliverGeometry.hitTestExtent,
      hasVisualOverflow:
          resolvedHeaderExtent > constraints.remainingPaintExtent ||
              constraints.scrollOffset > 0 ||
              sliverGeometry.hasVisualOverflow,
    );

    final Offset headerPaintOffset, sliverPaintOffset;
    switch (constraints.axisDirection) {
      case AxisDirection.down:
        headerPaintOffset = Offset(0, -constraints.scrollOffset);
        sliverPaintOffset = Offset(0, headerPaintExtent);
        break;
      case AxisDirection.right:
        headerPaintOffset = Offset(-constraints.scrollOffset, 0);
        sliverPaintOffset = Offset(headerPaintExtent, 0);
        break;
      case AxisDirection.up:
        headerPaintOffset = Offset(
            0,
            constraints.remainingPaintExtent -
                resolvedHeaderExtent +
                constraints.scrollOffset);
        sliverPaintOffset = Offset.zero;
        break;
      case AxisDirection.left:
        headerPaintOffset = Offset(
            constraints.remainingPaintExtent -
                resolvedHeaderExtent +
                constraints.scrollOffset,
            0);
        sliverPaintOffset = Offset.zero;
        break;
    }
    if (header != null) {
      getChildParentData(header!).paintOffset = headerPaintOffset;
    }
    getChildParentData(sliver!).paintOffset =
        sliverPaintOffset + translationOffset;
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    final childParentData = child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      assert(sliver != null);
      if (header != null) {
        context.paintChild(
            header!, offset + getChildParentData(header!).paintOffset);
      }
      if (sliver != null && isSliverVisible) {
        final sliverOffset = offset + getChildParentData(sliver!).paintOffset;
        if (animation.value == 1) {
          context.paintChild(sliver!, sliverOffset);
        } else {
          context.pushClipRect(
            needsCompositing,
            sliverOffset,
            -translationOffset &
                Size(
                    constraints.crossAxisExtent, sliver!.geometry!.paintExtent),
            (context, offset) => context.pushOpacity(
              offset,
              lerpDouble(0, 255, animation.value)!.toInt(),
              (context, offset) => context.paintChild(sliver!, offset),
            ),
          );
        }
      }
    }
  }

  bool get isSliverVisible {
    assert(sliver != null);
    assert(sliver!.geometry != null);

    return animation.value > 0 && sliver!.geometry!.visible;
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    assert(geometry!.hitTestExtent > 0);
    final double headerPosition = -constraints.scrollOffset;

    if (header != null && (mainAxisPosition - headerPosition) <= headerExtent) {
      final didHitHeader = hitTestBoxChild(
        BoxHitTestResult.wrap(SliverHitTestResult.wrap(result)),
        header!,
        mainAxisPosition:
            mainAxisPosition - childMainAxisPosition(header!) - headerPosition,
        crossAxisPosition: crossAxisPosition,
      );
      return didHitHeader;
    } else if (sliver != null && sliver!.geometry!.hitTestExtent > 0) {
      return sliver!.hitTest(result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(sliver!),
          crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderObject? child) {
    if (child == header) {
      return -(constraints.scrollOffset + constraints.overlap);
    }
    if (child == sliver) {
      return calculatePaintOffset(constraints, from: 0, to: headerExtent);
    }
    return 0;
  }

  SliverPhysicalParentData getChildParentData(RenderObject child) =>
      child.parentData as SliverPhysicalParentData;
}
