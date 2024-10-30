import 'dart:io';

import 'package:audiobook_record/ui/views/chapter_list/chapter_list_viewmodel.dart';
import 'package:flutter/material.dart';


class RecordingList extends StatelessWidget {
  const RecordingList({
    super.key,
    required this.viewModel
  });
  final ChapterListViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
