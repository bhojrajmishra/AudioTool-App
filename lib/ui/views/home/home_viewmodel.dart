import 'package:audiobook_record/app/app.router.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';

class HomeViewModel extends BaseViewModelWrapper with $HomeView {
  void navigationto() {
    navigation.replaceWithAudioView(title: title1Controller.text);
  }
  

}
