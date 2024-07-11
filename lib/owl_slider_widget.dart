import 'dart:math';

import 'package:flutter/material.dart';

/**
 * Created by Bekhruz Makhmudov on 11/07/24.
 * Project owl_slider
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ValueChangedCallback = void Function(int value);

class OwlSliderWidget extends StatefulWidget {
  const OwlSliderWidget({
    super.key,
    this.stepCount = 10,
    this.currentStepValue = 1,
    this.minStepValue = 1,
    required this.onValueChanged,
    required this.availableSpace,
  });

  final int stepCount;
  final int currentStepValue;
  final int minStepValue;
  final double sliderHeight = 60;
  final double stepIndicatorWidth = 4;
  final double availableSpace;
  final ValueChangedCallback onValueChanged;

  @override
  State<OwlSliderWidget> createState() => _OwlSliderWidgetState();
}

class _OwlSliderWidgetState extends State<OwlSliderWidget> {
  static double _horizontalPadding = 15;
  static double _verticalPadding = 18;
  static double _infoWidgetWidth = 40;
  static double _infoWidgetHeight = 70;

  double minWidthForSlider = 1;
  double maxWidthForSlider = 2;

  double sliderValueWidth = 1;
  int currentStep = 1;

  double getStepWidthFor(int forStep) {
    return forStep *
        (widget.availableSpace - _horizontalPadding * 2) /
        widget.stepCount;
  }

  int getStep(double forWidth) {
    return min(
        (forWidth /
            (widget.availableSpace - _horizontalPadding * 2) *
                widget.stepCount)
            .floor(),
        widget.stepCount);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        minWidthForSlider = getStepWidthFor(widget.minStepValue);
        maxWidthForSlider = getStepWidthFor(widget.stepCount + 1);
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          currentStep = widget.currentStepValue;
          sliderValueWidth = getStepWidthFor(currentStep);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          final newWidth = sliderValueWidth + details.delta.dx;
          if (newWidth < minWidthForSlider ||
              newWidth > maxWidthForSlider ||
              (currentStep == widget.stepCount && details.delta.dx > 0)) {
            return;
          }
          final newStep = getStep(newWidth);
          if (newStep < widget.minStepValue) {
            return;
          }
          bool valueChanged = newStep != currentStep;
          if (valueChanged) {
            HapticFeedback.mediumImpact();
          }
          currentStep = newStep;
          sliderValueWidth = newWidth;
          if (valueChanged) {
            widget.onValueChanged(currentStep);
          }
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          final newStep = max(getStep(sliderValueWidth), widget.minStepValue);
          currentStep = newStep;
          widget.onValueChanged(currentStep);
          sliderValueWidth = getStepWidthFor(currentStep);
        });
      },
      child: Container(
        height: 190,
        padding: EdgeInsets.symmetric(
            horizontal: _horizontalPadding, vertical: _verticalPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color.fromRGBO(245, 245, 245, 1),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: widget.sliderHeight,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(11, 11, 11, .05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i <= widget.stepCount; i++) ...{
                      Container(
                        width: widget.stepIndicatorWidth,
                        height: widget.sliderHeight * .6,
                        decoration: BoxDecoration(
                          color: (i == 0 || i == widget.stepCount)
                              ? Colors.transparent
                              : Color.fromRGBO(11, 11, 11, .2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    }
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 100),
                width: sliderValueWidth,
                height: widget.sliderHeight,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 102, 249, 1),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16),
                    right: currentStep == widget.stepCount
                        ? Radius.circular(16)
                        : Radius.zero,
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 100),
              bottom: currentStep == widget.stepCount ? 4 : 0,
              left: currentStep == widget.stepCount
                  ? sliderValueWidth - widget.stepIndicatorWidth
                  : sliderValueWidth,
              width: widget.stepIndicatorWidth,
              height: widget.sliderHeight + 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(219, 242, 76, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 100),
              bottom: widget.sliderHeight + 20,
              left: currentStep == widget.stepCount
                  ? sliderValueWidth - _infoWidgetWidth
                  : sliderValueWidth - (_infoWidgetWidth / 2),
              width: _infoWidgetWidth,
              height: _infoWidgetHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(219, 242, 76, 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStep.toString(),
                        softWrap: true,
                        style: TextStyle(
                          color: Color.fromRGBO(11, 11, 11, 1),
                          fontWeight: FontWeight.w500,
                          fontSize: 28,
                          height: 1,
                        ),
                      ),
                      Text(
                        "reps",
                        style: TextStyle(
                          color: Color.fromRGBO(11, 11, 11, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
