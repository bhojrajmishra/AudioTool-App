import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'audio_tool_viewmodel.dart';

class AudioToolView extends StackedView<AudioToolViewModel> {
  const AudioToolView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AudioToolViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  AudioToolViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AudioToolViewModel();
}
