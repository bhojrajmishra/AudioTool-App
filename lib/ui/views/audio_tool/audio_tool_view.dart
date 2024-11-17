import 'package:audiobook_record/ui/views/audio_tool/widgets/audio_waveform.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/edit_button.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/play_push_button.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/progress_bar.dart';
import 'package:audiobook_record/ui/views/audio_tool/widgets/record_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

import 'audio_tool_viewmodel.dart';

class AudioToolView extends StackedView<AudioToolViewModel> {
  const AudioToolView({
    super.key,
    required this.bookTitle,
    required this.audioPath,
  });

  final String bookTitle;
  final String? audioPath;

  @override
  Widget builder(
    BuildContext context,
    AudioToolViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                viewModel.formatDuration(viewModel.position),
                style: const TextStyle(fontSize: 20),
              ),
              AudioWaveformWidget(
                playerController: viewModel.playerController,
                duration: viewModel.duration,
                isLoading: viewModel.isloading,
                isSelecting: viewModel.isSelecting,
                selectionStart: viewModel.selectionStart,
                selectionWidth: viewModel.selectionWidth,
                onSelectionStart: viewModel.startSelection,
                onSelectionUpdate: viewModel.updateSelection,
                onSelectionEnd: viewModel.endSelection,
                // onManualTimeSet: viewModel.setManualTimeRange,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(viewModel.formatDuration(viewModel.position)),
                    Text(viewModel.formatDuration(viewModel.duration)),
                  ],
                ),
              ),
              ProgressBar(viewModel: viewModel),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EditButton(
                    icon: Icons.content_cut,
                    label: 'Trim',
                    isActive: viewModel.editMode == EditMode.trim,
                    onPressed: () => viewModel.setEditMode(EditMode.trim),
                  ),
                  PlayPushButton(viewModel: viewModel),
                  EditButton(
                    icon: Icons.playlist_add,
                    label: 'Insert',
                    isActive: viewModel.editMode == EditMode.insert,
                    onPressed: () => viewModel.setEditMode(EditMode.insert),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              if (viewModel.isSelecting)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Apply'),
                      onPressed: viewModel.applyChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      onPressed: () => viewModel.setEditMode(EditMode.none),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  AudioToolViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AudioToolViewModel(
        bookTitle: bookTitle,
        audioPath: audioPath,
      );
}
