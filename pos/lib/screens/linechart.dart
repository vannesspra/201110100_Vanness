import 'package:example/screens/pricePoints.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample1 extends StatefulWidget {
  const LineChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  late bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SizedBox(
              child: IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
            ),
            onPressed: () {
              setState(() {
                isShowingMainData = !isShowingMainData;
              });
            },
          )),
          SizedBox(
            child: AspectRatio(
              aspectRatio: 2,
              child: LineChartTest(isShowingMainData: isShowingMainData),
            ),
          )
        ],
      ),
      // aspectRatio: 1.23,
      // child: DecoratedBox(
      //   decoration: const BoxDecoration(
      //     borderRadius: BorderRadius.all(Radius.circular(18)),
      //     gradient: LinearGradient(
      //       colors: [
      //         Color(0xff2c274c),
      //         Color(0xff46426c),
      //       ],
      //       begin: Alignment.bottomCenter,
      //       end: Alignment.topCenter,
      //     ),
      //   ),
      //   child: Stack(
      //     children: <Widget>[
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.stretch,
      //         children: <Widget>[
      //           const SizedBox(
      //             height: 37,
      //           ),
      //           const Text(
      //             'Unfold Shop 2018',
      //             style: TextStyle(
      //               color: Color(0xff827daa),
      //               fontSize: 16,
      //             ),
      //             textAlign: TextAlign.center,
      //           ),
      //           const SizedBox(
      //             height: 4,
      //           ),
      //           const Text(
      //             'Monthly Sales',
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontSize: 32,
      //               fontWeight: FontWeight.bold,
      //               letterSpacing: 2,
      //             ),
      //             textAlign: TextAlign.center,
      //           ),
      //           const SizedBox(
      //             height: 37,
      //           ),
      //           Expanded(
      //             child: Padding(
      //               padding: const EdgeInsets.only(right: 16, left: 6),
      //               child: LineChartTest(isShowingMainData: isShowingMainData),
      //             ),
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //         ],
      //       ),
      //       IconButton(
      //         icon: Icon(
      //           Icons.refresh,
      //           color: Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
      //         ),
      //         onPressed: () {
      //           setState(() {
      //             isShowingMainData = !isShowingMainData;
      //           });
      //         },
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
