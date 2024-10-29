import 'package:audiobook_record/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:audiobook_record/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:audiobook_record/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:audiobook_record/ui/views/home/home_view.dart';
import 'package:audiobook_record/ui/views/audio/audio_view.dart';
import 'package:audiobook_record/ui/views/chapter_list/chapter_list_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: AudioView),
    MaterialRoute(page: ChapterListView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
