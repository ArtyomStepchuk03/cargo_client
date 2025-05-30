import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/core/date_utility.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'package:manager_mobile_client/src/logic/core/time_parse.dart';
import 'package:manager_mobile_client/src/logic/order/entrance_coordinate_mismatch.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/order.dart';
import 'package:manager_mobile_client/util/format/price_type.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/vehicle_equipment.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

import 'order_details_form_fields.dart';
import 'order_distance_form_row.dart';

class OrderDetailsMainBody extends StatefulWidget {
  final Order? order;
  final User? user;
  final bool editing;
  final bool? insetForFloatingActionButton;

  OrderDetailsMainBody({
    Key? key,
    this.order,
    this.user,
    this.editing = false,
    this.insetForFloatingActionButton = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderDetailsMainBodyState(editing);
}

class OrderDetailsMainBodyState extends State<OrderDetailsMainBody> {
  OrderDetailsMainBodyState(bool editing) : _editing = editing;

  void setEditing(bool editing) => setState(() => _editing = editing);

  void update() => setState(() {});

  void reset() => _formKey.currentState?.reset();

  Order? validate() {
    if (_formKey.currentState?.validate() != true) {
      return null;
    }

    final order = Order();
    order.assign(widget.order);

    order.type = _typeKey.currentState?.value?.raw;

    order.articleBrand = _articleBrandKey.currentState?.value;
    order.tonnage = parseDecimal(_tonnageKey.currentState!.value!);
    order.distance = _distanceKey.currentState?.distance;

    var userRole = widget.user?.role;
    if (userRole != Role.customer) {
      order.intermediary = _intermediaryKey.currentState?.value;
      order.supplier = _supplierKey.currentState?.value;
      order.loadingPoint = _loadingPointKey.currentState?.value;
      order.loadingEntrance = _loadingEntranceKey.currentState?.value;
      order.loadingDate = _loadingDateKey.currentState?.value;
    }

    if (userRole == Role.customer) {
      order.customer = widget.user?.customer;
    } else {
      order.customer = _customerKey.currentState?.value;
    }
    order.unloadingPoint = _unloadingPointKey.currentState?.value;
    if (userRole != Role.customer) {
      order.unloadingEntrance = _unloadingEntranceKey.currentState?.value;
    }

    order.unloadingContact = _unloadingContactKey.currentState?.value;

    print(
        'DEBUG: Saving contact: ${order.unloadingContact?.name} - ${order.unloadingContact?.phoneNumber}');

    order.unloadingBeginDate = DateUtility.fromDatePartAndTime(
        _unloadingDateKey.currentState!.value!,
        parseHour(_unloadingTimeBeginKey.currentState!.value!)!);
    order.unloadingEndDate = DateUtility.fromDatePartAndTime(
        _unloadingDateKey.currentState!.value!,
        parseHour(_unloadingTimeEndKey.currentState!.value!)!);

    if (widget.user!.canManageOrderSalePrice()) {
      order.salePriceType = _salePriceTypeKey.currentState?.value;
      order.saleTariff = _saleTariffKey.currentState!.value!.isNotEmpty
          ? parseDecimal(_saleTariffKey.currentState!.value!)
          : null;
    } else if (userRole != Role.customer) {
      order.salePriceType = _customerKey.currentState?.value?.priceType;
    } else {
      order.salePriceType = widget.user?.customer?.priceType;
    }
    if (userRole != Role.customer) {
      order.deliveryPriceType = _deliveryPriceTypeKey.currentState?.value;
      order.deliveryTariff = _deliveryTariffKey.currentState!.value!.isNotEmpty
          ? parseDecimal(_deliveryTariffKey.currentState!.value!)
          : null;
    } else {
      order.deliveryPriceType = PriceType.notOneTime;
    }

    order.comment = _commentKey.currentState?.value == null ||
            _commentKey.currentState!.value!.isEmpty
        ? null
        : _commentKey.currentState!.value;
    if (userRole != Role.customer) {
      order.inactivityTimeInterval =
          scanHours(_inactivityTimeIntervalKey.currentState!.value!);
    }
    if ([Role.manager, Role.administrator, Role.logistician].contains(userRole))
      order.consistency = _agreeTypeKey.currentState?.value?.raw;

    return order;
  }

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    return buildForm(key: _formKey, children: [
      if (widget.user?.role != Role.customer)
        _buildUpperGroup(dependencyState, widget.order),
      _buildCustomerGroup(dependencyState, widget.order),
      if (widget.user?.role != Role.customer)
        _buildSupplierGroup(dependencyState, widget.order),
      _buildArticleGroup(dependencyState, widget.order),
      if (widget.user?.role != Role.customer)
        _buildPriceGroup(dependencyState, widget.order),
      _buildMiscellaneousGroup(dependencyState, widget.order),
      buildFloatingActionButtonSpacer(widget.insetForFloatingActionButton)
    ]);
  }

  var _editing = false;

  final _formKey = GlobalKey<ScrollableFormState>();

  final _typeKey = GlobalKey<EnumerationFormFieldState<OrderType>>();
  final _agreeTypeKey = GlobalKey<EnumerationFormFieldState<AgreeOrderType>>();
  final _intermediaryKey = GlobalKey<LoadingListFormFieldState<Intermediary>>();
  final _loadingTypeKey = GlobalKey<EnumerationFormFieldState<LoadingType>>();
  final _supplierKey = GlobalKey<LoadingListFormFieldState<Supplier>>();
  final _loadingPointKey = GlobalKey<LoadingListFormFieldState<LoadingPoint>>();
  final _loadingEntranceKey = GlobalKey<LoadingListFormFieldState<Entrance>>();
  final _loadingDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _customerKey = GlobalKey<LoadingListFormFieldState<Customer>>();
  final _unloadingPointKey =
      GlobalKey<LoadingListFormFieldState<UnloadingPoint>>();
  final _unloadingEntranceKey =
      GlobalKey<LoadingListFormFieldState<Entrance>>();
  final _unloadingContactKey = GlobalKey<LoadingListFormFieldState<Contact>>();
  final _unloadingDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _unloadingTimeBeginKey = GlobalKey<FormFieldState<String>>();
  final _unloadingTimeEndKey = GlobalKey<FormFieldState<String>>();
  final _articleTypeListKey =
      GlobalKey<LoadingListFormFieldState<ArticleType>>();
  final _articleTypeKey = GlobalKey<CustomTextFormFieldState>();
  final _articleBrandKey = GlobalKey<LoadingListFormFieldState<ArticleBrand>>();
  final _tonnageKey = GlobalKey<FormFieldState<String>>();
  final _distanceKey = GlobalKey<OrderDistanceFormRowState>();
  final _salePriceTypeKey = GlobalKey<EnumerationFormFieldState<PriceType>>();
  final _saleTariffKey = GlobalKey<CustomTextFormFieldState>();
  final _deliveryPriceTypeKey =
      GlobalKey<EnumerationFormFieldState<PriceType>>();
  final _deliveryTariffKey = GlobalKey<CustomTextFormFieldState>();
  final _commentKey = GlobalKey<FormFieldState<String>>();
  final _inactivityTimeIntervalKey = GlobalKey<FormFieldState<String>>();

  Widget _buildUpperGroup(DependencyState? dependencyState, Order? order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.local_shipping,
        EnumerationFormField<OrderType>(
          context,
          key: _typeKey,
          initialValue: OrderType(order?.type),
          values: [OrderType.normal(), OrderType.carriage()],
          formatter: formatOrderType,
          label: localizationUtil.orderType,
          validator: RequiredValidator(context),
          enabled: _editing,
        ),
      ),
      buildFormRow(
        Icons.business_center,
        buildIntermediaryFormField(
          context,
          _intermediaryKey,
          order?.intermediary,
          dependencyState!.network.serverAPI.intermediaries,
          dependencyState.caches.intermediary,
          _editing,
        ),
      ),
    ]);
  }

  Widget _buildCustomerGroup(DependencyState dependencyState, Order? order) {
    final localizationUtil = LocalizationUtil.of(context);
    final configurationLoader = dependencyState.network.configurationLoader;
    return buildFormGroup([
      if (widget.user?.role != Role.customer)
        buildFormRow(
          Icons.assignment_ind,
          buildCustomerFormField(
            context,
            dependencyState: dependencyState,
            key: _customerKey,
            initialValue: order?.customer,
            user: widget.user,
            onChanged: _handleCustomerChanged,
            enabled: _editing,
          ),
        ),
      buildFormRow(
        null,
        buildUnloadingPointFormField(
          context: context,
          key: _unloadingPointKey,
          initialValue: order?.unloadingPoint,
          noteText: formatEquipmentRequirements(
              context,
              _unloadingPointKey.currentState != null
                  ? _unloadingPointKey.currentState?.value
                  : widget.order?.unloadingPoint),
          customerServerAPI: dependencyState.network.serverAPI.customers,
          cacheMap: dependencyState.caches.unloadingPoint,
          customer: widget.user?.role == Role.customer
              ? widget.user?.customer
              : _customerKey.currentState != null
                  ? _customerKey.currentState?.value
                  : order?.customer,
          user: widget.user,
          onChanged: _handleUnloadingPointChanged,
          enabled: _editing,
        ),
      ),
      if (widget.user?.role != Role.customer)
        buildFormRow(
          Icons.location_on,
          buildUnloadingEntranceFormField(
            context,
            key: _unloadingEntranceKey,
            initialValue: order?.unloadingEntrance,
            additionalErrorText: hasUnloadingEntranceCoordinateMismatch(
                    order, configurationLoader.configuration)
                ? localizationUtil.coordinateMismatch
                : null,
            unloadingPointServerAPI:
                dependencyState.network.serverAPI.unloadingPoints,
            cacheMap: dependencyState.caches.unloadingEntrance,
            unloadingPoint: _unloadingPointKey.currentState != null
                ? _unloadingPointKey.currentState?.value
                : order?.unloadingPoint,
            user: widget.user,
            enabled: _editing,
          ),
        ),
      buildFormRow(
          null,
          buildUnloadingContactFormField(
            context,
            key: _unloadingContactKey,
            initialValue: order?.unloadingContact,
            unloadingPointServerAPI:
                dependencyState.network.serverAPI.unloadingPoints,
            cacheMap: dependencyState.caches.unloadingContact,
            unloadingPoint: _unloadingPointKey.currentState != null
                ? _unloadingPointKey.currentState?.value
                : order?.unloadingPoint,
            user: widget.user,
            editing: _editing,
            onUpdate: _handleUnloadingContactChanged,
          )),
      buildFormRow(
        null,
        DateFormField(
          key: _unloadingDateKey,
          initialValue: order?.unloadingBeginDate?.toLocal(),
          pickerMode: CupertinoDatePickerMode.date,
          label: localizationUtil.unloadingDate,
          validator: RequiredValidator(context),
          enabled: _editing,
        ),
      ),
      buildFormRow(
        null,
        buildHourOnlyFormField(
          context,
          key: _unloadingTimeBeginKey,
          initialValue: order?.unloadingBeginDate?.toLocal().hour,
          label: localizationUtil.unloadingTimeBegin,
          validators: [
            RequiredValidator(context),
            RangeBeginValidator.buildHourRangeBeginValidator(
                _unloadingTimeEndKey, localizationUtil.timeGreaterThanEnd)
          ],
          enabled: _editing,
        ),
        buildHourOnlyFormField(
          context,
          key: _unloadingTimeEndKey,
          initialValue: order?.unloadingEndDate?.toLocal().hour ??
              order?.unloadingBeginDate?.toLocal().hour,
          label: localizationUtil.unloadingTimeEnd,
          validators: [
            RequiredValidator(context),
            RangeEndValidator.buildHourRangeEndValidator(
                _unloadingTimeBeginKey, localizationUtil.timeLessThanBegin)
          ],
          enabled: _editing,
        ),
      ),
      if ([Role.administrator, Role.logistician, Role.manager]
          .contains(widget.user?.role))
        buildFormRow(
          null,
          EnumerationFormField<AgreeOrderType>(
            context,
            key: _agreeTypeKey,
            initialValue: widget.order?.consistency == null
                ? AgreeOrderType.agree()
                : AgreeOrderType(widget.order?.consistency),
            values: [AgreeOrderType.agree(), AgreeOrderType.notAgree()],
            formatter: formatAgreeOrderType,
            label: localizationUtil.orderStage,
            validator: RequiredValidator(context),
            enabled: _editing,
            onChanged: _handleStatusChanged,
          ),
        )
    ]);
  }

  Widget _buildSupplierGroup(DependencyState? dependencyState, Order? order) {
    final localizationUtil = LocalizationUtil.of(context);
    final configurationLoader = dependencyState?.network.configurationLoader;
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
          initialValue: order?.supplier,
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
          order?.loadingPoint,
          dependencyState?.network.serverAPI.suppliers,
          dependencyState?.caches.loadingPoint,
          _supplierKey.currentState != null
              ? _supplierKey.currentState?.value
              : order?.supplier,
          _handleLoadingPointChanged,
          _editing,
        ),
      ),
      buildFormRow(
        Icons.location_on,
        buildLoadingEntranceFormField(
          context,
          key: _loadingEntranceKey,
          initialValue: order?.loadingEntrance,
          additionalErrorText: hasLoadingEntranceCoordinateMismatch(
                  order, configurationLoader?.configuration)
              ? localizationUtil.coordinateMismatch
              : null,
          loadingPointServerAPI:
              dependencyState?.network.serverAPI.loadingPoints,
          cacheMap: dependencyState?.caches.loadingEntrance,
          loadingPoint: _loadingPointKey.currentState != null
              ? _loadingPointKey.currentState!.value
              : order?.loadingPoint,
          enabled: _editing,
        ),
      ),
      buildFormRow(
        null,
        DateFormField(
          key: _loadingDateKey,
          initialValue: order?.loadingDate?.toLocal(),
          pickerMode: CupertinoDatePickerMode.dateAndTime,
          label: localizationUtil.loadingDateTime,
          validator: RequiredValidator(context),
          enabled: _editing,
        ),
      ),
    ]);
  }

  Widget _buildArticleGroup(DependencyState? dependencyState, Order? order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      if (widget.user?.role == Role.customer) ...[
        buildFormRow(
          Icons.local_mall,
          buildArticleTypeFormField(
            context,
            _articleTypeListKey,
            order?.articleBrand?.type,
            dependencyState!.network.serverAPI.articleTypes,
            dependencyState.caches.articleType,
            _handleArticleTypeChanged,
            _editing,
          ),
        ),
        buildFormRow(
          null,
          buildArticleBrandFormField(
            context,
            _articleBrandKey,
            order?.articleBrand,
            dependencyState.network.serverAPI.articleBrands,
            dependencyState.caches.articleBrand,
            _articleTypeListKey.currentState != null
                ? _articleTypeListKey.currentState!.value
                : order?.articleBrand?.type,
            _editing,
          ),
        ),
      ] else ...[
        buildFormRow(
          Icons.local_mall,
          buildArticleTypeDisplayFormField(
              context, _articleTypeKey, order?.articleBrand?.type),
        ),
        buildFormRow(
          null,
          buildSupplierArticleBrandFormField(
            context,
            _articleBrandKey,
            order?.articleBrand,
            dependencyState!.network.serverAPI.suppliers,
            dependencyState.caches.supplierArticleBrand,
            _supplierKey.currentState != null
                ? _supplierKey.currentState?.value
                : order?.supplier,
            _handleArticleBrandChanged,
            _editing,
          ),
        ),
      ],
      buildFormRow(
        null,
        buildCustomNumberFormField(
          context,
          key: _tonnageKey,
          initialValue: numberOrEmpty(order?.tonnage),
          label: localizationUtil.tonnage,
          validator: makeRequiredTonnageValidator(context),
          enabled: _editing && order?.distributedTonnage == 0,
        ),
      ),
      OrderDistanceFormRow(
        key: _distanceKey,
        initialValue: order?.distance,
        loadingPoint: _loadingPointKey.currentState != null
            ? _loadingPointKey.currentState!.value
            : order?.loadingPoint,
        unloadingPoint: _unloadingPointKey.currentState != null
            ? _unloadingPointKey.currentState!.value
            : order?.unloadingPoint,
        editing: _editing,
      ),
    ]);
  }

  Widget _buildPriceGroup(DependencyState? dependencyState, Order? order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      if (widget.user?.canManageOrderSalePrice() == true) ...[
        buildFormRow(
          Icons.account_balance_wallet,
          EnumerationFormField<PriceType>(
            context,
            key: _salePriceTypeKey,
            initialValue: order?.salePriceType ?? order?.customer?.priceType,
            values: PriceType.values,
            formatter: formatPriceTypeSafe,
            label: localizationUtil.salePriceType,
            validator: RequiredValidator(context),
            enabled: _editing,
          ),
        ),
        buildFormRow(
          null,
          buildCustomNumberFormField(
            context,
            key: _saleTariffKey,
            initialValue: numberOrEmpty(order?.saleTariff),
            label: localizationUtil.saleTariff,
            validator: NumberValidator(context, decimal: true, minimum: 0),
            enabled: _editing,
          ),
        ),
      ],
      buildFormRow(
        Icons.account_balance_wallet,
        EnumerationFormField<PriceType>(
          context,
          key: _deliveryPriceTypeKey,
          initialValue: order?.deliveryPriceType ?? PriceType.notOneTime,
          values: PriceType.values,
          formatter: formatPriceTypeSafe,
          label: localizationUtil.deliveryPriceType,
          validator: RequiredValidator(context),
          enabled: _editing,
        ),
      ),
      buildFormRow(
        null,
        buildCustomNumberFormField(
          context,
          key: _deliveryTariffKey,
          initialValue: numberOrEmpty(order?.deliveryTariff),
          label: localizationUtil.deliveryTariff,
          validator: NumberValidator(context, decimal: true, minimum: 0),
          enabled: _editing,
        ),
      ),
    ]);
  }

  Widget _buildMiscellaneousGroup(
      DependencyState? dependencyState, Order? order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.comment,
        CustomTextFormField(
          key: _commentKey,
          initialValue: textOrEmpty(order?.comment),
          label: localizationUtil.comment,
          enabled: _editing,
        ),
      ),
      if (widget.user?.role != Role.customer)
        buildFormRow(
          null,
          buildCustomIntegerFormField(
            context,
            key: _inactivityTimeIntervalKey,
            initialValue: formatHours(
                order?.inactivityTimeInterval ?? defaultInactivityTimeInterval),
            label: localizationUtil.inactivityTimeInterval,
            enabled: _editing,
          ),
        ),
    ]);
  }

  void _handleLoadingTypeChanged(LoadingType? value) {
    _supplierKey.currentState?.value = null;
    setState(() {});
  }

  void _handleStatusChanged(AgreeOrderType? value) {
    _agreeTypeKey.currentState?.value = value;

    setState(() {});
  }

  void _handleSupplierChanged(Supplier? value) {
    _loadingPointKey.currentState?.value = null;
    _articleBrandKey.currentState?.value = null;
    setState(() {});
  }

  void _handleCustomerChanged(Customer? value) {
    _unloadingPointKey.currentState?.value = null;
    if (_salePriceTypeKey.currentState != null)
      _salePriceTypeKey.currentState?.value =
          _customerKey.currentState?.value?.priceType;
    setState(() {});
  }

  void _handleLoadingPointChanged(LoadingPoint? value) {
    _loadingEntranceKey.currentState?.value = null;
    setState(() {});
  }

  void _handleUnloadingPointChanged(UnloadingPoint? value) {
    if (_unloadingEntranceKey.currentState != null)
      _unloadingEntranceKey.currentState?.value = null;

    // Очищаем контакт разгрузки при смене точки разгрузки
    _unloadingContactKey.currentState?.value = null;

    setState(() {});
  }

  void _handleUnloadingContactChanged(Contact? contact) {
    setState(() {
      _unloadingContactKey.currentState?.value = contact;
      widget.order?.unloadingContact = contact;
    });
  }

  void _handleArticleTypeChanged(ArticleType? value) {
    _articleBrandKey.currentState?.value = null;
    setState(() {});
  }

  void _handleArticleBrandChanged(ArticleBrand? value) {
    _articleTypeKey.currentState?.value = value?.type?.name;
    setState(() {});
  }

  LoadingType _getInitialLoadingType() =>
      widget.order?.supplier?.getLoadingType() ?? LoadingType.supplier;

  static const defaultInactivityTimeInterval = 24 * 60 * 60 * 1000;
}
