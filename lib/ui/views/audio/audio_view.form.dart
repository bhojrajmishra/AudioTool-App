// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String RecordingTitleValueKey = 'recordingTitle';

final Map<String, TextEditingController> _AudioViewTextEditingControllers = {};

final Map<String, FocusNode> _AudioViewFocusNodes = {};

final Map<String, String? Function(String?)?> _AudioViewTextValidations = {
  RecordingTitleValueKey: null,
};

mixin $AudioView {
  TextEditingController get recordingTitleController =>
      _getFormTextEditingController(RecordingTitleValueKey);

  FocusNode get recordingTitleFocusNode =>
      _getFormFocusNode(RecordingTitleValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_AudioViewTextEditingControllers.containsKey(key)) {
      return _AudioViewTextEditingControllers[key]!;
    }

    _AudioViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _AudioViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_AudioViewFocusNodes.containsKey(key)) {
      return _AudioViewFocusNodes[key]!;
    }
    _AudioViewFocusNodes[key] = FocusNode();
    return _AudioViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    recordingTitleController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    recordingTitleController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          RecordingTitleValueKey: recordingTitleController.text,
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

    for (var controller in _AudioViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _AudioViewFocusNodes.values) {
      focusNode.dispose();
    }

    _AudioViewTextEditingControllers.clear();
    _AudioViewFocusNodes.clear();
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

  String? get recordingTitleValue =>
      this.formValueMap[RecordingTitleValueKey] as String?;

  set recordingTitleValue(String? value) {
    this.setData(
      this.formValueMap..addAll({RecordingTitleValueKey: value}),
    );

    if (_AudioViewTextEditingControllers.containsKey(RecordingTitleValueKey)) {
      _AudioViewTextEditingControllers[RecordingTitleValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasRecordingTitle =>
      this.formValueMap.containsKey(RecordingTitleValueKey) &&
      (recordingTitleValue?.isNotEmpty ?? false);

  bool get hasRecordingTitleValidationMessage =>
      this.fieldsValidationMessages[RecordingTitleValueKey]?.isNotEmpty ??
      false;

  String? get recordingTitleValidationMessage =>
      this.fieldsValidationMessages[RecordingTitleValueKey];
}

extension Methods on FormStateHelper {
  setRecordingTitleValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[RecordingTitleValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    recordingTitleValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      RecordingTitleValueKey: getValidationMessage(RecordingTitleValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _AudioViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _AudioViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      RecordingTitleValueKey: getValidationMessage(RecordingTitleValueKey),
    });
