import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/stage.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class TripProblemListWidget extends StatelessWidget {
  final Order order;

  TripProblemListWidget(this.order);

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(title: Text(localizationUtil.orderProblems)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final offer = order.getAcceptedOffer();
    final trip = offer?.trip;
    final problems = trip?.problems;
    if (problems != null && problems.isNotEmpty) {
      return _buildListView(problems, trip);
    }
    return _buildPlaceholder(context);
  }

  Widget _buildListView(List<TripProblem?> problems, Trip? trip) {
    return ListView.separated(
      itemCount: problems.length,
      itemBuilder: (BuildContext context, int index) =>
          _buildCell(context, problems[index]!, trip),
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  Widget _buildCell(BuildContext context, TripProblem problem, Trip? trip) {
    return ListTile(
      title: Text(_titleForProblem(context, problem.type)),
      subtitle: Text(_subtitleForProblem(context, problem, trip)),
      isThreeLine: true,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return FullscreenPlaceholder(
        icon: Icons.error_outline, text: localizationUtil.noProblems);
  }

  String _titleForProblem(BuildContext context, TripProblemType? problemType) {
    final localizationUtil = LocalizationUtil.of(context);
    switch (problemType) {
      case TripProblemType.breakage:
        return localizationUtil.breakageTitle;
      case TripProblemType.inactivity:
        return localizationUtil.inactivityTitle;
      case TripProblemType.delay:
        return localizationUtil.delayTitle;
      case TripProblemType.stoppage:
        return localizationUtil.stoppageTitle;
      default:
        return localizationUtil.unknownProblemTitle;
    }
  }

  String _subtitleForProblem(
      BuildContext context, TripProblem problem, Trip? trip) {
    switch (problem.type) {
      case TripProblemType.breakage:
        return _subtitleForBreakage(context, problem);
      case TripProblemType.inactivity:
        return _subtitleForInactivity(context, problem);
      case TripProblemType.delay:
        return _subtitleForDelay(context, problem, trip);
      case TripProblemType.stoppage:
        return _subtitleForStoppage(context, problem);
      default:
        return '';
    }
  }

  String _subtitleForBreakage(BuildContext context, TripProblem problem) {
    final localizationUtil = LocalizationUtil.of(context);
    if (problem.date == null) {
      return '';
    }
    final date = formatDateOnly(problem.date!);
    final time = formatTimeOnly(problem.date!);
    return '${localizationUtil.carrierChangedStatus} $date ${localizationUtil.inTime} $time';
  }

  String _subtitleForInactivity(BuildContext context, TripProblem problem) {
    final localizationUtil = LocalizationUtil.of(context);
    if (problem.date == null) {
      return '';
    }
    final date = formatDate(problem.date!);
    return '${localizationUtil.noConnectionSince} $date';
  }

  String _subtitleForDelay(
      BuildContext context, TripProblem problem, Trip? trip) {
    final localizationUtil = LocalizationUtil.of(context);
    if (problem.date == null) {
      return '';
    }
    final timeInterval =
        DateTime.now().difference(problem.date!.toLocal()).inMilliseconds;
    final stage = formatTripStatus(context, trip);
    final timeIntervalString = formatTimeInterval(context, timeInterval);
    return '${localizationUtil.delayDetectedInStage} \"$stage\": $timeIntervalString';
  }

  String _subtitleForStoppage(BuildContext context, TripProblem problem) {
    final localizationUtil = LocalizationUtil.of(context);
    if (problem.date == null) {
      return '';
    }
    final timeInterval =
        DateTime.now().difference(problem.date!.toLocal()).inMilliseconds;
    final timeIntervalString = formatTimeInterval(context, timeInterval);
    return '${localizationUtil.carIsIdle} $timeIntervalString';
  }
}
