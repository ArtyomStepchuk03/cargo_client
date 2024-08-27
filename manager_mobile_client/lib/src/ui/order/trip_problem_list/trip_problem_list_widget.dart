import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/stage.dart';
import 'trip_problem_list_strings.dart' as strings;

class TripProblemListWidget extends StatelessWidget {
  final Order order;

  TripProblemListWidget(this.order);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: Text(strings.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final offer = order.getAcceptedOffer();
    final trip = offer?.trip;
    final problems = trip?.problems;
    if (problems != null && problems.isNotEmpty) {
      return _buildListView(problems, trip);
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildListView(List<TripProblem> problems, Trip trip) {
    return ListView.separated(
      itemCount: problems.length,
      itemBuilder: (BuildContext context, int index) => _buildCell(problems[index], trip),
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  Widget _buildCell(TripProblem problem, Trip trip) {
    return ListTile(
      title: Text(_titleForProblem(problem.type)),
      subtitle: Text(_subtitleForProblem(problem, trip)),
      isThreeLine: true,
    );
  }

  Widget _buildPlaceholder() {
    return FullscreenPlaceholder(
      icon: Icons.error_outline,
      text: strings.noProblems
    );
  }

  String _titleForProblem(TripProblemType problemType) {
    switch (problemType) {
      case TripProblemType.breakage: return strings.breakageTitle;
      case TripProblemType.inactivity: return strings.inactivityTitle;
      case TripProblemType.delay: return strings.delayTitle;
      case TripProblemType.stoppage: return strings.stoppageTitle;
      default: return strings.unknownProblemTitle;
    }
  }

  String _subtitleForProblem(TripProblem problem, Trip trip) {
    switch (problem.type) {
      case TripProblemType.breakage: return _subtitleForBreakage(problem);
      case TripProblemType.inactivity: return _subtitleForInactivity(problem);
      case TripProblemType.delay: return _subtitleForDelay(problem, trip);
      case TripProblemType.stoppage: return _subtitleForStoppage(problem);
      default: return '';
    }
  }

  String _subtitleForBreakage(TripProblem problem) {
    if (problem.date == null) {
      return '';
    }
    final date = formatDateOnly(problem.date);
    final time = formatTimeOnly(problem.date);
    return strings.breakageSubtitle(date, time);
  }

  String _subtitleForInactivity(TripProblem problem) {
    if (problem.date == null) {
      return '';
    }
    final date = formatDate(problem.date);
    return strings.inactivitySubtitle(date);
  }

  String _subtitleForDelay(TripProblem problem, Trip trip) {
    if (problem.date == null) {
      return '';
    }
    final timeInterval = DateTime.now().difference(problem.date.toLocal()).inMilliseconds;
    final stage = formatTripStatus(trip);
    final timeIntervalString = formatTimeInterval(timeInterval);
    return strings.delaySubtitle(stage, timeIntervalString);
  }

  String _subtitleForStoppage(TripProblem problem) {
    if (problem.date == null) {
      return '';
    }
    final timeInterval = DateTime.now().difference(problem.date.toLocal()).inMilliseconds;
    final timeIntervalString = formatTimeInterval(timeInterval);
    return strings.stoppageSubtitle(timeIntervalString);
  }
}
