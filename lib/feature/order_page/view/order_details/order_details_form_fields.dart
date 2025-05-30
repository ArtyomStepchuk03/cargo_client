import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/contact/phone_number_dial_field.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/feature/add_contact_page/view/add_contact_page.dart';
import 'package:manager_mobile_client/feature/add_entrance_page/view/add_entrance_page.dart';
import 'package:manager_mobile_client/feature/add_unloading_point_page/view/add_unloading_point_page.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_add/customer_add_widget.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_verify/customer_verify_widget.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_cache/data_cache_map.dart';
import 'package:manager_mobile_client/src/logic/data_source/filter_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/article_shape_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/article_type_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/intermediary_server_api.dart';
import 'package:manager_mobile_client/util/format/format.dart';
import 'package:manager_mobile_client/util/format/order.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/required_validator.dart';

import 'order_details_data_sources.dart';

class ArticleShapeSearchPredicate implements SearchPredicate<ArticleShape> {
  bool call(ArticleShape object, String query) =>
      satisfiesQuery(object.name, query);
}

Widget buildArticleShapeFormField(
    BuildContext context,
    Key key,
    ArticleShape initialValue,
    ArticleShapeServerAPI serverAPI,
    SkipPagedDataCache<ArticleShape> cache,
    [bool enabled = true]) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<ArticleShape>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource:
        SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(serverAPI, cache)),
    searchPredicate: ArticleShapeSearchPredicate(),
    formatter: short.formatArticleShapeSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, ArticleShape? object) =>
        SimpleListTile(object?.name),
    onRefresh: cache.clear,
    label: localizationUtil.articleShape,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}

class ArticleTypeSearchPredicate implements SearchPredicate<ArticleType> {
  bool call(ArticleType object, String query) =>
      satisfiesQuery(object.name, query);
}

Widget buildArticleTypeDisplayFormField(
  BuildContext context,
  Key key,
  ArticleType? initialValue,
) {
  final localizationUtil = LocalizationUtil.of(context);
  return CustomTextFormField(
    key: key,
    initialValue: short.formatArticleTypeSafe(context, initialValue),
    label: localizationUtil.articleType,
    loading: false,
    inputType: TextInputType.numberWithOptions(signed: false, decimal: true),
    validator: null,
    enabled: false,
  );
}

Widget buildArticleTypeFormField(
    BuildContext context,
    Key key,
    ArticleType? initialValue,
    ArticleTypeServerAPI serverAPI,
    SkipPagedDataCache<ArticleType> cache,
    ValueChanged<ArticleType?> onChanged,
    [bool enabled = true]) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<ArticleType>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource:
        SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(serverAPI, cache)),
    searchPredicate: ArticleTypeSearchPredicate(),
    formatter: short.formatArticleTypeSafe,
    listViewBuilder: (BuildContext context, ArticleType? object) =>
        SimpleListTile(object?.name),
    onChanged: onChanged,
    onRefresh: cache.clear,
    label: localizationUtil.articleType,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}

Widget buildSupplierArticleTypeFormField(
    BuildContext context,
    Key key,
    ArticleType initialValue,
    SupplierServerAPI supplierServerAPI,
    LimitedDataCacheMap<ArticleType, Supplier>? cacheMap,
    Supplier? supplier,
    ValueChanged<ArticleType?> onChanged,
    [bool enabled = true]) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<ArticleType>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: supplier != null
        ? LimitedDataSourceAdapter(CachedLimitedDataSource(
            SupplierArticleTypeDataSource(supplierServerAPI, supplier),
            cacheMap!.getCache(supplier),
          ))
        : null,
    searchPredicate: ArticleTypeSearchPredicate(),
    formatter: short.formatArticleTypeSafe,
    listViewBuilder: (BuildContext context, ArticleType? object) =>
        SimpleListTile(object?.name),
    onChanged: onChanged,
    onRefresh:
        supplier != null ? () => cacheMap?.getCache(supplier).clear() : null,
    label: localizationUtil.articleType,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}

class ArticleBrandSearchPredicate implements SearchPredicate<ArticleBrand> {
  bool call(ArticleBrand object, String query) =>
      satisfiesQuery(object.name, query);
}

