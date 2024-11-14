import 'dart:io';
import 'package:audiobook_record/base/utils/helpers.dart';
import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_viewmodel.dart';
import 'package:audiobook_record/ui/views/chapter_list/widget/seekbar_row.dart';
import 'package:audiobook_record/widget/box_decoration/recording_list_decoration.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordingList extends StatelessWidget {
  const RecordingList({super.key, required this.viewModel});
  final ChapterListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox // first Box
        (
      height: Helpers.getScreenHeight(context) * 0.9.r,
      child: FutureBuilder<List<FileSystemEntity>?> // Future Builder
          (
        future: viewModel.retrieveRecordings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppStrings.errorLoadinRecording));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(AppStrings.noRecordingFound));
          }

          final recordings = snapshot.data!;
          return ListView.builder // ListView Builder
              (
            itemCount: recordings.length,
            itemBuilder: (context, index) {
              /// to check the item is active or not
              bool isActive = viewModel.activeIndex == index; // active index
              final file = recordings[index];
              final fileName = file.path.split('/').last;

              return Padding // To create space between records in list and padding for actule container
                  (
                padding: EdgeInsets.all(10.0.r),
                child: Container(
                  height: isActive ? 200.r : 100.r,
                  decoration: recordingListDecoration(isActive), // decoration
                  child: Column // column of container
                      (
                    children: [
                      ListTile(
                        title: Text(fileName), // file  name
                        subtitle: const Text(AppStrings.recording),
                        leading: IconButton // Play pause button
                            (
                          onPressed: () {
                            viewModel.navigateToAudioToolView(
                              bookTitle: fileName,
                              audioPath: file.path,
                            );
                            // viewModel.tooglePlayButton(index);
                            // viewModel.playBackRecording(file.path);
                          },
                          icon: viewModel.activeIndex ==
                                  index // toggle the play and pause button
                              ? const Icon(Icons.stop)
                              : const Icon(Icons.play_arrow),
                        ),

                        onTap: () {
                          viewModel.navigateToAudioToolView(
                            bookTitle: fileName,
                            audioPath: file.path,
                          );
                        },

                        /// Delete Button

                        trailing: isActive
                            ? IconButton // delete button when expanded and shows dialog
                                (
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Delete the recording:- \n${fileName.toString()}",
                                            style: TextStyle(fontSize: 20.sp),
                                          ),
                                          actions: [
                                            PrimaryButton(
                                                color: Colors.red,
                                                title: "Delete",
                                                onPressedCallBack: () {
                                                  viewModel
                                                      .deleteRecording(file);
                                                  viewModel.navigation.back();
                                                })
                                          ],
                                        );
                                      });
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            : IconButton // more horizontal button
                                (
                                onPressed: () {},
                                icon: const Icon(Icons.more_horiz),
                              ),
                      ),

                      /// active row
                      isActive
                          ? Padding(
                              padding: EdgeInsets.all(8.0.r),
                              //
                              child: SeekBarRow(
                                viewModel: viewModel,
                                isActive: isActive,
                              ), // seek Bar Row (Expandable)
                            )
                          : SizedBox(
                              height: 0,
                            )
                    ],
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
