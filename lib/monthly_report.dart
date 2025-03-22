import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  _MonthlyReportScreenState createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  Map<String, double> reportData = {};
  bool isLoading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchReport();
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      fetchReport();
    });
  }

  Future<void> fetchReport() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/reports/latest"),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> rawData = json.decode(response.body);
        if (rawData.containsKey("month") &&
            rawData.containsKey("latestPercentage")) {
          String month = rawData["month"];
          double percentage = (rawData["latestPercentage"] as num).toDouble();
          setState(() {
            reportData[month] = percentage;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load report: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  // Function to generate and save PDF
  Future<void> generatePDF() async {
    final pdf = pw.Document();

    // ✅ Load Images from Assets
    final ByteData logoBytes = await rootBundle.load('assets/logo1.png');
    final Uint8List logoImage = logoBytes.buffer.asUint8List();

    final ByteData sealBytes = await rootBundle.load('assets/seal.png');
    final Uint8List sealImage = sealBytes.buffer.asUint8List();

    pdf.addPage(
      pw.MultiPage(
        // ✅ MultiPage ensures content doesn't get cut off
        build:
            (pw.Context context) => [
              // ✅ Add Logo at the Top
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(logoImage),
                  width: 80,
                  height: 80,
                ),
              ),
              pw.SizedBox(height: 10),

              // ✅ Title
              pw.Center(
                child: pw.Text(
                  "TANK TRACK",
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "Monthly Report",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              // ✅ Styled Table for Tank Data
              pw.Table.fromTextArray(
                headers: ["Month", "Percentage"],
                data:
                    reportData.entries
                        .map(
                          (entry) => [
                            entry.key,
                            "${entry.value.toStringAsFixed(1)}%",
                          ],
                        )
                        .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.center,
                cellStyle: pw.TextStyle(fontSize: 12),
              ),

              pw.SizedBox(height: 20),

              // ✅ Mini Bar Graph inside PDF with Labels
              pw.Container(
                height: 350, // ✅ Increased height for better spacing
                width: 400,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children:
                      reportData.entries.map((entry) {
                        double barHeight =
                            entry.value * 3; // ✅ Scale bars correctly
                        return pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            // ✅ Add Percentage Labels Above Bars
                            pw.Text(
                              "${entry.value.toStringAsFixed(1)}%",
                              style: pw.TextStyle(fontSize: 10),
                            ),

                            // ✅ Bar Graph (Ensures visibility)
                            pw.Container(
                              width: 30, // ✅ Increased width of bars
                              height:
                                  barHeight < 15
                                      ? 15
                                      : barHeight, // ✅ Ensure minimum height
                              color: PdfColors.blue,
                              margin: pw.EdgeInsets.symmetric(horizontal: 4),
                            ),

                            // ✅ Add Month Labels Below Bars
                            pw.SizedBox(height: 5),
                            pw.Text(
                              entry.key.substring(
                                0,
                                3,
                              ), // Show first 3 letters of the month
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),

              pw.SizedBox(height: 20),

              // ✅ Footer: Generated Date
              pw.Text(
                "Generated on: ${DateTime.now()}",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 30),

              // ✅ Verified by Section with Seal Image (Always on the same page)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Verified by:", style: pw.TextStyle(fontSize: 16)),
                  pw.Image(
                    pw.MemoryImage(sealImage),
                    width: 80,
                    height: 80,
                  ), // ✅ Add Seal Image
                ],
              ),
            ],
      ),
    );

    // Save PDF file
    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/Monthly_Report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    OpenFile.open(file.path);
  }

  Widget buildTankIndicator(double percentage) {
    Color tankColor = Colors.orangeAccent;
    if (percentage > 80) {
      tankColor = Colors.redAccent;
    } else if (percentage < 20) {
      tankColor = const Color(0xFF66FF66);
    }

    double waterHeight = 200 * (percentage / 100);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Tank Container
        Container(
          width: 100,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade800,
          ),
        ),

        // Water Fill with Smooth Animation
        Positioned(
          bottom: 0,
          child: ClipPath(
            clipper: WaveClipper(),
            child: AnimatedContainer(
              duration: Duration(
                seconds: 2,
              ), // ✅ Smooth transition in 2 seconds
              curve: Curves.easeInOut, // ✅ Smooth easing effect
              width: 100,
              height: waterHeight.clamp(
                0,
                200,
              ), // ✅ Ensures water stays inside the tank
              decoration: BoxDecoration(
                color: tankColor.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
        ),

        // Percentage Label
        Positioned(
          top: 10,
          child: Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Report"),
        backgroundColor: const Color.fromARGB(255, 72, 66, 109),
        actions: [
          IconButton(icon: Icon(Icons.picture_as_pdf), onPressed: generatePDF),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 72, 66, 109),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Tank Level",
                      style: TextStyle(
                        fontSize: 22,
                        color: const Color.fromARGB(247, 240, 194, 142),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    if (reportData.isNotEmpty)
                      Column(
                        children: [
                          buildTankIndicator(reportData.values.last),
                          SizedBox(height: 10),
                          Text(
                            "Estimated days to full: ${_calculateDaysToFull(reportData.values.last)}",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            "Current daily usage: ${_calculateDailyUsage()}%",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),

                    SizedBox(height: 20),
                    Text(
                      "Monthly Charts",
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(247, 240, 194, 142),
                      ),
                    ),
                    SizedBox(height: 10),

                    Expanded(
                      child: BarChart(
                        BarChartData(
                          maxY: 100,
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(12, (index) {
                            List<String> months = [
                              "January",
                              "February",
                              "March",
                              "April",
                              "May",
                              "June",
                              "July",
                              "August",
                              "September",
                              "October",
                              "November",
                              "December",
                            ];
                            double percentage =
                                reportData.containsKey(months[index])
                                    ? reportData[months[index]]!
                                    : 0.0;

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: percentage,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors:
                                        percentage > 80
                                            ? [Colors.redAccent, Colors.red]
                                            : percentage > 50
                                            ? [
                                              Colors.orangeAccent,
                                              Colors.deepOrange,
                                            ]
                                            : [
                                              Colors.greenAccent,
                                              Colors.blueAccent,
                                            ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY:
                                        100, // ✅ This ensures empty bars show full height
                                    color: const Color.fromARGB(
                                      60,
                                      240,
                                      194,
                                      142,
                                    ), // ✅ Empty bar color before filling
                                  ),
                                ),
                              ],
                            );
                          }),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  List<String> months = [
                                    "JAN",
                                    "FEB",
                                    "MAR",
                                    "APR",
                                    "MAY",
                                    "JUN",
                                    "JUL",
                                    "AUG",
                                    "SEP",
                                    "OCT",
                                    "NOV",
                                    "DEC",
                                  ];
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      months[value.toInt() % 12],
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          240,
                                          194,
                                          142,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 22,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ), // ❌ Remove Left Labels
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ), // ❌ Remove Top Labels
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  if (value % 10 == 0) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        "${value.toInt()}",
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            240,
                                            194,
                                            142,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                          ),
                          barTouchData: BarTouchData(enabled: true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  int _calculateDaysToFull(double currentLevel) {
    double dailyIncrease = 5;
    if (currentLevel >= 100) return 0;
    return ((100 - currentLevel) / dailyIncrease).ceil();
  }

  double _calculateDailyUsage() {
    return 5.0;
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double waveHeight = 8;
    double waveLength = size.width / 4;

    path.moveTo(0, waveHeight);
    for (double i = 0; i < size.width; i += waveLength) {
      path.quadraticBezierTo(
        i + (waveLength / 2),
        0,
        i + waveLength,
        waveHeight,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