Widget buildArticleBrandFormField(
    BuildContext context,
    Key key,
    ArticleBrand? initialValue,
    ArticleBrandServerAPI serverAPI,
    SkipPagedDataCacheMap<ArticleBrand, ArticleType> cacheMap,
    ArticleType? articleType,
    [bool enabled = true]) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<ArticleBrand>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: articleType != null
        ? SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
            ArticleBrandDataSource(serverAPI, articleType),
            cacheMap.getCache(articleType),
          ))
        : null,
    searchPredicate: ArticleBrandSearchPredicate(),
    formatter: short.formatArticleBrandSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, ArticleBrand? object) =>
        SimpleListTile(object?.name),
    onRefresh: articleType != null
        ? () => cacheMap.getCache(articleType).clear()
        : null,
    label: localizationUtil.articleBrand,
    validator: RequiredValidator(context),
    enabled: enabled && articleType != null,
  );
}

Widget buildSupplierArticleBrandFormField(
    BuildContext context,
    Key key,
    ArticleBrand? initialValue,
    SupplierServerAPI supplierServerAPI,
    LimitedDataCacheMap<ArticleBrand, Supplier> cacheMap,
    Supplier? supplier,
    ValueChanged<ArticleBrand?> onChanged,
    [bool enabled = true]) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<ArticleBrand>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: supplier != null
        ? LimitedDataSourceAdapter(CachedLimitedDataSource(
            SupplierArticleBrandDataSource(supplierServerAPI, supplier),
            cacheMap.getCache(supplier),
          ))
        : null,
    searchPredicate: ArticleBrandSearchPredicate(),
    formatter: short.formatArticleBrandSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, ArticleBrand? object) =>
        SimpleListTile(object?.name),
    onChanged: onChanged,
    onRefresh:
        supplier != null ? () => cacheMap.getCache(supplier).clear() : null,
    label: localizationUtil.articleBrand,
    validator: RequiredValidator(context),
    enabled: enabled && supplier != null,
  );
}

class IntermediarySearchPredicate implements SearchPredicate<Intermediary> {
  bool call(Intermediary object, String query) =>
      satisfiesQuery(object.name, query);
}

Widget buildIntermediaryFormField(
    BuildContext context,
    Key key,
    Intermediary? initialValue,
    IntermediaryServerAPI serverAPI,
    SkipPagedDataCache<Intermediary> cache,
    [bool enabled = true]) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<Intermediary>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource:
        SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(serverAPI, cache)),
    searchPredicate: IntermediarySearchPredicate(),
    formatter: short.formatIntermediarySafe,
    listViewBuilder: (BuildContext context, Intermediary? object) =>
        SimpleListTile(object?.name),
    onRefresh: cache.clear,
    label: localizationUtil.intermediary,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}

Widget buildSupplierFormField(
  BuildContext context, {
  DependencyState? dependencyState,
  Key? key,
  Supplier? initialValue,
  LoadingType? loadingType,
  User? user,
  ValueChanged<Supplier?>? onChanged,
  bool enabled = true,
}) {
  if (user?.role == Role.dispatcher &&
      user?.carrier?.showAllSuppliers == false) {
    return _buildSupplierFormField(
      context,
      key: key,
      initialValue: initialValue,
      dataSource: FilterDataSource(
        LimitedDataSourceAdapter(CachedLimitedDataSource(
          AllowedSupplierDataSource(
              dependencyState!.network.serverAPI.carriers, user!.carrier!),
          dependencyState.caches.allowedSupplier.getCache(user.carrier!),
        )),
        TransferSupplierPredicate(loadingType == LoadingType.transfer),
      ),
      onChanged: onChanged,
      onRefresh: () => dependencyState.caches.allowedSupplier
          .getCache(user.carrier!)
          .clear(),
      enabled: enabled,
    );
  }
  return _buildSupplierFormField(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
      SupplierDataSource(dependencyState!.network.serverAPI.suppliers,
          loadingType == LoadingType.transfer),
      dependencyState.caches.supplier
          .getCache(loadingType == LoadingType.transfer),
    )),
    onChanged: onChanged,
    onRefresh: () => dependencyState.caches.supplier
        .getCache(loadingType == LoadingType.transfer)
        .clear(),
    enabled: enabled,
  );
}

