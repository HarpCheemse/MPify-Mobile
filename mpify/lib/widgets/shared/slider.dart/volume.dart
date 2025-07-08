import 'package:flutter/material.dart';

import 'package:mpify/utils/audio_ultis.dart';

class VolumeSlider extends StatefulWidget {
  final double width;
  final double height;
  final double value;
  final Color baseColor;
  final Color progressColor;
  final Color hoverColor;
  final Color thumbColor;
  final double thumbSize;
  final ValueChanged<double> onChanged;

  const VolumeSlider({
    super.key,
    required this.width,
    required this.height,
    required this.value,
    required this.baseColor,
    required this.progressColor,
    required this.hoverColor,
    required this.thumbColor,
    required this.thumbSize,
    required this.onChanged,
  });

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  late double _value;
  bool _hovering = false;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        width: widget.width,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _hovering
                ? widget.hoverColor
                : widget.progressColor,
            inactiveTrackColor: widget.baseColor,
            thumbColor: widget.thumbColor,
            thumbShape: _hovering
                ? RoundSliderThumbShape(enabledThumbRadius: widget.thumbSize)
                : SliderComponentShape.noThumb,
            trackHeight: widget.height,
          ),

          child: Slider(
            value: _value,
            min: 0,
            max: 100,
            onChanged: (newValue) {
              setState(() {
                _value = newValue;
              });
              widget.onChanged(newValue);
              AudioUtils.setVolume(newValue/100);
            },
          ),
        ),
      ),
    );
  }
}
