import 'package:provider/provider.dart';
import 'package:wlanpi_mobile/services/shared_methods.dart';
import 'package:wlanpi_mobile/widgets/not_connected_overlay.dart';

import '../../theme/theme.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> data;
  final String unit;
  final Color color;
  final String title;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.unit,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ${data.last.toStringAsFixed(2)}$unit",
          style: theme.bodyMedium,
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: double.infinity,
          height: 150.0,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              maxY: 100,
              minY: 0,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(),
                topTitles: AxisTitles(),
                bottomTitles: AxisTitles(),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CircularPercentWidget extends StatelessWidget {
  final double percentage;
  final String unit;
  final Color color;
  final String title;

  const CircularPercentWidget({
    super.key,
    required this.percentage,
    required this.unit,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CustomTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.bodyMedium,
        ),
        const SizedBox(height: 8.0),
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 10.0,
          percent: percentage / 100,
          circularStrokeCap: CircularStrokeCap.round,
          center: Text(
            "${percentage.toStringAsFixed(1)}$unit",
            style: theme.bodyMedium,
          ),
          progressColor: color,
          backgroundColor: theme.alternate,
        ),
      ],
    );
  }
}

class StatsPageWidget extends StatefulWidget {
  const StatsPageWidget({super.key});

  @override
  State<StatsPageWidget> createState() => _StatsPageWidgetState();
}

class _StatsPageWidgetState extends State<StatsPageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  SharedMethodsProvider? _sharedMethodsProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sharedMethodsProvider =
          Provider.of<SharedMethodsProvider>(context, listen: false);
      if (_sharedMethodsProvider!.connected) {
        _sharedMethodsProvider?.startStatsTimer();
      }
    });
  }

  @override
  void dispose() {
    Future.microtask(() {
      if (_sharedMethodsProvider!.connected) {
        _sharedMethodsProvider?.stopStatsTimer();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharedMethods = Provider.of<SharedMethodsProvider>(context);
    final theme = CustomTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: true,
        title: Text("Stats", style: theme.titleLarge),
        centerTitle: false,
        elevation: 2.0,
      ),
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: true,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Uptime and IP Address Container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: theme.alternate, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Uptime",
                                  style: theme.bodyMedium,
                                ),
                                const SizedBox(height: 10.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.alternate,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      sharedMethods.uptime,
                                      style: theme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "IP Address",
                                  style: theme.bodyMedium,
                                ),
                                const SizedBox(height: 10.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.alternate,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      sharedMethods.ip,
                                      style: theme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Stats Wheels Container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: theme.alternate, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: CircularPercentWidget(
                                    percentage: sharedMethods.cpuHistory.last,
                                    color: Colors.blue,
                                    unit: "%",
                                    title: 'CPU Usage',
                                  ),
                                ),
                                Flexible(
                                  child: CircularPercentWidget(
                                    percentage: sharedMethods.ramHistory.last,
                                    color: Colors.green,
                                    unit: "%",
                                    title: 'RAM Usage',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: CircularPercentWidget(
                                    percentage:
                                        sharedMethods.cpuTempHistory.last,
                                    color: Colors.orange,
                                    unit: "C",
                                    title: 'CPU Temp',
                                  ),
                                ),
                                Flexible(
                                  child: CircularPercentWidget(
                                    percentage: sharedMethods.diskHistory.last,
                                    color: Colors.red,
                                    unit: "%",
                                    title: 'Disk Usage',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Graphs Container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: theme.alternate, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            LineChartWidget(
                              data: sharedMethods.cpuHistory,
                              color: Colors.blue,
                              unit: "%",
                              title: 'CPU Usage History',
                            ),
                            const SizedBox(height: 20.0),
                            LineChartWidget(
                              data: sharedMethods.ramHistory,
                              color: Colors.green,
                              unit: "%",
                              title: 'RAM Usage History',
                            ),
                            const SizedBox(height: 20.0),
                            LineChartWidget(
                              data: sharedMethods.cpuTempHistory,
                              color: Colors.orange,
                              unit: "C",
                              title: 'CPU Temp History',
                            ),
                            const SizedBox(height: 20.0),
                            LineChartWidget(
                              data: sharedMethods.diskHistory,
                              color: Colors.red,
                              unit: "%",
                              title: 'Disk Usage History',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!sharedMethods.connected) NotConnectedOverlay()
        ]),
      ),
    );
  }
}
