import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioTimeInput extends StatefulWidget {
  final Duration duration;
  final Function(Duration, Duration) onManualTimeSet;

  const AudioTimeInput({
    super.key,
    required this.duration,
    required this.onManualTimeSet,
  });

  @override
  State<AudioTimeInput> createState() => _AudioTimeInputState();
}

class _AudioTimeInputState extends State<AudioTimeInput> {
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Expanded(
              child:
                  _buildTimeField(startTimeController, 'Start Time (seconds)')),
          SizedBox(width: 16.w),
          Expanded(
              child: _buildTimeField(endTimeController, 'End Time (seconds)')),
          SizedBox(width: 16.w),
          _buildSetTimeButton(context),
        ],
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildSetTimeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _validateAndSetTime(context),
      child: const Text('Set Time'),
    );
  }

  void _validateAndSetTime(BuildContext context) {
    final startSeconds = int.tryParse(startTimeController.text) ?? 0;
    final endSeconds = int.tryParse(endTimeController.text) ?? 0;

    if (_isValidTimeRange(startSeconds, endSeconds)) {
      widget.onManualTimeSet(
        Duration(seconds: startSeconds),
        Duration(seconds: endSeconds),
      );
    } else {
      _showError(context);
    }
  }

  bool _isValidTimeRange(int startSeconds, int endSeconds) {
    return endSeconds > startSeconds &&
        startSeconds >= 0 &&
        endSeconds <= widget.duration.inSeconds;
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid time range. Please check your inputs.'),
      ),
    );
  }
}
