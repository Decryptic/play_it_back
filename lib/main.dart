import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  late final Record _audioRecorder;
  bool _recording = false;
  bool _null_record = true; // whether or not a sample exists
  int _duration = 0;
  Timer? _timer;

  @override
  void initState() {
    _audioRecorder = Record();

    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.aacLc;
        final isSupported = await _audioRecorder.isEncoderSupported(encoder);
        debugPrint('${encoder.name} supported: $isSupported');

        await _audioRecorder.start();
        setState(() {
          _duration = 0;
        });
        _startTimer();
      } else {
        setState(() {
          _recording = false;
          _null_record = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
          _recording = false;
          _null_record = true;
        });
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();
    if (path == null) {
      debugPrint('path is null on stop');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _duration++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _recording = false;
    _null_record = true;
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
            _buildTimer(),
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
                  onPressed: _recording || _null_record ? null : () {

                  },
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  iconSize: _icon_size,
                  tooltip: 'Play forward',
                  onPressed: _recording  || _null_record ? null : () {

                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_recording) {
            _start();
            setState(() {
              _recording = true;
            });
          } else {
            _stop();
            setState(() {
              _null_record = false;
              _recording = false;
            });
          }
        },
        tooltip: _recording ? 'Stop' : 'Record',
        child: _recording 
          ? const Icon(Icons.stop) 
          : const Icon(Icons.fiber_manual_record, color: Colors.red),
      ),
    );
  }

  Widget _buildTimer() {
    final String Function(int) _formatNumber = (sec) {
      String numberStr = sec.toString();
      if (sec < 10) {
        numberStr = '0$numberStr';
      }
      return numberStr;
    };

    final String minutes = _formatNumber(_duration ~/ 60);
    final String seconds = _formatNumber(_duration % 60);
    return Text(
      '$minutes : $seconds',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
      ),
    );
  }
}
