import 'dart:io';

import 'package:audiobook_record/ui/common/app_image.dart';
import 'package:audiobook_record/ui/common/ui_helpers.dart';
import 'package:audiobook_record/ui/views/audio/widgets/record_button_row.dart';
import 'package:audiobook_record/ui/views/audio/widgets/seekbar.dart';
import 'package:audiobook_record/widget/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'audio_viewmodel.dart';

class AudioView extends StackedView<AudioViewModel> {
  const AudioView({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget builder(
    BuildContext context,
    AudioViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Scaffold(
          /// AppBar
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_add),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_sharp),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const RoundedImage(imageUrl: AppImage.audioBook),
                const Text("AudioBook Title 1"),
                const Text("AudioBook Title 2"),
                // if (viewModel.audioPath != null)
                // ElevatedButton(
                //     onPressed: () {
                //       viewModel.tooglePlayPause(viewModel.isPlaying);
                //       viewModel.playCurrentRecord;
                //     },
                //     child: viewModel.isPlaying
                //         ? const Icon(Icons.one_k)
                //         : const Icon(Icons.play_arrow)),
                // if (viewModel.audioPath == null)
                //   const Text("No recording found :("),

                /// slider seek bar
                SeekBar(
                  viewModel: viewModel,
                ),

                verticalSpaceMedium,
                //
                // paly pause buttons
                RecordButtonRow(
                  viewModel: viewModel,
                ),

                /// List of retrieved recordings with play and delete options
                SizedBox(
                  height: 300,
                  child: FutureBuilder<List<FileSystemEntity>>(
                    future: viewModel.retrieveRecordings(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading recordings'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No recordings found'));
                      }

                      final recordings = snapshot.data!;
                      return ListView.builder(
                        itemCount: recordings.length,
                        itemBuilder: (context, index) {
                          final file = recordings[index];
                          final fileName = file.path.split('/').last;

                          return ListTile(
                            leading: IconButton(
                              onPressed: () =>
                                  viewModel.playRecording(file.path),
                              icon: viewModel.isPlaying
                                  ? const Icon(Icons.pause)
                                  : const Icon(Icons.play_arrow),
                            ),
                            title: Text(fileName),
                            trailing: IconButton(
                              onPressed: () => viewModel.deleteRecording(file),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  AudioViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AudioViewModel();
}
