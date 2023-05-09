import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:performance/performance.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool si = true;
  bool minimized = true;
  bool cacheOnComplex = true;

  void _switchSi() => setState(() => si = !si);

  void _switchMinimized() => setState(() => minimized = !minimized);

  void _switchCacheOnComplex() =>
      setState(() => cacheOnComplex = !cacheOnComplex);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return CustomPerformanceOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SVG Smoothness (no svg cache)'),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: FutureBuilder<ScalableImage>(
                    key: ValueKey('mama $index'),
                    future: si
                        ? ScalableImage.fromSIAsset(
                            rootBundle,
                            minimized
                                ? 'assets/mikroskop_min.si'
                                : 'assets/mikroskop.si',
                          )
                        : ScalableImage.fromSvgAsset(
                            rootBundle,
                            minimized
                                ? 'assets/mikroskop_min.svg'
                                : 'assets/mikroskop.svg',
                          ),
                    builder: (context, snap) {
                      return SizedBox(
                        height: 224,
                        child: Card(
                          child: Column(
                            children: [
                              Text('Item $index'),
                              if (snap.hasData)
                                SizedBox(
                                  height: 200,
                                  child: ScalableImageWidget(
                                    si: snap.requireData,
                                    isComplex: cacheOnComplex,
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 40,
                      )
                    ]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoSwitch(
                            value: si, onChanged: (_) => _switchSi()),
                        const SizedBox(width: 8),
                        const Text('Jovial Binary'),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoSwitch(
                            value: minimized,
                            onChanged: (_) => _switchMinimized()),
                        const SizedBox(width: 8),
                        const Text('SVGO minimized'),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoSwitch(
                            value: cacheOnComplex,
                            onChanged: (_) => _switchCacheOnComplex()),
                        const SizedBox(width: 8),
                        const Text('Paint Cache'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cache for caching SVGs throughout the application that is using it.
///
/// This cache is intended to be used with jovial svg (https://pub.dev/packages/jovial_svg).
/// This will cache svgs in the efficient binary storage format, resulting in
/// shorter loading times of svgs that a user has already seen.
class SvgCache extends ScalableImageCache {
  static final SvgCache _instance = SvgCache._();

  /// Returns an application wide cache for caching scalable images.
  factory SvgCache() {
    return _instance;
  }

  SvgCache._() : super(size: 50);
}
