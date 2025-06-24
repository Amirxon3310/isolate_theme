import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_expressions/math_expressions.dart';

Future<void> runTask(void Function(List) task, dynamic param) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(task, [receivePort.sendPort, param]);
  final result = await receivePort.first;
  print('Natija: $result');
}

void base64EncodeTask(List args) async {
  SendPort sendPort = args[0];
  String filePath = args[1];
  final bytes = await File(filePath).readAsBytes();
  final base64 = base64Encode(bytes);
  sendPort.send(base64);
}

void sumListTask(List args) {
  SendPort sendPort = args[0];
  List<int> numbers = args[1];
  final sum = numbers.reduce((a, b) => a + b);
  sendPort.send(sum);
}

void bigSumTask(List args) {
  SendPort sendPort = args[0];
  int total = 0;
  for (int i = 1; i <= 100000000; i++) {
    total += i;
  }
  sendPort.send(total);
}

void reverseStringTask(List args) {
  SendPort sendPort = args[0];
  String input = args[1];
  sendPort.send(input.split('').reversed.join());
}

void fibonacciTask(List args) {
  SendPort sendPort = args[0];
  int n = args[1];
  int a = 0, b = 1;
  for (int i = 2; i <= n; i++) {
    int temp = a + b;
    a = b;
    b = temp;
  }
  sendPort.send(n == 0 ? 0 : b);
}

void squareListTask(List args) {
  SendPort sendPort = args[0];
  List<int> numbers = args[1];
  sendPort.send(numbers.map((e) => e * e).toList());
}

void uniqueListTask(List args) {
  SendPort sendPort = args[0];
  List<int> numbers = args[1];
  sendPort.send(numbers.toSet().toList());
}

void wordCountTask(List args) {
  SendPort sendPort = args[0];
  String input = args[1];
  final words = input.toLowerCase().split(' ');
  final countMap = <String, int>{};
  for (var word in words) {
    countMap[word] = (countMap[word] ?? 0) + 1;
  }
  sendPort.send(countMap);
}

void extractNumbersTask(List args) {
  SendPort sendPort = args[0];
  String input = args[1];
  final matches = RegExp(r'\d+').allMatches(input);
  final numbers = matches.map((m) => int.parse(m.group(0)!)).toList();
  sendPort.send(numbers);
}

void evaluateExpressionTask(List args) {
  SendPort sendPort = args[0];
  String expression = args[1];
  final parser = Parser();
  final exp = parser.parse(expression);
  final result = exp.evaluate(EvaluationType.REAL, ContextModel());
  sendPort.send(result);
}

void main() async {
  await runTask(sumListTask, [1, 2, 3, 4, 5]);
  await runTask(fibonacciTask, 40);
  await runTask(reverseStringTask, "Flutter");
  await runTask(evaluateExpressionTask, "10 + 5 * 2");

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? base64Result;
  final picker = ImagePicker();

  Future<void> pickImageAndConvert() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await runTask(base64EncodeTask, picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImageAndConvert,
              child: Text("Rasm tanlash va base64ga o‘tkazish"),
            ),
            SizedBox(height: 20),
            base64Result != null
                ? Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(base64Result ?? ""),
                    ),
                  )
                : Text("Hech qanday rasm tanlanmadi."),
          ],
        ),
      )),
    );
  }
}
