import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:ecats/account/loading_body_widget.dart';
import 'package:ecats/assets/constants.dart' as Constants;
import 'package:ecats/models/enums/app_bar_enum.dart';
import 'package:ecats/models/enums/page_enum.dart';
import 'package:ecats/models/requests/income_transaction_request_model.dart';
import 'package:ecats/models/requests/my_income_transaction_request_model.dart';
import 'package:ecats/models/table_data_sources/income_transactions_by_user_data_source.dart';
import 'package:ecats/services/http_service.dart';
import 'package:flutter/material.dart';

import './shared/data_table/custom_pager.dart';
import './shared/data_table/nav_helper.dart';

class IncomeTransactionsBodyWidget extends StatefulWidget {
  final void Function(PageEnum, AppBarEnum) screenCallback;

  const IncomeTransactionsBodyWidget({super.key, required this.screenCallback});

  @override
  State<IncomeTransactionsBodyWidget> createState() =>
      _IncomeTransactionsBodyWidgetState();
}

class _IncomeTransactionsBodyWidgetState
    extends State<IncomeTransactionsBodyWidget> {
  final _httpService = HttpService();
  bool isLoading = true;

  //final int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  //int? _sortColumnIndex;
  //bool _sortAscending = true;
  PaginatorController? _controller;

  late IncomeTransactionsByUserDataSouce _incomeTransactionsDataSource;
  late MyIncomeTransactionRequestModel _model;

  @override
  void initState() {
    super.initState();

    _updateData();
  }

  @override
  void dispose() {
    _incomeTransactionsDataSource.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller = PaginatorController();

    //if (getCurrentRouteOption(context) == defaultSorting) {
    //_sortColumnIndex = 1;
    //}
  }

  Future _updateData() async {
    setState(() => isLoading = true);

    var uri = Uri.https(Constants.SERVER_URL,
        Constants.ServerApiEndpoints.USER_INCOME_TRANSACTIONS);
    var response = await _httpService.get(uri);
    var value = await response.stream.bytesToString();

    _model = MyIncomeTransactionRequestModel.fromJson(jsonDecode(value));
    _incomeTransactionsDataSource =
        IncomeTransactionsByUserDataSouce(context, _model);

    setState(() => isLoading = false);
  }

  void sort<T>(Comparable<T> Function(EventRequestModel d) getField,
      int columnIndex, bool ascending) {
    _incomeTransactionsDataSource.sort<T>(getField, ascending);
    //setState(() {
    //_sortColumnIndex = columnIndex;
    //_sortAscending = ascending;
    //});
  }

  List<DataColumn> get _columns {
    return [
      const DataColumn2(
        size: ColumnSize.S,
        label: Text('Currency acronim', textAlign: TextAlign.left),
      ),
      const DataColumn2(
          size: ColumnSize.S,
          label: Text('Amount', textAlign: TextAlign.right),
          numeric: true),
      const DataColumn2(
          size: ColumnSize.S,
          label: Text('Transaction fee', textAlign: TextAlign.right),
          numeric: true),
      const DataColumn2(
          size: ColumnSize.S,
          label: Text('From address', textAlign: TextAlign.right),
          numeric: true),
      const DataColumn2(
          size: ColumnSize.S,
          label: Text('To address', textAlign: TextAlign.center)),
      const DataColumn2(
          size: ColumnSize.L, label: Text('Date', textAlign: TextAlign.center)),
    ];
  }

  String getCurrentRouteOption(BuildContext context) {
    var isEmpty = ModalRoute.of(context) != null &&
            ModalRoute.of(context)!.settings.arguments != null &&
            ModalRoute.of(context)!.settings.arguments is String
        ? ModalRoute.of(context)!.settings.arguments as String
        : '';

    return isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingBodyWidget()
        : Center(
            child: Stack(alignment: Alignment.bottomCenter, children: [
            PaginatedDataTable2(
              dataRowHeight: 35,
              headingRowHeight: 40,
              fixedLeftColumns: 5,
              showCheckboxColumn: false,
              horizontalMargin: 20,
              checkboxHorizontalMargin: 12,
              columnSpacing: 0,
              wrapInCard: false,
              renderEmptyRowsInTheEnd: false,
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.grey[200]!),
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Income transactions'),
                  //if (getCurrentRouteOption(context) == custPager &&
                  // _controller != null)
                  //PageNumber(controller: _controller!),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          await _updateData();
                        },
                      ),
                    ),
                  )
                ],
              ),
              //rowsPerPage: _rowsPerPage,
              autoRowsToHeight: getCurrentRouteOption(context) == autoRows,
              fit: FlexFit.tight,
              border: const TableBorder(
                  top: BorderSide(width: 0, style: BorderStyle.none),
                  bottom: BorderSide(width: 0, style: BorderStyle.none),
                  left: BorderSide(width: 0, style: BorderStyle.none),
                  right: BorderSide(width: 0, style: BorderStyle.none),
                  verticalInside: BorderSide(width: 0, style: BorderStyle.none),
                  horizontalInside: BorderSide(color: Colors.grey, width: 0.2)),
              //onRowsPerPageChanged: (value) {
              // _rowsPerPage = value!;
              //},
              initialFirstRowIndex: 0,
              //onPageChanged: (rowIndex) {
              //TODO: pagination
              //},
              //sortColumnIndex: _sortColumnIndex,
              //sortAscending: _sortAscending,
              //sortArrowIcon: Icons.keyboard_arrow_up,
              // custom arrow
              //sortArrowAnimationDuration: const Duration(milliseconds: 0),
              // custom animation duration
              //onSelectAll: _incomeTransactions.selectAll,
              //controller: getCurrentRouteOption(context) == custPager
              //? _controller
              //: null,
              //hidePaginator: getCurrentRouteOption(context) == custPager,
              hidePaginator: true,
              columns: _columns,
              empty: Center(
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.grey[200],
                      child: const Text('No data'))),
              source: getCurrentRouteOption(context) == noData
                  ? IncomeTransactionsByUserDataSouce.empty(context)
                  : _incomeTransactionsDataSource,
            ),
            if (getCurrentRouteOption(context) == custPager)
              Positioned(bottom: 16, child: CustomPager(_controller!))
          ]));
  }
}
