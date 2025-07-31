import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:pie_chart/pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final double totalPayment;

  const PieChartWidget({
    Key? key,
    required this.dataMap,
    required this.colorList,
    required this.totalPayment,
  }) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   final isIncome = totalPayment >= 0;
  //   final formattedAmount = NumberFormat("#,##0.00", "en_US")
  //       .format(totalPayment.abs());

  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       PieChart(
  //         dataMap: dataMap,
  //         colorList: colorList,
  //         chartType: ChartType.ring,
  //         chartRadius: MediaQuery.of(context).size.width / 2,
  //         ringStrokeWidth: 60,
  //         chartLegendSpacing: 60,
  //         degreeOptions: const DegreeOptions(initialAngle: -90),
  //         animationDuration: const Duration(seconds: 3),
  //         chartValuesOptions: const ChartValuesOptions(
  //           chartValueStyle: TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //           ),
  //           showChartValues: true,
  //           showChartValuesOutside: true,
  //           showChartValuesInPercentage: true,
  //           showChartValueBackground: false,
  //           decimalPlaces: 1,
  //         ),
  //         legendOptions: const LegendOptions(
  //           showLegends: false,
  //           legendShape: BoxShape.circle,
  //           legendTextStyle: TextStyle(fontSize: 12),
  //           legendPosition: LegendPosition.bottom,
  //           showLegendsInRow: true,
  //         ),
  //       ),
  //       Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'Total',
  //             style: TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.white,
  //             ),
  //           ),
  //           SizedBox(height: 2),
  //           Text(
  //             isIncome ? formattedAmount: '-$formattedAmount',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: isIncome ? Colors.teal[600] : Colors.red[600],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final total = dataMap.values.fold(0.0, (a, b) => a + b);
    final isIncome = totalPayment >= 0;
    final formattedAmount = NumberFormat(
      "#,##0.00",
      "en_US",
    ).format(totalPayment.abs());
    final List<PieChartSectionData> sections = [];

    int index = 0;
    dataMap.forEach((label, value) {
      final percent = (value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colorList[index % colorList.length],
          value: value,
          title: '${percent.toStringAsFixed(1)}%',
          radius: MediaQuery.of(context).size.width / 7,
          titlePositionPercentageOffset: 1.4,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sections: sections,
              sectionsSpace: 0,
              centerSpaceRadius: 70,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Net',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                isIncome ? formattedAmount : '-$formattedAmount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isIncome ? Colors.teal[600] : Colors.red[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
