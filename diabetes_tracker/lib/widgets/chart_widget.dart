import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/blood_sugar_entry.dart';

class ChartWidget extends StatelessWidget {
  final List<BloodSugarEntry> entries;
  final String unit;
  final int daysToShow;

  const ChartWidget({
    Key? key,
    required this.entries,
    required this.unit,
    this.daysToShow = 7,
  }) : super(key: key);

  List<Color> get gradientColors => [
        Colors.blue[400]!,
        Colors.blue[200]!,
      ];

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No data available for chart'),
      );
    }

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - daysToShow + 1);
    
    // Filter and sort entries
    final filteredEntries = entries
        .where((entry) => entry.dateTime.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(
          mainData(filteredEntries),
        ),
      ),
    );
  }

  LineChartData mainData(List<BloodSugarEntry> filteredEntries) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 50,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= filteredEntries.length) {
                return const Text('');
              }
              final date = filteredEntries[value.toInt()].dateTime;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('MM/dd').format(date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!),
      ),
      minX: 0,
      maxX: (filteredEntries.length - 1).toDouble(),
      minY: 0,
      maxY: _getMaxY(filteredEntries),
      lineBarsData: [
        LineChartBarData(
          spots: _createSpots(filteredEntries),
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: gradientColors[0],
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final entry = filteredEntries[barSpot.x.toInt()];
              return LineTooltipItem(
                '${entry.bloodSugarValue} $unit\n${DateFormat('MM/dd HH:mm').format(entry.dateTime)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  List<FlSpot> _createSpots(List<BloodSugarEntry> filteredEntries) {
    return List.generate(
      filteredEntries.length,
      (index) => FlSpot(
        index.toDouble(),
        filteredEntries[index].bloodSugarValue,
      ),
    );
  }

  double _getMaxY(List<BloodSugarEntry> filteredEntries) {
    if (filteredEntries.isEmpty) return 200;
    final maxValue = filteredEntries
        .map((e) => e.bloodSugarValue)
        .reduce((max, value) => value > max ? value : max);
    return (maxValue * 1.2).roundToDouble(); // Add 20% padding
  }
}