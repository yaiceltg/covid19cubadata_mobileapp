part of 'statistics_bloc.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object> get props => [];
}

class FetchStatistics extends StatisticsEvent {}

class ReFetchStatistics extends StatisticsEvent {}
