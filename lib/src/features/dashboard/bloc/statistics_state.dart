part of 'statistics_bloc.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsState {
  @override
  List<Object> get props => [];
}

class StatisticsFetchState extends StatisticsState {
  final bool refreshing;

  const StatisticsFetchState({this.refreshing});
}

class FetchingStatistics extends StatisticsFetchState {
  const FetchingStatistics({ bool refreshing });
}

class FetchingStatisticsSuccess extends StatisticsFetchState {
  final StatisticsModel statistics;

  const FetchingStatisticsSuccess({bool refreshing , @required this.statistics});

  @override
  List<Object> get props => [statistics];

  @override
  String toString() => 'FetchingStatisticsSuccess { data: ${statistics.toString()} }';
}

class FetchingStatisticsFailure extends StatisticsFetchState {
  final String error;

  const FetchingStatisticsFailure({bool refreshing , @required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'FetchingStatisticsFailure { error: $error }';
}
