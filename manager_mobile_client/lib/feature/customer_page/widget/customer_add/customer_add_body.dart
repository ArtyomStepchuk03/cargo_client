import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/attachment/multiple_attachment_form_group.dart';
import 'package:manager_mobile_client/common/form/contact/contact_form_rows.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'package:manager_mobile_client/src/logic/external/places_service.dart';
import 'package:manager_mobile_client/util/format/price_type.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/required_validator.dart';

class CustomerCreateInformation {
  String name;
  String contactName;
  String contactPhoneNumber;
  PriceType priceType;
  List<File> files;
  String address;
  PlacesSearchResult placesSearchResult;
}

class CustomerAddBody extends StatefulWidget {
  CustomerAddBody({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CustomerAddBodyState();
}

class CustomerAddBodyState extends State<CustomerAddBody> {
  CustomerCreateInformation validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final createInformation = CustomerCreateInformation();
    createInformation.name = _nameKey.currentState.value;
    if (_contactNameKey.currentState.value != null &&
        _contactNameKey.currentState.value.isNotEmpty) {
      createInformation.contactName = _contactNameKey.currentState.value;
    }
    if (_contactPhoneNumberKey.currentState.value != null &&
        _contactPhoneNumberKey.currentState.value.isNotEmpty) {
      createInformation.contactPhoneNumber =
          _contactPhoneNumberKey.currentState.value;
    }
    createInformation.priceType = _priceTypeKey.currentState.value;
    if (_attachmentFormGroupKey.currentState.files.isNotEmpty) {
      createInformation.files = _attachmentFormGroupKey.currentState.files;
    }
    createInformation.address = _addressKey.currentState.value;
    createInformation.placesSearchResult =
        _addressKey.currentState.placesSearchResult;
    return createInformation;
  }

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    return buildForm(key: _formKey, children: [
      _buildMainGroup(dependencyState),
      MultipleAttachmentFormGroup(key: _attachmentFormGroupKey),
    ]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();

  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _contactNameKey = GlobalKey<FormFieldState<String>>();
  final _contactPhoneNumberKey = GlobalKey<FormFieldState<String>>();
  final _priceTypeKey = GlobalKey<EnumerationFormFieldState<PriceType>>();
  final _attachmentFormGroupKey = GlobalKey<MultipleAttachmentFormGroupState>();
  final _addressKey = GlobalKey<AddressFormFieldState>();

  Widget _buildMainGroup(DependencyState dependencyState) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
          Icons.assignment_ind,
          _buildTextFormField(
              _nameKey, localizationUtil.name, RequiredValidator(context))),
      buildFormRow(Icons.location_on,
          _buildAddressFormField(dependencyState.location.placesService)),
      buildContactNameFormRow(context, key: _contactNameKey),
      buildContactPhoneNumberFormRow(context, key: _contactPhoneNumberKey),
      buildFormRow(Icons.account_balance_wallet, _buildPriceTypeFormField()),
    ]);
  }

  Widget _buildAddressFormField(PlacesService placesService) {
    final localizationUtil = LocalizationUtil.of(context);
    return AddressFormField(
      key: _addressKey,
      initialValue: '',
      placesService: placesService,
      label: localizationUtil.unloadingAddress,
      validator: RequiredValidator(context),
    );
  }

  Widget _buildPriceTypeFormField() {
    final localizationUtil = LocalizationUtil.of(context);
    return EnumerationFormField<PriceType>(
      context,
      key: _priceTypeKey,
      values: PriceType.values,
      formatter: formatPriceTypeSafe,
      label: localizationUtil.priceTypeCustomer,
      validator: RequiredValidator(context),
    );
  }

  Widget _buildTextFormField(Key key, String label,
      [FormFieldValidator<String> validator]) {
    return CustomTextFormField(
      key: key,
      initialValue: '',
      label: label,
      validator: validator,
    );
  }
}
