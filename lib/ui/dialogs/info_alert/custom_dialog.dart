import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

void setupDialogUi(DialogService dialogService) {
  dialogService.registerCustomDialogBuilders({
    'audio_exists': (BuildContext context, DialogRequest request,
        Function(DialogResponse) completer) {
      return AlertDialog(
        title: Text(request.title ?? ''),
        content: Text(request.description ?? ''),
        actions: [
          TextButton(
            onPressed: () => completer(DialogResponse(confirmed: false)),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => completer(DialogResponse(confirmed: true)),
            child: const Text("Overwrite"),
          ),
        ],
      );
    },
  });
}
