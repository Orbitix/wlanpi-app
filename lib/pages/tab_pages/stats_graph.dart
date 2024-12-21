import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

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
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ${data.last.toStringAsFixed(2)}$unit",
          style: theme.headlineSmall,
        ),
        SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          height: 200.0,
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

class StatsGraph extends StatelessWidget {
  final List<double> cpuHistory;
  final List<double> cpuTempHistory;
  final List<double> ramHistory;
  final List<double> diskHistory;

  const StatsGraph({
    super.key,
    required this.cpuHistory,
    required this.cpuTempHistory,
    required this.ramHistory,
    required this.diskHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LineChartWidget(
              data: cpuHistory,
              color: Colors.blue,
              unit: "%",
              title: 'CPU Usage',
            ),
            SizedBox(height: 20.0),
            LineChartWidget(
              data: cpuTempHistory,
              color: Colors.orange,
              unit: "C",
              title: 'CPU Temp',
            ),
            SizedBox(height: 20.0),
            LineChartWidget(
              data: ramHistory,
              color: Colors.green,
              unit: "%",
              title: 'RAM Usage',
            ),
            SizedBox(height: 20.0),
            LineChartWidget(
              data: diskHistory,
              color: Colors.red,
              unit: "%",
              title: 'Disk Usage',
            ),
          ],
        ),
      ),
    );
  }
}
