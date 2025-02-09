import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_creator/domain/modules/generate_code.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:target/main.dart' as target;
import 'package:path/path.dart' as path;

import 'secret.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final _generativeModel = GenerativeModel(
    model: Secret.llmModelName,
    apiKey: Secret.keyGeminiApiKey,
  );

  final _textController = TextEditingController();
  late final generateCode = GenerateCode(
    _generativeModel,
    Directory(path.join('..', 'target')),
  );

  bool _isProgressing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '修正点を入力 \n  例)テーマカラーを青にして',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      minLines: 10,
                      maxLines: 20,
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      setState(() {
                        _isProgressing = true;
                      });
                      generateCode.generate(_textController.text).then((_) {
                        setState(() {
                          _isProgressing = false;
                        });
                      });
                    },
                    child: Text('送信'),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: DevicePreview(
                  builder: (context) => _isProgressing
                      ? CircularProgressIndicator()
                      : target.MyApp()),
            ),
          ],
        ),
      ),
    );
  }
}
