import 'dart:io';

import 'package:audiobook_record/base/utils/helpers.dart';
import 'package:audiobook_record/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';

class BooksList extends StatelessWidget {
  const BooksList({super.key, required this.viewModel});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Helpers.getScreenHeight(context) * 0.5, // 100,
      child: FutureBuilder<List<FileSystemEntity>>(
        future: viewModel.retriveBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Books found'));
          }

          final recordings = snapshot.data!;
          return ListView.builder(
            itemCount: recordings.length,
            itemBuilder: (context, index) {
              /// to check the item is active or not

              final file = recordings[index];
              final fileName = file.path.split('/').last;

              return GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 100,
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

                          /// Delete Button
                        ),

                        /// active row
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
