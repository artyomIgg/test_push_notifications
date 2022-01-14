import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_earth/flutter_earth.dart';
import 'package:model_viewer/model_viewer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Object _earth;
  late Scene _scene;
  late double _earthRotationY;
  late Vector2 startMove;
  late Vector2 updateMove;


  @override
  void initState() {
    super.initState();
    _earth = Object(
      fileName: 'res/3d_model/earth.obj',
      scale: Vector3(5.0, 5.0, 5.0),
      // rotation: Vector3(9999, 9999, 9999)
    );
    _controller = AnimationController(
        duration: Duration(milliseconds: 30000), vsync: this)
      ..addListener(() {
        if (_earth != null) {
          _earth.rotation.y = _earthRotationY;
          _earthRotationY = _controller.value * 360;
          _earth.updateTransform();
          _scene.update();
        }
      })
      ..repeat();
    _earthRotationY = _controller.value * 360;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;

    // scene.camera;
    scene.world.add(_earth);
    scene.camera;
    _earth.updateTransform();
    print(scene.world.children.first);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            onHorizontalDragStart: (_) {
              _controller.stop();
              startMove = Vector2(_.globalPosition.dx, _.globalPosition.dy);
            },
            onHorizontalDragUpdate: (_) {
              updateMove = Vector2(_.delta.dx, _.delta.dy);
              _earth.rotation.y = _earth.rotation.y + _.delta.dx / 3;
              _earth.updateTransform();
              // _scene.camera.position.setValues(_scene.camera.position.x + _.delta.dx, 0, 0);
              _scene.update();
              _controller.value = _earth.rotation.y / 360;
              _controller.stop();
            },

            onHorizontalDragEnd: (_) {
              Future.delayed(Duration(milliseconds: 1000)).then((value) {
                _controller..forward()..repeat();

              });
            },
            // onLongPress: () {
            //   _controller.stop();
            //
            //   // Future.delayed(Duration(milliseconds: 500)).then((value) {
            //   //   _controller.forward();
            //   // });
            // },
            // onTap: () {
            //   _controller.stop();
            // },
            // onTapCancel: () {
            //   _controller..forward()..repeat();
            // },

            // onScaleUpdate: (_) {
            //   print("qwe");
            //   // _scene.camera.trackBall(_.scale., to)
            // },
            //
            // onTapDown: (_) {
            //   _controller
            //     ..forward()
            //     ..repeat();
            // },
            // // onHorizontalDragStart: (_) {
            // //   _scene.camera.trackBall(
            // //     Vector2(_.),
            // //     Vector2(0, 0),
            // //   );
            // // },
            // onLongPressMoveUpdate: (_) {
            //   _controller.stop();
            // },
            // onLongPressUp: () {
            //   Future.delayed(Duration(milliseconds: 500)).then((value) {
            //     _controller.forward();
            //   });
            // },
            child: Cube(onSceneCreated: _onSceneCreated),
          ),
        ),
      ),
    );
    // return MaterialApp(
    //   home: Scaffold(
    //     appBar: AppBar(title: Text("Model Viewer")),
    //     body: ModelViewer(
    //       src: 'res/3d_model/earth.glb',
    //       alt: "A 3D model of an astronaut",
    //       // ar: true,
    //       autoRotate: true,
    //       cameraControls: true,
    //     ),
    //   ),
    // );
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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
  int _counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // PushNotificationService pushNotificationService = PushNotificationService();
    // pushNotificationService.initialise();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlutterEarth(
          url: 'http://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
          radius: 180,
        ),
      ),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("qwe"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
