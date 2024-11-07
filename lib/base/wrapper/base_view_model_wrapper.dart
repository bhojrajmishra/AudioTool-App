import 'package:audiobook_record/app/app.locator.dart';
import 'package:audiobook_record/ui/views/home/home_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

abstract class BaseViewModelWrapper extends BaseViewModel   with $HomeView{
  final navigation = locator<NavigationService>();
  final dialogService = locator<DialogService>();
  final showSnackBar = locator<SnackbarService>();
}
