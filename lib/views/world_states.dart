import 'dart:async';

import 'package:covid_tracker_app/model/world_stats_model.dart';
import 'package:covid_tracker_app/services/stats_services.dart';
import 'package:covid_tracker_app/views/countries_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie_chart/pie_chart.dart';

import '../widget/resuable_row.dart';

class WorldStatesScreen extends StatefulWidget {
  const WorldStatesScreen({super.key});

  @override
  State<WorldStatesScreen> createState() => _WorldStatesScreenState();
}

class _WorldStatesScreenState extends State<WorldStatesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 3), vsync: this)
        ..repeat();
  @override
  void initState() {
    super.initState();

    Timer(
        const Duration(seconds: 5),
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WorldStatesScreen())));
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  final colorList = <Color>[
    const Color(0xff4285F4),
    const Color(0xff1aa260),
    const Color(0xffde5246),
  ];
  @override
  Widget build(BuildContext context) {
    StatsServices statsServices = StatsServices();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            FutureBuilder(
                future: statsServices.fetchWorldStatsRecords(),
                builder: (context, AsyncSnapshot<WorldStatsModel> snapshot) {
                  if (!snapshot.hasData) {
                    return Expanded(
                        flex: 1,
                        child: SpinKitFadingCircle(
                          color: Colors.white,
                          size: 50,
                          controller: _controller,
                        ));
                  }
                  if (snapshot.hasError) {
                    return Text('Error fetching data: ${snapshot.error}');
                  } else {
                    return Column(
                      children: [
                        PieChart(
                          dataMap: {
                            'Total':
                                double.parse(snapshot.data!.cases!.toString()),
                            'Recovered': double.parse(
                                snapshot.data!.recovered!.toString()),
                            'Deaths':
                                double.parse(snapshot.data!.deaths!.toString()),
                          },
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValuesInPercentage: true,
                          ),
                          animationDuration: const Duration(microseconds: 1200),
                          chartType: ChartType.ring,
                          colorList: colorList,
                          chartRadius: MediaQuery.of(context).size.width / 3.2,
                          legendOptions: const LegendOptions(
                              legendPosition: LegendPosition.left),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.06),
                          child: Card(
                            child: Column(children: [
                              ReusableRow(
                                title: 'Total',
                                value: snapshot.data!.cases.toString(),
                              ),
                              ReusableRow(
                                title: 'Deaths',
                                value: snapshot.data!.deaths.toString(),
                              ),
                              ReusableRow(
                                title: 'Recovered',
                                value: snapshot.data!.recovered.toString(),
                              ),
                              ReusableRow(
                                title: 'Active',
                                value: snapshot.data!.active.toString(),
                              ),
                              ReusableRow(
                                title: 'Critical',
                                value: snapshot.data!.critical.toString(),
                              ),
                              ReusableRow(
                                title: 'Today Deaths',
                                value: snapshot.data!.todayDeaths.toString(),
                              ),
                              ReusableRow(
                                title: 'Today Recovered',
                                value: snapshot.data!.todayRecovered.toString(),
                              ),
                            ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CountriesList()));
                          },
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                                color: const Color(0xff1aa260),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                                child: Text(
                              'Track Countries',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400),
                            )),
                          ),
                        )
                      ],
                    );
                  }
                }),
          ]),
        ),
      ),
    );
  }
}
