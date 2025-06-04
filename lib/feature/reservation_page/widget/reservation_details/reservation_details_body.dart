import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_details_form_fields.dart';
import 'package:manager_mobile_client/src/logic/article/tonnage_convert.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'package:manager_mobile_client/util/format/order.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/vehicle_equipment.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

import 'reservation_details_form_fields.dart';

class ReservationDetailsBody extends StatefulWidget {
  final Order? reservation;
  final User? user;
  final bool? editing;
  final bool? insetForFloatingActionButton;

  ReservationDetailsBody(
      {Key? key,
      this.reservation,
      this.user,
      this.editing = false,
      this.insetForFloatingActionButton = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReservationDetailsBodyState(editing);
}

class ReservationDetailsBodyState extends State<ReservationDetailsBody> {
  ReservationDetailsBodyState(bool? editing) : _editing = editing ?? false;

  void setEditing(bool editing) => setState(() => _editing = editing);
  void update() => setState(() {});
  void reset() => _formKey.currentState?.reset();

  Order? validate() {
    if (!_formKey.currentState!.validate()!) {
      return null;
    }

    final reservation = Order();
    reservation.assign(widget.reservation);

    reservation.articleBrand = _articleBrandKey.currentState?.value;
    reservation.tonnage = parseDecimal(_tonnageKey.currentState!.value!);

    reservation.supplier = _supplierKey.currentState?.value;
    reservation.loadingPoint = _loadingPointKey.currentState?.value;

    reservation.customer = _customerAssignmentKey.currentState?.value?.customer;
    reservation.unloadingPoint = _unloadingPointKey.currentState?.value;
    reservation.unloadingContact = _unloadingContactKey.currentState?.value;
    reservation.unloadingBeginDate = _unloadingDateKey.currentState?.value;

    reservation.salePriceType =
        _customerAssignmentKey.currentState?.value?.customer?.priceType ??
            PriceType.notOneTime;
    reservation.deliveryPriceType = PriceType.notOneTime;

    reservation.comment = _commentKey.currentState?.value == null ||
            _commentKey.currentState!.value!.isEmpty
        ? null
        : _commentKey.currentState?.value;

    return reservation;
  }

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    return buildForm(key: _formKey, children: [
      _buildCustomerGroup(dependencyState, widget.reservation),
      _buildSupplierGroup(dependencyState, widget.reservation),
      _buildArticleGroup(dependencyState, widget.reservation),
      _buildMiscellaneousGroup(dependencyState, widget.reservation),
      buildFloatingActionButtonSpacer(widget.insetForFloatingActionButton)
    ]);
  }

  var _editing = false;

  final _formKey = GlobalKey<ScrollableFormState>();

  final _loadingTypeKey = GlobalKey<EnumerationFormFieldState<LoadingType>>();
  final _supplierKey = GlobalKey<LoadingListFormFieldState<Supplier>>();
  final _loadingPointKey = GlobalKey<LoadingListFormFieldState<LoadingPoint>>();
  final _customerAssignmentKey =
      GlobalKey<LoadingListFormFieldState<ReservationCustomerAssignment>>();
  final _unloadingPointKey =
      GlobalKey<LoadingListFormFieldState<UnloadingPoint>>();
  final _unloadingContactKey = GlobalKey<LoadingListFormFieldState<Contact>>();
  final _unloadingDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _articleBrandKey = GlobalKey<LoadingListFormFieldState<ArticleBrand>>();
  final _articleTypeKey = GlobalKey<CustomTextFormFieldState>();
  final _truckCountKey = GlobalKey<CustomTextFormFieldState>();
  final _tonnageKey = GlobalKey<CustomTextFormFieldState>();
  final _commentKey = GlobalKey<FormFieldState<String>>();

  Widget _buildCustomerGroup(
      DependencyState dependencyState, Order? reservation) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.assignment_ind,
        buildReservationCustomerFormField(
          context,
          dependencyState: dependencyState,
          key: _customerAssignmentKey,
          initialValue: (widget.user?.role != Role.dispatcher ||
                  reservation?.customer != null)
              ? ReservationCustomerAssignment(reservation?.customer)
              : null,
          user: widget.user,
          onChanged: _handleCustomerChanged,
          enabled: _editing,
        ),
      ),
      if (_shouldShowUnloadingPointFormField()) ...[
        buildFormRow(
          null,
          buildUnloadingPointFormField(
            context: context,
            key: _unloadingPointKey,
            initialValue: reservation?.unloadingPoint,
            noteText: formatEquipmentRequirements(
                context,
                _unloadingPointKey.currentState != null
                    ? _unloadingPointKey.currentState!.value
                    : widget.reservation?.unloadingPoint),
            customerServerAPI: dependencyState.network.serverAPI.customers,
            cacheMap: dependencyState.caches.unloadingPoint,
            customer: _customerAssignmentKey.currentState != null
                ? _customerAssignmentKey.currentState!.value?.customer
                : reservation?.customer,
            user: widget.user,
            onChanged: _handleUnloadingPointChanged,
            enabled: _editing,
          ),
        ),
        buildFormRow(
          null,
          buildUnloadingContactFormField(
            context,
            key: _unloadingContactKey,
            initialValue: reservation?.unloadingContact,
            unloadingPointServerAPI:
                dependencyState.network.serverAPI.unloadingPoints,
            cacheMap: dependencyState.caches.unloadingContact,
            unloadingPoint: _unloadingPointKey.currentState != null
                ? _unloadingPointKey.currentState!.value
                : reservation!.unloadingPoint,
            user: widget.user,
            editing: _editing,
            onUpdate: _handleUnloadingContactChanged, // Используем новый метод
          ),
        ),
      ],
      buildFormRow(
        null,
        DateFormField(
          key: _unloadingDateKey,
          initialValue: reservation?.unloadingBeginDate?.toLocal(),
          pickerMode: CupertinoDatePickerMode.dateAndTime,
          label: localizationUtil.unloadingDateTime,
          validator: RequiredValidator(context),
          enabled: _editing,
        ),
      ),
    ]);
  }

  Widget _buildSupplierGroup(
      DependencyState? dependencyState, Order? reservation) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.location_city,
        EnumerationFormField<LoadingType>(
          context,
          key: _loadingTypeKey,
          initialValue: _getInitialLoadingType(),
          values: LoadingType.values,
          formatter: formatLoadingTypeSafe,
          onChanged: _handleLoadingTypeChanged,
          label: localizationUtil.loadingType,
          validator: RequiredValidator(context),
          enabled: _editing,
        ),
      ),
      buildFormRow(
        null,
        buildSupplierFormField(
          context,
          dependencyState: dependencyState,
          key: _supplierKey,
          initialValue: reservation?.supplier,
          loadingType: _loadingTypeKey.currentState != null
              ? _loadingTypeKey.currentState!.value
              : _getInitialLoadingType(),
          user: widget.user,
          onChanged: _handleSupplierChanged,
          enabled: _editing,
        ),
      ),
      buildFormRow(
        null,
        buildLoadingPointFormField(
          context,
          _loadingPointKey,
          reservation?.loadingPoint,
          dependencyState?.network.serverAPI.suppliers,
          dependencyState?.caches.loadingPoint,
          _supplierKey.currentState != null
              ? _supplierKey.currentState!.value
              : reservation?.supplier,
          null,
          _editing,
        ),
      ),
    ]);
  }

  Widget _buildArticleGroup(
      DependencyState? dependencyState, Order? reservation) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        null,
        buildArticleTypeDisplayFormField(
            context, _articleTypeKey, reservation?.articleBrand?.type),
      ),
      buildFormRow(
        null,
        buildSupplierArticleBrandFormField(
          context,
          _articleBrandKey,
          reservation!.articleBrand!,
          dependencyState!.network.serverAPI.suppliers,
          dependencyState.caches.supplierArticleBrand,
          _supplierKey.currentState != null
              ? _supplierKey.currentState!.value
              : reservation.supplier,
          _handleArticleBrandChanged,
          _editing,
        ),
      ),
      buildFormRow(
        null,
        buildCustomIntegerFormField(
          context,
          key: _truckCountKey,
          initialValue: getInitialTruckCount(),
          label: localizationUtil.truckCount,
          onChanged: _handleTruckCountChanged,
          validator: makeTruckCountValidator(context),
          enabled: _editing && _hasTonnagePerTruck(),
        ),
      ),
      buildFormRow(
        null,
        buildCustomNumberFormField(
          context,
          key: _tonnageKey,
          initialValue: getInitialTonnage(),
          label: localizationUtil.tonnage,
          onChanged: _handleTonnageChanged,
          validator: makeRequiredTonnageValidator(context),
          enabled: _editing,
        ),
      ),
    ]);
  }

  Widget _buildMiscellaneousGroup(
      DependencyState? dependencyState, Order? reservation) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.comment,
        CustomTextFormField(
          key: _commentKey,
          initialValue: textOrEmpty(reservation?.comment),
          label: localizationUtil.comment,
          enabled: _editing,
        ),
      ),
    ]);
  }

  void _handleCustomerChanged(ReservationCustomerAssignment? value) {
    _unloadingPointKey.currentState?.value = null;
    setState(() {});
  }

  void _handleUnloadingPointChanged(UnloadingPoint? value) {
    _unloadingContactKey.currentState?.value = null;
    setState(() {});
  }

  void _handleLoadingTypeChanged(LoadingType value) {
    _supplierKey.currentState?.value = null;
    setState(() {});
  }

  void _handleSupplierChanged(Supplier? value) {
    _loadingPointKey.currentState?.value = null;
    _articleBrandKey.currentState?.value = null;
    setState(() {});
  }

  void _handleArticleBrandChanged(ArticleBrand? articleBrand) {
    if (articleBrand?.tonnagePerTruck != null) {
      final truckCount = int.tryParse(_truckCountKey.currentState!.value!);
      if (truckCount != null) {
        final tonnage = tonnageFromTruckCount(truckCount, articleBrand!);
        _tonnageKey.currentState?.value = '$tonnage';
      }
    } else {
      _truckCountKey.currentState?.value = '';
    }
    _articleTypeKey.currentState?.value = articleBrand?.type?.name;
    setState(() {});
  }

  void _handleTruckCountChanged(String truckCountText) {
    final articleBrand = _articleBrandKey.currentState != null
        ? _articleBrandKey.currentState?.value
        : widget.reservation?.articleBrand;
    if (articleBrand?.tonnagePerTruck == null) {
      return;
    }
    if (truckCountText.isEmpty) {
      _tonnageKey.currentState?.value = '';
      return;
    }
    final truckCount = int.tryParse(truckCountText);
    if (truckCount == null) {
      _tonnageKey.currentState?.value = '';
      return;
    }
    final tonnage = tonnageFromTruckCount(truckCount, articleBrand!);
    _tonnageKey.currentState?.value = '$tonnage';
  }

  void _handleUnloadingContactChanged(Contact? contact) {
    setState(() {
      _unloadingContactKey.currentState?.value = contact;
      widget.reservation?.unloadingContact = contact;
    });
  }

  void _handleTonnageChanged(String tonnageText) {
    final articleBrand = _articleBrandKey.currentState != null
        ? _articleBrandKey.currentState?.value
        : widget.reservation?.articleBrand;
    if (articleBrand?.tonnagePerTruck == null) {
      return;
    }
    if (tonnageText.isEmpty) {
      _truckCountKey.currentState?.value = '';
      return;
    }
    final tonnage = tryParseDecimal(tonnageText);
    if (tonnage == null) {
      _truckCountKey.currentState?.value = '';
      return;
    }
    final truckCount = truckCountFromTonnage(tonnage, articleBrand!);
    _truckCountKey.currentState?.value = '$truckCount';
  }

  bool _shouldShowUnloadingPointFormField() {
    if (_customerAssignmentKey.currentState == null) {
      return widget.reservation?.customer != null;
    }
    return _customerAssignmentKey.currentState?.value == null ||
        _customerAssignmentKey.currentState!.value?.customer != null;
  }

  String getInitialTruckCount() {
    if (widget.reservation?.tonnage != null) {
      if (widget.reservation?.articleBrand?.tonnagePerTruck == null) {
        return '';
      }
      final truckCount = truckCountFromTonnage(
          widget.reservation!.tonnage!, widget.reservation!.articleBrand!);
      return '$truckCount';
    }
    return '${1}';
  }

  String getInitialTonnage() {
    if (widget.reservation?.tonnage != null) {
      return '${widget.reservation!.tonnage!}';
    }
    if (widget.reservation?.articleBrand?.tonnagePerTruck == null) {
      return '';
    }
    final tonnage = tonnageFromTruckCount(1, widget.reservation!.articleBrand!);
    return '$tonnage';
  }

  bool _hasTonnagePerTruck() {
    final articleBrand = _articleBrandKey.currentState != null
        ? _articleBrandKey.currentState!.value
        : widget.reservation?.articleBrand;
    return articleBrand?.tonnagePerTruck != null;
  }

  LoadingType _getInitialLoadingType() =>
      widget.reservation?.supplier?.getLoadingType() ?? LoadingType.supplier;
}
