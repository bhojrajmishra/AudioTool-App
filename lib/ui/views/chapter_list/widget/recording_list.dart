import 'dart:io';

import 'package:audiobook_record/base/utils/helpers.dart';
import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/common/ui_helpers.dart';
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordingList extends StatelessWidget {
  const RecordingList({super.key, required this.viewModel});
  final ChapterListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Helpers.getScreenHeight(context) * 0.8.r, // 100,
      child: FutureBuilder<List<FileSystemEntity>?>(
        future: viewModel.retrieveRecordings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppStrings.errorLoadinRecording));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(AppStrings.noRecordingFound));
          }

          final recordings = snapshot.data!;
          return ListView.builder(
            itemCount: recordings.length,
            itemBuilder: (context, index) {
              /// to check the item is active or not
              bool isActive = viewModel.activeIndex == index;
              final file = recordings[index];
              final fileName = file.path.split('/').last;

              return GestureDetector(
                onTap: () {
                  viewModel.onTapRecord(index);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0.h),
                  child: Container(
                    height: isActive ? 160.h : 100.h,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ]),
                    // duration: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        ListTile(
                            // file  name
                            title: Text(fileName),
                            subtitle: const Text(AppStrings.recording),

                            /// Delete Button
                            trailing: isActive
                                ? IconButton(
                                    onPressed: () =>
                                        viewModel.deleteRecording(file),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.more_horiz))),

                        /// active row
                        isActive
                            ? Padding(
                                padding: EdgeInsets.all(8.0.r),
                                child: Row(
                                  children: [
                                    /// Play pause button
                                    IconButton(
                                      onPressed: () {
                                        viewModel.playBackRecording(file.path);
                                      },
                                      icon: viewModel.isPlaying
                                          ? const Icon(Icons.stop)
                                          : const Icon(Icons.play_arrow),
                                    ),

                                    viewModel.isPlaying
                                        ? IconButton(
                                            onPressed: () {
                                              viewModel.pauseResume();
                                              viewModel.toggleButton();
                                            },
                                            icon: viewModel.isPaused
                                                ? const Icon(Icons.play_arrow)
                                                : const Icon(Icons.pause))
                                        : horizontalSpaceTiny,

                                    // seek Bar
                                    Expanded(
                                      child: Slider(
                                        value: viewModel.currentPosition
                                            .toDouble(),
                                        max: viewModel.totalDuration.toDouble(),
                                        divisions:
                                            viewModel.totalDuration.toInt(),
                                        label: viewModel.currentPosition
                                            .toStringAsFixed(0),
                                        onChanged: (value) {
                                          viewModel.audioPlayer.seek(
                                              Duration(seconds: value.toInt()));
                                        },
                                      ),
                                    ),
                                    Text(
                                        "00:${viewModel.currentPosition.toStringAsFixed(0)}"),
                                  ],
                                ),
                              )
                            : const Text('')
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
