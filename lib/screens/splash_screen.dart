import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();

    _initializeVideoPlayback();
  }

  @override
  void dispose() {
    _playerController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_playerController != null) {
      return AspectRatio(
        aspectRatio: _playerController!.value.aspectRatio,
        child: VideoPlayer(_playerController!),
      );
    } else {
      return Container();
    }
  }

  // Private instance
  Future<void> _initializeVideoPlayback() async {
    _playerController = VideoPlayerController.asset('assets/video/maze_tales_launch_video.mp4');
    // _playerController?.addListener(() {
    //
    //
    // });
    await _playerController?.initialize();
    await _playerController?.setLooping(false);
    setState(() {
      _playerController?.play();
    });
    // setState(() {});
  }
}

//
// class SplashPage extends StatefulWidget {
//   SplashPage({Key key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   VideoPlayerController _controller;
//   bool _visible = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//
//     _controller = VideoPlayerController.asset("assets/video/splash_video.mp4");
//     _controller.initialize().then((_) {
//       _controller.setLooping(true);
//       Timer(Duration(milliseconds: 100), () {
//         setState(() {
//           _controller.play();
//           _visible = true;
//         });
//       });
//     });
//
//     Future.delayed(Duration(seconds: 4), () {
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//               builder: (context) => HomePage(param_homepage: 'Welcome Home')),
//               (e) => false);
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     if (_controller != null) {
//       _controller.dispose();
//       _controller = null;
//     }
//   }
//
//   _getVideoBackground() {
//     return AnimatedOpacity(
//       opacity: _visible ? 1.0 : 0.0,
//       duration: Duration(milliseconds: 1000),
//       child: VideoPlayer(_controller),
//     );
//   }
//
//   _getBackgroundColor() {
//     return Container(color: Colors.transparent //.withAlpha(120),
//     );
//   }
//
//   _getContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.start,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Stack(
//           children: <Widget>[
//             _getVideoBackground(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
