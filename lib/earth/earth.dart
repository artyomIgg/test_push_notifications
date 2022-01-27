import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
// import 'package:flutter_earth/flutter_earth.dart';
import 'package:model_viewer/model_viewer.dart';
import 'package:photo_view/photo_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _earthSizeAnimationController;
  late Object _earth;
  late Scene _scene;
  late double _earthRotationY;
  late Vector2 startMove;
  late Vector2 updateMove;
  late bool isControllerStop = false;
  bool isTap = false;

  void generateSphereObject(Object parent, String name, double radius,
      bool backfaceCulling, String texturePath) async {
    final Mesh mesh =
        await generateSphereMesh(radius: radius, texturePath: texturePath);
    parent
        .add(Object(name: name, mesh: mesh, backfaceCulling: backfaceCulling));
    _scene.updateTexture();
  }

  @override
  void initState() {
    super.initState();
    _earth = Object(name: 'earth', scale: Vector3(5.0, 5.0, 5.0));
    generateSphereObject(
        _earth, 'surface', 0.485, true, 'res/3d_model/flutter8.png');
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

    _earthSizeAnimationController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    )..addListener(() {
        if (_earth != null) {
          _earth.scale.xyz = Vector3(
              _earthSizeAnimationController.value * 5,
              _earthSizeAnimationController.value * 5,
              _earthSizeAnimationController.value * 5);
          _earth.updateTransform();
          _scene.update();
        }
      });



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
    // scene.camera.;
    _earth.updateTransform();
    print(scene.world.children.first);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller.stop();
                if (!isTap) {
                  _earthSizeAnimationController.reverse();
                } else {
                  _earthSizeAnimationController.forward();
                }
                isTap = !isTap;
                // _scene.world.visiable = !_scene.world.visiable;
                // _earthSizeAnimationController.reverse();
              });
            },

            onPanCancel: () {},

            onPanDown: (_) {},

            onPanEnd: (_) {},

            onPanStart: (_) {},

            onPanUpdate: (_) {},

            onDoubleTap: () {
              _controller.stop();
            },

            // onScaleUpdate: (_) {
            //
            // },
            child: Listener(
                onPointerDown: (_) {
                  setState(() {
                    _controller.stop();
                  });
                },
                onPointerMove: (_) {
                  setState(() {
                    _controller.stop();
                  });
                },
                onPointerUp: (_) {
                  Future.delayed(Duration(milliseconds: 2000)).then((value) {
                    _controller
                      ..forward()
                      ..repeat();
                  });
                },
                child: Stack(
                  children: [
                    Cube(onSceneCreated: _onSceneCreated),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 600),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: isTap
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                            // clipper: CustomClipper,
                          // decoration:  BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     image: DecorationImage(
                          //         fit: BoxFit.fill,
                          //         image:  Image.asset("res/3d_model/flutter8.png")
                          //     )
                          // ),
                              child: PhotoView(
                                initialScale: 0.35,
                                backgroundDecoration:
                                    BoxDecoration(color: Colors.transparent),
                                imageProvider:
                                    AssetImage("res/3d_model/flutter8.png"),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}


Future<Mesh> generateSphereMesh(
    {num radius = 0.5,
    int latSegments = 32,
    int lonSegments = 64,
    required String texturePath}) async {
  int count = (latSegments + 1) * (lonSegments + 1);
  List<Vector3> vertices = List<Vector3>.filled(count, Vector3.zero());
  List<Offset> texcoords = List<Offset>.filled(count, Offset.zero);
  List<Polygon> indices =
      List<Polygon>.filled(latSegments * lonSegments * 2, Polygon(0, 0, 0));

  int i = 0;
  for (int y = 0; y <= latSegments; ++y) {
    final double v = y / latSegments;
    final double sv = math.sin(v * math.pi);
    final double cv = math.cos(v * math.pi);
    for (int x = 0; x <= lonSegments; ++x) {
      final double u = x / lonSegments;
      vertices[i] = Vector3(radius * math.cos(u * math.pi * 2.0) * sv,
          radius * cv, radius * math.sin(u * math.pi * 2.0) * sv);
      texcoords[i] = Offset(1.0 - u, 1.0 - v);
      i++;
    }
  }

  i = 0;
  for (int y = 0; y < latSegments; ++y) {
    final int base1 = (lonSegments + 1) * y;
    final int base2 = (lonSegments + 1) * (y + 1);
    for (int x = 0; x < lonSegments; ++x) {
      indices[i++] = Polygon(base1 + x, base1 + x + 1, base2 + x);
      indices[i++] = Polygon(base1 + x + 1, base2 + x + 1, base2 + x);
    }
  }

  ui.Image texture = await loadImageFromAsset(texturePath);
  final Mesh mesh = Mesh(
      vertices: vertices,
      texcoords: texcoords,
      indices: indices,
      texture: texture,
      texturePath: texturePath);
  return mesh;
}
