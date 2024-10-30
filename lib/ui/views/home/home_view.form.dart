// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String Title1ValueKey = 'title1';
const String BookTitleValueKey = 'book_title';

final Map<String, TextEditingController> _HomeViewTextEditingControllers = {};

final Map<String, FocusNode> _HomeViewFocusNodes = {};

final Map<String, String? Function(String?)?> _HomeViewTextValidations = {
  Title1ValueKey: null,
  BookTitleValueKey: null,
};

mixin $HomeView {
  TextEditingController get title1Controller =>
      _getFormTextEditingController(Title1ValueKey);
  TextEditingController get bookTitleController =>
      _getFormTextEditingController(BookTitleValueKey);

  FocusNode get title1FocusNode => _getFormFocusNode(Title1ValueKey);
  FocusNode get bookTitleFocusNode => _getFormFocusNode(BookTitleValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_HomeViewTextEditingControllers.containsKey(key)) {
      return _HomeViewTextEditingControllers[key]!;
    }

    _HomeViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _HomeViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_HomeViewFocusNodes.containsKey(key)) {
      return _HomeViewFocusNodes[key]!;
    }
    _HomeViewFocusNodes[key] = FocusNode();
    return _HomeViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    title1Controller.addListener(() => _updateFormData(model));
    bookTitleController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    title1Controller.addListener(() => _updateFormData(model));
    bookTitleController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          Title1ValueKey: title1Controller.text,
          BookTitleValueKey: bookTitleController.text,
        }),
    );

    if (_autoTextFieldValidation || forceValidate) {
      updateValidationData(model);
    }
  }

  bool validateFormFields(FormViewModel model) {
    _updateFormData(model, forceValidate: true);
    return model.isFormValid;
  }

  /// Calls dispose on all the generated controllers and focus nodes
  void disposeForm() {
    // The dispose function for a TextEditingController sets all listeners to null

    for (var controller in _HomeViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _HomeViewFocusNodes.values) {
      focusNode.dispose();
    }

    _HomeViewTextEditingControllers.clear();
    _HomeViewFocusNodes.clear();
  }
}

extension ValueProperties on FormStateHelper {
  bool get hasAnyValidationMessage => this
      .fieldsValidationMessages
      .values
      .any((validation) => validation != null);

  bool get isFormValid {
    if (!_autoTextFieldValidation) this.validateForm();

    return !hasAnyValidationMessage;
  }

  String? get title1Value => this.formValueMap[Title1ValueKey] as String?;
  String? get bookTitleValue => this.formValueMap[BookTitleValueKey] as String?;

  set title1Value(String? value) {
    this.setData(
      this.formValueMap..addAll({Title1ValueKey: value}),
    );

    if (_HomeViewTextEditingControllers.containsKey(Title1ValueKey)) {
      _HomeViewTextEditingControllers[Title1ValueKey]?.text = value ?? '';
    }
  }

  set bookTitleValue(String? value) {
    this.setData(
      this.formValueMap..addAll({BookTitleValueKey: value}),
    );

    if (_HomeViewTextEditingControllers.containsKey(BookTitleValueKey)) {
      _HomeViewTextEditingControllers[BookTitleValueKey]?.text = value ?? '';
    }
  }

  bool get hasTitle1 =>
      this.formValueMap.containsKey(Title1ValueKey) &&
      (title1Value?.isNotEmpty ?? false);
  bool get hasBookTitle =>
      this.formValueMap.containsKey(BookTitleValueKey) &&
      (bookTitleValue?.isNotEmpty ?? false);

  bool get hasTitle1ValidationMessage =>
      this.fieldsValidationMessages[Title1ValueKey]?.isNotEmpty ?? false;
  bool get hasBookTitleValidationMessage =>
      this.fieldsValidationMessages[BookTitleValueKey]?.isNotEmpty ?? false;

  String? get title1ValidationMessage =>
      this.fieldsValidationMessages[Title1ValueKey];
  String? get bookTitleValidationMessage =>
      this.fieldsValidationMessages[BookTitleValueKey];
}

extension Methods on FormStateHelper {
  setTitle1ValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[Title1ValueKey] = validationMessage;
  setBookTitleValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[BookTitleValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    title1Value = '';
    bookTitleValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      Title1ValueKey: getValidationMessage(Title1ValueKey),
      BookTitleValueKey: getValidationMessage(BookTitleValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _HomeViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _HomeViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      Title1ValueKey: getValidationMessage(Title1ValueKey),
      BookTitleValueKey: getValidationMessage(BookTitleValueKey),
    });
