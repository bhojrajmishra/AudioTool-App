import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';

class HomeViewModel extends BaseViewModelWrapper {
  void navigationto() {
    navigation.replaceWithAudioView();
  }
}
