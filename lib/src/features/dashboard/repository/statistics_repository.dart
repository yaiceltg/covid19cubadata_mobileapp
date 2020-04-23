import 'dart:convert';

import 'package:covid19_cuba/src/features/dashboard/models/statistics_model.dart';
import 'package:http/http.dart' as http;

class StatisticsRepository {
  Future<StatisticsModel> fetchData() async {
    final _url = 'https://covid19cubadata.github.io';

    final _response = await http.get('$_url/data/covid19-cuba.json');

    // final _provincias = await http.get('$_url/data/provincias.geojson');

    final _municipios = await http.get('$_url/data/municipios.geojson');

    final Map<dynamic, dynamic> decodedData =
        json.decode(utf8.decode(_response.bodyBytes));


    StatisticsModel data = StatisticsModel.fromJson(decodedData);

    // build report
    data.buildReports();

    return data;
  }
}
