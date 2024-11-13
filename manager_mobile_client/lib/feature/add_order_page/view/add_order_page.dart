import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_details_form_fields.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_distance_form_row.dart';
import 'package:manager_mobile_client/src/logic/order/entrance_coordinate_mismatch.dart';
import 'package:manager_mobile_client/src/logic/order/order_clone.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/order.dart';
import 'package:manager_mobile_client/util/format/price_type.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/vehicle_equipment.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class AddOrderPage extends StatefulWidget {
  final User user;
  final Order order;

  AddOrderPage({this.user, this.order});
  factory AddOrderPage.empty({User user}) =>
      AddOrderPage(user: user, order: Order());
  factory AddOrderPage.clone({User user, Order order}) =>
      AddOrderPage(user: user, order: cloneOrder(order, user));

  @override
  State<StatefulWidget> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
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

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newOrder),
        actions: [
          IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
        ],
      ),
      body: buildForm(key: _formKey, children: [
        if (widget.user.role != Role.customer)
          _buildUpperGroup(dependencyState, widget.order),
        _buildCustomerGroup(dependencyState, widget.order),
        if (widget.user.role != Role.customer)
          _buildSupplierGroup(dependencyState, widget.order),
        _buildArticleGroup(dependencyState, widget.order),
        if (widget.user.role != Role.customer)
          _buildPriceGroup(dependencyState, widget.order),
        _buildMiscellaneousGroup(dependencyState, widget.order),
        buildFloatingActionButtonSpacer(false)
      ]),
    );
  }

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final editedOrder = validate();
    if (editedOrder != null) {
      showActivityDialog(context, localizationUtil.saving);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      try {
        if (editedOrder.id != null && editedOrder.status != OrderStatus.ready) {
          await serverAPI.update(widget.order, editedOrder);
          await serverAPI.setStatus(editedOrder, OrderStatus.ready);
        } else {
          await serverAPI.create(editedOrder, widget.user);
        }
        Navigator.pop(context);
        Navigator.pop(context, editedOrder);
      } on CloudFunctionFailedException catch (exception) {
        Navigator.pop(context);
        if (exception.error == ServerError.noSupplierForArticle) {
          showErrorDialog(context, localizationUtil.articleNotAvailableForSale);
          return;
        }
        showDefaultErrorDialog(context);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  Order validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
  }

  Widget _buildUpperGroup(DependencyState dependencyState, Order order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.local_shipping,
        EnumerationFormField<OrderType>(
          context,
          key: _typeKey,
          initialValue: OrderType(order.type),
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
          order.intermediary,
          dependencyState.network.serverAPI.intermediaries,
          dependencyState.caches.intermediary,
          _editing,
        ),
      ),
    ]);
  }

  Widget _buildCustomerGroup(DependencyState dependencyState, Order order) {
    final localizationUtil = LocalizationUtil.of(context);
    final configurationLoader = dependencyState.network.configurationLoader;
    return buildFormGroup([
      if (widget.user.role != Role.customer)
        buildFormRow(
          Icons.assignment_ind,
          buildCustomerFormField(
            context,
            dependencyState: dependencyState,
            key: _customerKey,
            initialValue: order.customer,
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
          initialValue: order.unloadingPoint,
          noteText: formatEquipmentRequirements(
              context,
              _unloadingPointKey.currentState != null
                  ? _unloadingPointKey.currentState.value
                  : widget.order.unloadingPoint),
          customerServerAPI: dependencyState.network.serverAPI.customers,
          cacheMap: dependencyState.caches.unloadingPoint,
          customer: widget.user.role == Role.customer
              ? widget.user.customer
              : _customerKey.currentState != null
                  ? _customerKey.currentState.value
                  : order.customer,
          user: widget.user,
          onChanged: _handleUnloadingPointChanged,
          enabled: _editing,
        ),
      ),
      if (widget.user.role != Role.customer)
        buildFormRow(
          Icons.location_on,
          buildUnloadingEntranceFormField(
            context,
            key: _unloadingEntranceKey,
            initialValue: order.unloadingEntrance,
            additionalErrorText: hasUnloadingEntranceCoordinateMismatch(
                    order, configurationLoader.configuration)
                ? localizationUtil.coordinateMismatch
                : null,
            unloadingPointServerAPI:
                dependencyState.network.serverAPI.unloadingPoints,
            cacheMap: dependencyState.caches.unloadingEntrance,
            unloadingPoint: _unloadingPointKey.currentState != null
                ? _unloadingPointKey.currentState.value
                : order.unloadingPoint,
            user: widget.user,
            enabled: _editing,
          ),
        ),
      buildFormRow(
        null,
        buildUnloadingContactFormField(
          context,
          key: _unloadingContactKey,
          initialValue: order.unloadingContact,
          unloadingPointServerAPI:
              dependencyState.network.serverAPI.unloadingPoints,
          cacheMap: dependencyState.caches.unloadingContact,
          unloadingPoint: _unloadingPointKey.currentState != null
              ? _unloadingPointKey.currentState.value
              : order.unloadingPoint,
          user: widget.user,
          editing: _editing,
        ),
      ),
      buildFormRow(
        null,
        DateFormField(
          key: _unloadingDateKey,
          initialValue: order.unloadingBeginDate?.toLocal(),
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
          initialValue: order.unloadingBeginDate?.toLocal()?.hour,
          label: localizationUtil.unloadingTimeBegin,
          validators: [
            RequiredValidator(context),
            HourRangeBeginValidator.build(
                _unloadingTimeEndKey, localizationUtil.timeGreaterThanEnd)
          ],
          enabled: _editing,
        ),
        buildHourOnlyFormField(
          context,
          key: _unloadingTimeEndKey,
          initialValue: order.unloadingEndDate?.toLocal()?.hour ??
              order.unloadingBeginDate?.toLocal()?.hour,
          label: localizationUtil.unloadingTimeEnd,
          validators: [
            RequiredValidator(context),
            HourRangeEndValidator.build(
                _unloadingTimeBeginKey, localizationUtil.timeLessThanBegin)
          ],
          enabled: _editing,
        ),
      ),
      if ([Role.administrator, Role.logistician, Role.manager]
          .contains(widget.user.role))
        buildFormRow(
            null,
            EnumerationFormField<AgreeOrderType>(
              context,
              key: _agreeTypeKey,
              values: [AgreeOrderType.agree(), AgreeOrderType.notAgree()],
              formatter: formatAgreeOrderType,
              label: localizationUtil.orderStage,
              validator: RequiredValidator(context),
              enabled: _editing,
            ))
    ]);
  }

  Widget _buildSupplierGroup(DependencyState dependencyState, Order order) {
    final localizationUtil = LocalizationUtil.of(context);
    final configurationLoader = dependencyState.network.configurationLoader;
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
          initialValue: order.supplier,
          loadingType: _loadingTypeKey.currentState != null
              ? _loadingTypeKey.currentState.value
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
          order.loadingPoint,
          dependencyState.network.serverAPI.suppliers,
          dependencyState.caches.loadingPoint,
          _supplierKey.currentState != null
              ? _supplierKey.currentState.value
              : order.supplier,
          _handleLoadingPointChanged,
          _editing,
        ),
      ),
      buildFormRow(
        Icons.location_on,
        buildLoadingEntranceFormField(
          context,
          key: _loadingEntranceKey,
          initialValue: order.loadingEntrance,
          additionalErrorText: hasLoadingEntranceCoordinateMismatch(
                  order, configurationLoader.configuration)
              ? localizationUtil.coordinateMismatch
              : null,
          loadingPointServerAPI:
              dependencyState.network.serverAPI.loadingPoints,
          cacheMap: dependencyState.caches.loadingEntrance,
          loadingPoint: _loadingPointKey.currentState != null
              ? _loadingPointKey.currentState.value
              : order.loadingPoint,
          enabled: _editing,
        ),
      ),
      buildFormRow(
        null,
        DateFormField(
          key: _loadingDateKey,
          initialValue: order.loadingDate?.toLocal(),
          pickerMode: CupertinoDatePickerMode.dateAndTime,
          minuteInterval: 60,
          label: localizationUtil.loadingDateTime,
          validator: RequiredValidator(context),
          enabled: _editing,
        ),
      ),
    ]);
  }

  Widget _buildArticleGroup(DependencyState dependencyState, Order order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      if (widget.user.role == Role.customer) ...[
        buildFormRow(
          Icons.local_mall,
          buildArticleTypeFormField(
            context,
            _articleTypeListKey,
            order.articleBrand?.type,
            dependencyState.network.serverAPI.articleTypes,
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
            order.articleBrand,
            dependencyState.network.serverAPI.articleBrands,
            dependencyState.caches.articleBrand,
            _articleTypeListKey.currentState != null
                ? _articleTypeListKey.currentState.value
                : order.articleBrand?.type,
            _editing,
          ),
        ),
      ] else ...[
        buildFormRow(
          Icons.local_mall,
          buildArticleTypeDisplayFormField(
              context, _articleTypeKey, order.articleBrand?.type),
        ),
        buildFormRow(
          null,
          buildSupplierArticleBrandFormField(
            context,
            _articleBrandKey,
            order.articleBrand,
            dependencyState.network.serverAPI.suppliers,
            dependencyState.caches.supplierArticleBrand,
            _supplierKey.currentState != null
                ? _supplierKey.currentState.value
                : order.supplier,
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
          initialValue: numberOrEmpty(order.tonnage),
          label: localizationUtil.tonnage,
          validator: makeRequiredTonnageValidator(context),
          enabled: _editing && order.distributedTonnage == 0,
        ),
      ),
      OrderDistanceFormRow(
        key: _distanceKey,
        initialValue: order.distance,
        loadingPoint: _loadingPointKey.currentState != null
            ? _loadingPointKey.currentState.value
            : order.loadingPoint,
        unloadingPoint: _unloadingPointKey.currentState != null
            ? _unloadingPointKey.currentState.value
            : order.unloadingPoint,
        editing: _editing,
      ),
    ]);
  }

  Widget _buildPriceGroup(DependencyState dependencyState, Order order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      if (widget.user.canManageOrderSalePrice()) ...[
        buildFormRow(
          Icons.account_balance_wallet,
          EnumerationFormField<PriceType>(
            context,
            key: _salePriceTypeKey,
            initialValue: order.salePriceType ?? order.customer?.priceType,
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
            initialValue: numberOrEmpty(order.saleTariff),
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
          initialValue: order.deliveryPriceType ?? PriceType.notOneTime,
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
          initialValue: numberOrEmpty(order.deliveryTariff),
          label: localizationUtil.deliveryTariff,
          validator: NumberValidator(context, decimal: true, minimum: 0),
          enabled: _editing,
        ),
      ),
    ]);
  }

  Widget _buildMiscellaneousGroup(
      DependencyState dependencyState, Order order) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.comment,
        CustomTextFormField(
          key: _commentKey,
          initialValue: textOrEmpty(order.comment),
          label: localizationUtil.comment,
          enabled: _editing,
        ),
      ),
      if (widget.user.role != Role.customer)
        buildFormRow(
          null,
          buildCustomIntegerFormField(
            context,
            key: _inactivityTimeIntervalKey,
            initialValue: formatHours(
                order.inactivityTimeInterval ?? defaultInactivityTimeInterval),
            label: localizationUtil.inactivityTimeInterval,
            enabled: _editing,
          ),
        ),
    ]);
  }

  void _handleLoadingTypeChanged(LoadingType value) {
    _supplierKey.currentState.value = null;
    setState(() {});
  }

  void _handleSupplierChanged(Supplier value) {
    _loadingPointKey.currentState.value = null;
    _articleBrandKey.currentState.value = null;
    setState(() {});
  }

  void _handleCustomerChanged(Customer value) {
    _unloadingPointKey.currentState.value = null;
    if (_salePriceTypeKey.currentState != null)
      _salePriceTypeKey.currentState.value =
          _customerKey.currentState.value.priceType;
    setState(() {});
  }

  void _handleLoadingPointChanged(LoadingPoint value) {
    _loadingEntranceKey.currentState.value = null;
    setState(() {});
  }

  void _handleUnloadingPointChanged(UnloadingPoint value) {
    if (_unloadingEntranceKey.currentState != null)
      _unloadingEntranceKey.currentState.value = null;
    _unloadingContactKey.currentState.value = null;
    setState(() {});
  }

  void _handleArticleTypeChanged(ArticleType value) {
    _articleBrandKey.currentState.value = null;
    setState(() {});
  }

  void _handleArticleBrandChanged(ArticleBrand value) {
    _articleTypeKey.currentState.value = value?.type?.name;
    setState(() {});
  }

  LoadingType _getInitialLoadingType() =>
      widget.order.supplier?.getLoadingType() ?? LoadingType.supplier;

  static const defaultInactivityTimeInterval = 24 * 60 * 60 * 1000;
}
