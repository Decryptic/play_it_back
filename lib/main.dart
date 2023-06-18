import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

// Gage Swenson @Decryptic
// credit to: https://github.com/llfbandit/record/tree/master/record/example

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _title = 'Play it Back';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        //scaffoldBackgroundColor: Colors.grey,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: _title),
      debugShowCheckedModeBanner: false,
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

  final _icon_size = 42.0;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '00:00',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const Image(
              image: const AssetImage(
                'assets/images/tape.png',
              ),
              width: 200, //todo: scaled size
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: const Icon(Icons.play_circle_outline),
                  ),
                  iconSize: _icon_size,
                  tooltip: 'Play reverse',
                  onPressed: null, //todo: implement
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  iconSize: _icon_size,
                  tooltip: 'Play forward',
                  onPressed: null, //todo: implement
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_recording) {
            setState(() {
              _recording = true;
            });
          } else {
            setState(() {
              _recording = false;
            });
          }
        },
        tooltip: _recording ? 'Stop' : 'Record',
        child: _recording ? const Icon(Icons.stop) : const Icon(Icons.fiber_manual_record),
      ),
    );
  }
}
