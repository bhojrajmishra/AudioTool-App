import 'dart:io';

import 'package:audiobook_record/base/utils/helpers.dart';
import 'package:audiobook_record/ui/common/app_colors.dart';
import 'package:audiobook_record/ui/common/app_strings.dart';
import 'package:audiobook_record/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BooksList extends StatelessWidget {
  const BooksList({super.key, required this.viewModel});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Helpers.getScreenHeight(context) * 0.7.r,
      child: FutureBuilder<List<FileSystemEntity>>(
        future: viewModel.retrieveBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child:
                    Text(AppStrings.noBook)); // show text if no book is found
          }

          final recordings = snapshot.data!;
          return ListView.builder(
            itemCount: recordings.length,
            itemBuilder: (context, index) {
              final file = recordings[index];
              final fileName = file.path.split('/').last;

              return Padding(
                padding:  EdgeInsets.symmetric(vertical: 10.0.h),
                child: Container(
                  height: 90, // height of the tile
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: kcPrimaryColor.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]),
                  child: Column(children: [
                    ListTile(
                      onTap: () {
                        viewModel.bookNavigation(fileName);
                      },
                      title: Text(fileName),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
