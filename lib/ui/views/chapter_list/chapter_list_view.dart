import 'dart:io';

import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:audiobook_record/widget/primary_button.dart';
import 'package:audiobook_record/widget/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chapter_list_viewmodel.dart';

class ChapterListView extends StackedView<ChapterListViewModel> with $HomeView {
  const ChapterListView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChapterListViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapter List"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SizedBox(
          height: 300,
          child: FutureBuilder<List<FileSystemEntity>>(
            future: viewModel.retrieveRecordings(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading recordings'));
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
                      onPressed: () => viewModel.playRecording(file.path),
                      icon: viewModel.isPlaying
                          ? const Icon(Icons.stop)
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Enter Book tilte"),

                  /// Button
                  actions: [
                    PrimaryButton(
                      title: "Save",
                      onPressedCallBack: viewModel.navigationto,
                    )
                  ],
                  content: PrimaryTextField(
                    controller: title1Controller,
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  ChapterListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChapterListViewModel();
}
