import 'package:audiobook_record/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

abstract class BaseViewModelWrapper extends BaseViewModel {
  final navigation = locator<NavigationService>();
  final dialogService = locator<DialogService>();
}
