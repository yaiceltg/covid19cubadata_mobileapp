import 'dart:async';

import 'package:covid19_cuba/src/features/dashboard/bloc/statistics_bloc.dart';
import 'package:covid19_cuba/src/features/dashboard/models/statistics_model.dart';
import 'package:covid19_cuba/src/features/dashboard/repository/statistics_repository.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_bloc/flutter_bloc.dart';

class DashBoardScreen extends StatefulWidget {
  DashBoardScreen({Key key}) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  StatisticsRepository statisticsRepository = StatisticsRepository();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return StatisticsBloc(statisticsRepository: statisticsRepository)
          ..add(FetchStatistics());
      },
      child: Scaffold(
          backgroundColor: Color(0xffecf0f1),
          appBar: AppBar(
            title: Text('Covid19 Cuba Dashboard'),
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.info_outline),
                tooltip: 'Orientaciones para el público',
                onPressed: () {
                  Navigator.of(context).pushNamed('info');
                },
              ),
            ],
          ),
          body: BlocConsumer<StatisticsBloc, StatisticsState>(
              listener: (context, state) {
            if (state is FetchingStatisticsSuccess) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          }, builder: (context, state) {
            if (state is FetchingStatistics) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is FetchingStatisticsFailure &&
                state.refreshing == false) {
              return Center(
                child: Text('Ha ocurrido un error al cargar los datos'),
              );
            }

            if (state is FetchingStatisticsSuccess) {
              if (state.statistics == null) {
                return Center(
                  child: Text('No hay datos'),
                );
              }

              return RefreshIndicator(
                onRefresh: () {
                  BlocProvider.of<StatisticsBloc>(context).add(
                    ReFetchStatistics(),
                  );
                  return _refreshCompleter.future;
                },
                child: ListView(
                  children: <Widget>[
                    _buildHeader(context, state),
                    _buildChartBySex(context, state.statistics.sex),
                    _buildChartByContagion(context, state.statistics.contagios),
                    _buildDistributionByRange(context),
                    _buildFooter(context, state.statistics.casos),
                  ],
                ),
              );
            }

            return Center(
              child: Text('No hay datos'),
            );
          })),
    );
  }

  _buildHeader(BuildContext context, state) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
        color: Theme.of(context).primaryColor,
        height: 368.0,
        child: Column(
          children: <Widget>[
            Container(
              height: 180.0,
              child: _buildEvolution(context, state.statistics.casos),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 128,
              child: _buildResume(context, state.statistics.resume),
            )
          ],
        ),
      ),
    );
  }

  _buildEvolution(BuildContext context, Casos days) {
    List<ChartLinePoint> data = [];

    int accumulate = 0;
    days.dias.forEach((date, day) {
      accumulate += day.diagnosticados == null ? 0 : day.diagnosticados.length;
      List<String> _a = day.fecha.split("/");
      data.add(ChartLinePoint(
          new DateTime(int.parse(_a[0]), int.parse(_a[1]), int.parse(_a[2])),
          accumulate));
    });

    List<charts.Series<ChartLinePoint, DateTime>> seriesList = [
      charts.Series<ChartLinePoint, DateTime>(
        id: 'Cost',
        colorFn: (_, __) => charts.MaterialPalette.white,
        domainFn: (ChartLinePoint row, _) => row.timeStamp,
        measureFn: (ChartLinePoint row, _) => row.cost,
        data: data,
      )
    ];

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: charts.TimeSeriesChart(
          seriesList,
          animate: true,
          primaryMeasureAxis: new charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                  lineStyle: charts.LineStyleSpec(
            dashPattern: [4, 4],
          ))),
          behaviors: [],
        ));
  }

  _buildResume(BuildContext context, Map<String, int> contagios) {
    List<Stat> _stats = List();

    contagios.forEach((key, value) {
      _stats.add(Stat(key, value.toString()));
    });

    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stats.length,
        itemBuilder: (BuildContext context, int index) {
          Stat stat = _stats[index];
          return Padding(
            padding: EdgeInsets.only(
                left: 20.0,
                top: 15,
                bottom: 20.0,
                right: _stats.length - 1 > index ? 0 : 20.0),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 80.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(5, 5))
                      ]),
                  child: Center(
                    child: ListTile(
                      title: Text(
                        stat.value,
                        style: TextStyle(fontSize: 24.0, color: Colors.black),
                      ),
                      subtitle: Text(
                        stat.name,
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  _buildChartBySex(BuildContext context, Map<String, int> sex) {
    List<LinearSales> data = [];

    sex.forEach((key, value) {
      data.add(LinearSales(key, value));
    });

    List<charts.Series> seriesList = [
      new charts.Series<LinearSales, String>(
        id: 'CasosPorSexo',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        colorFn: (_, __) => _.year == 'Mujeres'
            ? charts.MaterialPalette.deepOrange.shadeDefault
            : charts.MaterialPalette.blue.shadeDefault,
      ),
    ];

    return Container(
        margin: EdgeInsets.all(12.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(5, 5))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Casos por sexo'),
            SizedBox(height: 12.0),
            Container(
              height: 128,
              decoration: BoxDecoration(),
              child: charts.PieChart(
                seriesList,
                animate: true,
                defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 40,
                  // arcRendererDecorators: [new charts.ArcLabelDecorator()]
                ),
                behaviors: [
                  new charts.DatumLegend(
                    position: charts.BehaviorPosition.end,
                    horizontalFirst: false,
                    cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                    showMeasures: true,
                    legendDefaultMeasure:
                        charts.LegendDefaultMeasure.firstValue,
                    measureFormatter: (num value) {
                      return value == null ? '-' : '${value}';
                    },
                  )
                ],
              ),
            ),
          ],
        ));
  }

  _buildChartByContagion(BuildContext context, Map<String, int> items) {
    List<LinearSales> data = [];

    items.forEach((key, value) {
      data.add(LinearSales(key, value));
    });

    final seriesList = [
      new charts.Series<LinearSales, String>(
        id: 'CasosPorModoDeContagio',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        colorFn: (_, __) {
          switch (_.year) {
            case 'importado':
              return charts.MaterialPalette.green.shadeDefault;
              break;
            case 'introducido':
              return charts.MaterialPalette.cyan.shadeDefault;
              break;
            case 'autoctono':
              return charts.MaterialPalette.deepOrange.shadeDefault;
              break;
            case 'desconocido':
              return charts.MaterialPalette.gray.shadeDefault;
              break;
            default:
              return charts.MaterialPalette.blue.shadeDefault;
          }
        },
      )
    ];

    return Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(5, 5))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Casos por modo de contagio'),
            SizedBox(height: 12.0),
            Container(
              height: 128,
              decoration: BoxDecoration(),
              child: charts.PieChart(
                seriesList,
                animate: true,
                defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 40,
                  // arcRendererDecorators: [new charts.ArcLabelDecorator()]
                ),
                behaviors: [
                  new charts.DatumLegend(
                    position: charts.BehaviorPosition.end,
                    horizontalFirst: false,
                    cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                    showMeasures: true,
                    legendDefaultMeasure:
                        charts.LegendDefaultMeasure.firstValue,
                    measureFormatter: (num value) {
                      return value == null ? '-' : '${value}';
                    },
                  )
                ],
              ),
            ),
          ],
        ));
  }

  _buildDistributionByRange(BuildContext context) {
    final data = [
      new LinearSales("Importado", 100),
      new LinearSales("Introducido", 75),
      new LinearSales("Autóctono", 25),
      new LinearSales("Desconocido", 5),
    ];

    final seriesList = [
      new charts.Series<LinearSales, String>(
        id: 'CasosPorModoDeContagio',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];

    return Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(5, 5))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Distribución por rangos etarios'),
            SizedBox(height: 12.0),
            Container(
              height: 128,
              decoration: BoxDecoration(),
              child: charts.PieChart(
                seriesList,
                animate: true,
                defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 40,
                  // arcRendererDecorators: [new charts.ArcLabelDecorator()]
                ),
                behaviors: [
                  new charts.DatumLegend(
                    position: charts.BehaviorPosition.end,
                    horizontalFirst: false,
                    cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                    showMeasures: true,
                    legendDefaultMeasure:
                        charts.LegendDefaultMeasure.firstValue,
                    measureFormatter: (num value) {
                      return value == null ? '-' : '${value}';
                    },
                  )
                ],
              ),
            ),
          ],
        ));
  }

  _buildFooter(BuildContext context, Casos casos){
    Dia last;
    
    casos.dias.forEach((s, day) {
      last = day;
    });

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text('Datos correspondientes a ${last.fecha}.'),
          SizedBox(height: 12,),
          Text('Estos se actualizan a partir de la información oficial del MINSAP.'),
          SizedBox(height: 12,),
          Text('Los datos se informan por las autoridades al día siguiente.'),
          SizedBox(height: 12,),
        ],
      ),
    );
  }
}

/// Sample linear data type.
class LinearSales {
  final String year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class Stat {
  final String name;
  final String value;

  Stat(this.name, this.value);
}

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 60.0);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ChartLinePoint {
  final DateTime timeStamp;
  final int cost;
  ChartLinePoint(this.timeStamp, this.cost);
}
