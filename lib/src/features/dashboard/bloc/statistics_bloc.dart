import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:covid19_cuba/src/features/dashboard/models/statistics_model.dart';
import 'package:covid19_cuba/src/features/dashboard/repository/statistics_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  StatisticsRepository statisticsRepository;

  StatisticsBloc({@required this.statisticsRepository});

  @override
  StatisticsState get initialState => StatisticsInitial();

  @override
  Stream<StatisticsState> mapEventToState(
    StatisticsEvent event,
  ) async* {
    if (event is FetchStatistics) {
      yield FetchingStatistics(refreshing: false);

      try {
        StatisticsModel statistics = await statisticsRepository.fetchData();

        yield FetchingStatisticsSuccess(statistics: statistics, refreshing: false);
      } catch (err) {
        yield FetchingStatisticsFailure(error: err, refreshing: false);
      }
    }

    if (event is ReFetchStatistics) {
      // yield FetchingStatistics(refreshing: true);

      try {
        StatisticsModel statistics = await statisticsRepository.fetchData();

        yield FetchingStatisticsSuccess(statistics: statistics, refreshing: true);
      } catch (err) {
        yield FetchingStatisticsFailure(error: err, refreshing: true);
      }
    }
  }
}