class LoadingPointSearchPredicate implements SearchPredicate<LoadingPoint> {
  bool call(LoadingPoint object, String query) =>
      satisfiesQuery(object.address, query);
}

Widget buildLoadingPointFormField(
    BuildContext context,
    Key? key,
    LoadingPoint? initialValue,
    SupplierServerAPI? supplierServerAPI,
    LimitedDataCacheMap<LoadingPoint, Supplier>? cacheMap,
    Supplier? supplier,
    ValueChanged<LoadingPoint?>? onChanged,
    [bool enabled = true]) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<LoadingPoint>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: supplier != null
        ? LimitedDataSourceAdapter(CachedLimitedDataSource(
            LoadingPointDataSource(supplierServerAPI!, supplier),
            cacheMap!.getCache(supplier),
          ))
        : null,
    searchPredicate: LoadingPointSearchPredicate(),
    formatter: short.formatLoadingPointSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, LoadingPoint? object) =>
        SimpleListTile(object?.address),
    onChanged: onChanged,
    onRefresh:
        supplier != null ? () => cacheMap?.getCache(supplier).clear() : null,
    label: localizationUtil.loadingPoint,
    validator: RequiredValidator(context),
    enabled: enabled && supplier != null,
  );
}

Widget buildLoadingEntranceFormField(
  BuildContext context, {
  Key? key,
  Entrance? initialValue,
  String? additionalErrorText,
  LoadingPointServerAPI? loadingPointServerAPI,
  LimitedDataCacheMap<Entrance, LoadingPoint>? cacheMap,
  LoadingPoint? loadingPoint,
  bool enabled = true,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return _buildEntranceFormField(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: loadingPoint != null
        ? LimitedDataSourceAdapter(CachedLimitedDataSource(
            LoadingEntranceDataSource(loadingPointServerAPI!, loadingPoint),
            cacheMap!.getCache(loadingPoint),
          ))
        : null,
    additionalErrorText: additionalErrorText,
    onRefresh: loadingPoint != null
        ? () => cacheMap?.getCache(loadingPoint).clear()
        : null,
    label: localizationUtil.loadingEntrance,
    enabled: enabled && loadingPoint != null,
  );
}

Widget buildCustomerFormField(
  BuildContext context, {
  required DependencyState dependencyState,
  Key? key,
  Customer? initialValue,
  User? user,
  ValueChanged<Customer?>? onChanged,
  bool enabled = true,
}) {
  if (user?.role == Role.dispatcher &&
      user?.carrier?.showAllCustomers == false) {
    return _buildCustomerFormField(
      context,
      key: key,
      initialValue: initialValue,
      user: user,
      dataSource: LimitedDataSourceAdapter(CachedLimitedDataSource(
        AllowedCustomerDataSource(
            dependencyState.network.serverAPI.carriers, user!.carrier!),
        dependencyState.caches.allowedCustomer.getCache(user.carrier!),
      )),
      onChanged: onChanged,
      onRefresh: () => dependencyState.caches.allowedCustomer
          .getCache(user.carrier!)
          .clear(),
      enabled: enabled,
    );
  }
  return _buildCustomerFormField(
    context,
    key: key,
    initialValue: initialValue,
    user: user,
    dataSource: SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
      dependencyState.network.serverAPI.customers,
      dependencyState.caches.customer,
    )),
    onChanged: onChanged,
    onRefresh: dependencyState.caches.customer.clear,
    enabled: enabled,
  );
}

class UnloadingPointSearchPredicate implements SearchPredicate<UnloadingPoint> {
  bool call(UnloadingPoint object, String query) =>
      satisfiesQuery(object.address, query);
}

