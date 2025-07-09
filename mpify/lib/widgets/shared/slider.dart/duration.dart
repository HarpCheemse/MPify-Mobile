import 'package:flutter/material.dart';
import 'package:mpify/models/audio_models.dart';
import 'package:provider/provider.dart';

class DurationSlider extends StatefulWidget {
  final double? width;
  final double height;
  final double value;
  final Color baseColor;
  final Color progressColor;
  final Color hoverColor;
  final Color thumbColor;
  final double thumbSize;
  final ValueChanged<double> onChanged;

  const DurationSlider({
    super.key,
    this.width,
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
  State<DurationSlider> createState() => _DurationSliderState();
}

class _DurationSliderState extends State<DurationSlider> {
  bool _hovering = false;
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
          child: Consumer<AudioModels>(
            builder: (context, value, child) {
              final totalSecond = value.songDuration.inSeconds;
              final currentSecond = value.songProgress.inSeconds;

              return Slider(
                value: currentSecond.toDouble().clamp(0, totalSecond.toDouble() ),
                min: 0,
                max: totalSecond > 0 ? totalSecond.toDouble() : 1,
                onChanged: (newValue) {
                  context.read<AudioModels>().seek(Duration(seconds: newValue.toInt()));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
