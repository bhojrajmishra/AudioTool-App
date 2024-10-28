import 'package:audiobook_record/app/app.dialogs.dart';
import 'package:audiobook_record/base/wrapper/base_view_model_wrapper.dart';


class HomeViewModel extends BaseViewModelWrapper {


  void showDialog() {
    dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks!',
      description: 'Give stacked stars on Github',
    );
  }
}