Widget buildUnloadingPointFormField({
  required BuildContext context,
  Key? key,
  UnloadingPoint? initialValue,
  String? noteText,
  CustomerServerAPI? customerServerAPI,
  LimitedDataCacheMap<UnloadingPoint, Customer>? cacheMap,
  Customer? customer,
  User? user,
  ValueChanged<UnloadingPoint?>? onChanged,
  bool enabled = true,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<UnloadingPoint>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: customer != null
        ? LimitedDataSourceAdapter(CachedLimitedDataSource(
            UnloadingPointDataSource(customerServerAPI!, customer),
            cacheMap!.getCache(customer),
          ))
        : null,
    searchPredicate: UnloadingPointSearchPredicate(),
    formatter: short.formatUnloadingPointSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, UnloadingPoint? object) =>
        SimpleListTile(object?.address),
    onChanged: onChanged,
    noteText: noteText,
    noteColor: Colors.deepOrangeAccent,
    onRefresh:
        customer != null ? () => cacheMap?.getCache(customer).clear() : null,
    onAdd: user!.canAddUnloadingPoints()
        ? (context) async {
            return await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddUnloadingPointPage(
                    customer: customer, manager: user.manager),
                fullscreenDialog: true,
              ),
            );
          }
        : null,
    label: localizationUtil.unloadingPoint,
    validator: RequiredValidator(context),
    enabled: enabled && customer != null,
  );
}

Widget buildUnloadingEntranceFormField(
  BuildContext context, {
  Key? key,
  Entrance? initialValue,
  String? additionalErrorText,
  UnloadingPointServerAPI? unloadingPointServerAPI,
  LimitedDataCacheMap<Entrance, UnloadingPoint>? cacheMap,
  UnloadingPoint? unloadingPoint,
  User? user,
  bool enabled = true,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return _buildEntranceFormField(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: unloadingPoint != null
        ? LimitedDataSourceAdapter(
            CachedLimitedDataSource(
              UnloadingEntranceDataSource(
                  unloadingPointServerAPI!, unloadingPoint),
              cacheMap!.getCache(unloadingPoint),
            ),
          )
        : null,
    additionalErrorText: additionalErrorText,
    onRefresh: unloadingPoint != null
        ? () => cacheMap?.getCache(unloadingPoint).clear()
        : null,
    onAdd: user!.canAddUnloadingEntrances()
        ? (context) async {
            return await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntranceAddPage(unloadingPoint),
                fullscreenDialog: true,
              ),
            );
          }
        : null,
    label: localizationUtil.unloadingEntrance,
    enabled: enabled && unloadingPoint != null,
  );
}

class ContactSearchPredicate implements SearchPredicate<Contact> {
  bool call(Contact contact, String query) {
    if (satisfiesQuery(contact.name, query)) {
      return true;
    }
    if (satisfiesQuery(contact.phoneNumber, query)) {
      return true;
    }
    return false;
  }
}

Widget buildUnloadingContactFormField(BuildContext context,
    {Key? key,
    Contact? initialValue,
    UnloadingPointServerAPI? unloadingPointServerAPI,
    LimitedDataCacheMap<Contact, UnloadingPoint>? cacheMap,
    UnloadingPoint? unloadingPoint,
    User? user,
    bool editing = true,
    Function(Contact?)? onUpdate}) {
  final localizationUtil = LocalizationUtil.of(context);
  if (!editing) {
    return PhoneNumberDialField(
        phoneNumber: initialValue?.phoneNumber,
        text: formatContactSafe(context, initialValue),
        label: localizationUtil.unloadingContact);
  }
  return LoadingListFormField<Contact>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: unloadingPoint != null
        ? LimitedDataSourceAdapter(
            CachedLimitedDataSource(
              UnloadingContactDataSource(
                  unloadingPointServerAPI!, unloadingPoint),
              cacheMap!.getCache(unloadingPoint),
            ),
          )
        : null,
    searchPredicate: ContactSearchPredicate(),
    formatter: formatContactSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Contact? contact) =>
        SimpleListTile(contact?.name, contact?.phoneNumber),
    onRefresh: unloadingPoint != null
        ? () => cacheMap?.getCache(unloadingPoint).clear()
        : null,
    onDelete: (Contact? contact) async {
      final serverAPI =
          DependencyHolder.of(context).network.serverAPI.unloadingPoints;
      await serverAPI.removeContact(unloadingPoint, contact);
      unloadingPoint?.contacts?.remove(contact);
      // Очищаем кэш после удаления
      cacheMap?.getCache(unloadingPoint!).clear();
    },
    selectedItem: initialValue,
    onUpdate: onUpdate,
    onAdd: user!.canAddUnloadingContacts()
        ? (context) async {
            try {
              Contact? contact = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddContactPage(unloadingPoint: unloadingPoint),
                  fullscreenDialog: true,
                ),
              );

              if (contact != null) {
                // Обновляем локальный список контактов в unloadingPoint
                if (unloadingPoint?.contacts == null) {
                  unloadingPoint?.contacts = [];
                }
                unloadingPoint?.contacts?.add(contact);

                // Очищаем кэш, чтобы данные обновились
                cacheMap?.getCache(unloadingPoint!).clear();

                // Вызываем onUpdate для обновления UI
                if (onUpdate != null) {
                  await onUpdate(contact);
                }

                return contact;
              }
              // Если contact == null, выбрасываем исключение или возвращаем dummy contact
              throw Exception('Contact creation was cancelled');
            } catch (e) {
              print('Error adding contact: $e');
              // Возвращаем dummy contact или перебрасываем исключение
              throw Exception('Failed to add contact: $e');
            }
          }
        : null,
    label: localizationUtil.unloadingContact,
    validator: RequiredValidator(context),
    enabled: unloadingPoint != null,
  );
}

