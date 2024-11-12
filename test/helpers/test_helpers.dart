// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
import 'package:audiobook_record/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
// @stacked-import

// @GenerateMocks([], customMocks: [
//   MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
//   MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
//   MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
//   // @stacked-mock-spec
// ])
void registerServices() {
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  // @stacked-mock-register
}

class MockNavigationService {}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  // // when(service.showCustomSheet(
  // //   enableDrag: anyNamed('enableDrag'),
  // //   enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
  // //   exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
  // //   ignoreSafeArea: anyNamed('ignoreSafeArea'),
  // //   isScrollControlled: anyNamed('isScrollControlled'),
  // //   barrierDismissible: anyNamed('barrierDismissible'),
  // //   additionalButtonTitle: anyNamed('additionalButtonTitle'),
  // //   variant: anyNamed('variant'),
  // //   title: anyNamed('title'),
  // //   hasImage: anyNamed('hasImage'),
  // //   imageUrl: anyNamed('imageUrl'),
  // //   showIconInMainButton: anyNamed('showIconInMainButton'),
  // //   mainButtonTitle: anyNamed('mainButtonTitle'),
  // //   showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
  // //   secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
  // //   showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
  // //   takesInput: anyNamed('takesInput'),
  // //   barrierColor: anyNamed('barrierColor'),
  // //   barrierLabel: anyNamed('barrierLabel'),
  // //   customData: anyNamed('customData'),
  // //   data: anyNamed('data'),
  // //   description: anyNamed('description'),
  // )).thenAnswer((realInvocation) =>
  //     Future.value(showCustomSheetResponse ?? SheetResponse<T>()));

  locator.registerSingleton<BottomSheetService>(service as BottomSheetService);
  return service;
}

class MockBottomSheetService {
  showCustomSheet(
      {required enableDrag,
      required enterBottomSheetDuration,
      required exitBottomSheetDuration,
      required ignoreSafeArea,
      required isScrollControlled,
      required barrierDismissible,
      required additionalButtonTitle,
      required variant,
      required title,
      required hasImage,
      required imageUrl,
      required showIconInMainButton,
      required mainButtonTitle,
      required showIconInSecondaryButton,
      required secondaryButtonTitle,
      required showIconInAdditionalButton,
      required takesInput,
      required barrierColor,
      required barrierLabel,
      required customData,
      required data,
      required description}) {}
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service as DialogService);
  return service;
}

class MockDialogService {}

// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
