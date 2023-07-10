import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
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

  final Record _audioRecorder = Record();
  final _audioPlayer = ap.AudioPlayer();
  bool _recording = false;
  String? _file_path = null;
  String? _file_path_reverse = null;
  int _duration = 0;
  Timer? _timer;
  bool _playing = false;
  late final StreamSubscription _stream;

  @override
  void initState() {
    _recording = false;
    _file_path = null;
    _file_path_reverse = null;
    _playing = false;
    _stream = _audioPlayer.onPlayerStateChanged.listen((it) {
      switch (it) {
        case ap.PlayerState.completed:
        case ap.PlayerState.stopped:
          setState(() {
            _playing = false;
          });
          break;
        default:
          break;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _recording = false;
    _playing = false;
    _file_path = null;
    _file_path_reverse = null;
    _stream.cancel();
    super.dispose();
  }

  void _play({bool reversed = false}) {
    if (_file_path != null && !reversed) {
      setState(() => _playing = true);
      _audioPlayer.play(
        kIsWeb ? ap.UrlSource(_file_path!) : ap.DeviceFileSource(_file_path!)
      );
      _audioPlayer.setPlaybackRate(1.0);
    } else if (_file_path_reverse != null && reversed) {
      setState(() => _playing = true);
      _audioPlayer.play(
        kIsWeb ? ap.UrlSource(_file_path_reverse!) : ap.DeviceFileSource(_file_path_reverse!)
      );
      _audioPlayer.setPlaybackRate(1.0);
    } else {
      debugPrint('play attempted on null record');
    }
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
          _recording = true;
        });
        _startTimer();
      } else {
        setState(() {
          _recording = false;
          _file_path = null;
          _file_path_reverse = null;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
          _recording = false;
          _file_path = null;
          _file_path_reverse = null;
      });
    }
  }

  Future<void> _stop() async {
    if (_playing) {
      _audioPlayer.stop();
      setState(() {
        _playing = false;
      });
    } else {
      _timer?.cancel();
      final path = await _audioRecorder.stop();
      String? reverse_path = null;
      if (path == null) {
        debugPrint('path is null on stop');
      } else {
        debugPrint('recorded audio to: ' + path);
        reverse_path = path + '_reverse';
        FFmpegKit.execute('-i ' + path + ' -af areverse ' + reverse_path).then((session) async {
          final output = await session.getOutput();
          debugPrint(output);
          final failStackTrace = await session.getFailStackTrace();
          debugPrint(failStackTrace);
        });
      }
      setState(() {
        _recording = false;
        _file_path = path;
        _file_path_reverse = reverse_path;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _duration++);
    });
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
                  onPressed: _recording || _playing || (_file_path == null)
                    ? null 
                    : () => _play(reversed: true),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  iconSize: _icon_size,
                  tooltip: 'Play forward',
                  onPressed: _recording || _playing || (_file_path == null)
                    ? null
                    : _play,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recording || _playing ? _stop : _start,
        tooltip: _recording || _playing ? 'Stop' : 'Record',
        child: _recording || _playing
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