class SupplierSearchPredicate implements SearchPredicate<Supplier> {
  bool call(Supplier object, String query) {
    if (satisfiesQuery(object.name, query)) {
      return true;
    }
    if (satisfiesQuery(object.itn, query)) {
      return true;
    }
    return false;
  }
}

class CustomerSearchPredicate implements SearchPredicate<Customer> {
  bool call(Customer object, String query) {
    if (satisfiesQuery(object.name, query)) {
      return true;
    }
    if (satisfiesQuery(object.itn, query)) {
      return true;
    }
    return false;
  }
}

class EntranceSearchPredicate implements SearchPredicate<Entrance> {
  bool call(Entrance object, String query) =>
      satisfiesQuery(object.name, query) ||
      satisfiesQuery(object.address, query);
}

Widget _buildSupplierFormField(
  BuildContext context, {
  Key? key,
  Supplier? initialValue,
  DataSource<Supplier>? dataSource,
  ValueChanged<Supplier?>? onChanged,
  VoidCallback? onRefresh,
  bool enabled = true,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<Supplier>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: dataSource,
    searchPredicate: SupplierSearchPredicate(),
    formatter: short.formatSupplierSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Supplier? object) =>
        SimpleListTile(object?.name, object?.itn),
    onChanged: onChanged,
    onRefresh: onRefresh,
    label: localizationUtil.supplier,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}

Widget _buildCustomerFormField(
  BuildContext context, {
  Key? key,
  Customer? initialValue,
  User? user,
  DataSource<Customer>? dataSource,
  ValueChanged<Customer?>? onChanged,
  VoidCallback? onRefresh,
  bool enabled = true,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<Customer>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: dataSource,
    searchPredicate: CustomerSearchPredicate(),
    formatter: short.formatCustomerSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Customer? customer) {
      return SimpleListTile(customer?.name, customer?.itn,
          customer?.internal == true ? null : Icons.keyboard_arrow_right);
    },
    onChanged: onChanged,
    onRefresh: onRefresh,
    onSelect: (BuildContext context, Customer customer) async {
      if (customer.internal = true) {
        Navigator.pop(context, customer);
      } else {
        final accepted = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => CustomerVerifyWidget(customer),
            ));
        if (accepted != null && accepted) {
          Navigator.pop(context, customer);
        }
      }
    },
    onAdd: user!.canAddCustomers()
        ? (context) async {
            return await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerAddWidget(manager: user.manager),
                fullscreenDialog: true,
              ),
            );
          }
        : null,
    label: localizationUtil.customer,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}

Widget _buildEntranceFormField(
  BuildContext context, {
  Key? key,
  Entrance? initialValue,
  DataSource<Entrance>? dataSource,
  String? additionalErrorText,
  VoidCallback? onRefresh,
  LoadingListFormFieldAddCallback<Entrance>? onAdd,
  String? label,
  bool enabled = true,
}) {
  return LoadingListFormField<Entrance>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: dataSource,
    searchPredicate: EntranceSearchPredicate(),
    formatter: short.formatEntranceSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Entrance? object) =>
        SimpleListTile(object?.name, object?.address),
    noteText: additionalErrorText,
    noteColor: Colors.red,
    onRefresh: onRefresh,
    onAdd: onAdd,
    label: label,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}
