import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:photo_view/photo_view.dart';

Color bottomNavBarColor = Color(0xFF25372D);
Color bottomNavBarSelectTextColor = Color(0xFF88F9BA);
Color bottomNavBarTextColor = Color(0xffB4CCBA);
Color bottomNavBarButtonColor = Color(0xffBFE9F8);
Color textColorLightGreen = Color(0xff88F9BA);
Color bottomNavBarMapColor = Color(0xff033541);
Color backImageGradientFirst = Color(0xff0F2027);
Color backImageGradientSecond = Color(0xff2C5364);

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
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "SFProDisplay"),
      home: SafeArea(child: Home()),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _earthSizeAnimationController;
  late AnimationController _earthSizeUpAnimationController;
  late AnimationController _earthDoubleTapSizeController;
  late AnimationController _earthOpacityController;
  late Object _earth;
  late Scene _scene;
  late double _earthRotationY;
  late Vector2 startMove;
  late Vector2 updateMove;
  late bool isControllerStop = false;
  Vector3 defaultEarthSize = Vector3(8, 8, 8);
  Vector3 scaleMinEarthSize = Vector3(5, 5, 5);
  Vector3 scaleMaxEarthSize = Vector3(10, 10, 10);
  Color backgroundColor = Color(0xff191C1A);
  Color cardGradientFirstGreen = Color(0xff134E5E);
  Color cardGradientSecondGreen = Color(0xff71B280);
  Color cardGradientFirstBlue = Color(0xff4B6CB7);
  Color cardGradientSecondBlue = Color(0xff182848);
  Color textCountColorBlue = Color(0xffBFE9F8);
  bool isTap = false;
  bool isTapZoom = true;
  bool isLongPress = false;
  bool isReverseZoom = false;

  late Timer _earthRotationTimer;
  late Timer _earthZoomTimer;
  // bool isDoubleTap = false;

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
    _earth = Object(name: 'earth', scale: defaultEarthSize);
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
      lowerBound: 0.7,
      duration: Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        // if (_earth != null) {
        _earthDoubleTapSizeController.stop();
        _earth.scale.setFrom(
            scaleMaxEarthSize.xyz * _earthSizeAnimationController.value);
        _earth.updateTransform();
        _scene.update();
        // }
      });

    _earthSizeUpAnimationController = AnimationController(
      // lowerBound: 0.7,
      duration: Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        // if (_earth != null) {
        _earthDoubleTapSizeController.stop();
        _earth.scale.setFrom(
            defaultEarthSize.xyz * _earthSizeUpAnimationController.value);
        _earth.updateTransform();
        _scene.update();
        // }
      });

    _earthDoubleTapSizeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        if (_earth != null &&
            ((_earthDoubleTapSizeController.value * scaleMaxEarthSize.x >=
                    defaultEarthSize.x) &&
                ((!isReverseZoom || _earth.scale.x != scaleMaxEarthSize.x)))) {
          _earth.scale.setFrom(
              scaleMaxEarthSize.xyz * _earthDoubleTapSizeController.value);
          _earth.updateTransform();
          _scene.update();
        }
      });
    // ..addStatusListener((status) {
    //   if (status == AnimationStatus.completed && isDoubleTap) {
    //     Future.delayed(Duration(milliseconds: 3000)).then((value) {
    //       _earthDoubleTapSizeController.reverse();
    //     });
    //   }
    // });

    _earthOpacityController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this)
          ..addListener(() {})
          ..forward();

    _earthRotationY = _controller.value * 360;

    _earthRotationTimer = Timer(Duration(seconds: 3), () {
      _controller
        ..forward()
        ..repeat();
    });
    _earthZoomTimer = Timer(Duration(seconds: 5), () {
      _earthDoubleTapSizeController.reverse();
    });
  }

  @override
  trackBall() {}

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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: backgroundColor,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Current Situation",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700),
                          ),
                          Icon(
                            Icons.wb_sunny,
                            color: Colors.orange,
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 327,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          // _earthOpacityController.forward();
                          isTapZoom = false;

                          _controller.stop();
                          if (isTap) {
                            _earthSizeUpAnimationController.forward(from: 0);
                            _earthOpacityController.forward();
                            setState(() {
                              isTap = !isTap;
                            });
                            // });
                          } else {
                            _earthSizeAnimationController.forward(from: 0);
                            _earthOpacityController.reverse().whenComplete(() {
                              setState(() {
                                isTap = !isTap;
                              });
                            });
                          }
                        },

                        onPanCancel: () {},

                        onPanDown: (_) {},

                        onPanEnd: (_) {},

                        onPanStart: (_) {},

                        onPanUpdate: (_) {},

                        onLongPressStart: (_) {
                          // _controller.stop();
                          // _earthDoubleTapSizeController.forward();
                        },

                        onLongPress: () {
                          // _earthZoomTimer.cancel();
                          // _earthRotationTimer.cancel();
                          // isLongPress = true;
                        },

                        // onHorizontalDragUpdate: (_) {
                        //   // _controller.stop();
                        //   // _earthZoomTimer.cancel();
                        //   // _earthRotationTimer.cancel();
                        //   // updateMove = Vector2(_.delta.dx, _.delta.dy);
                        //   // _earth.rotation.y =
                        //   //     _earth.rotation.y + _.delta.dx / 2;
                        //   // _earth.updateTransform();
                        //   // // _scene.camera.position.setValues(_scene.camera.position.x + _.delta.dx, 0, 0);
                        //   // _scene.update();
                        //   // if (_earth.rotation.y < 0) {
                        //   //   _controller.value =
                        //   //       (_earth.rotation.y + 360) / 360;
                        //   // } else if (_earth.rotation.y > 360) {
                        //   //   _controller.value =
                        //   //       (_earth.rotation.y - 360) / 360;
                        //   // } else {
                        //   //   _controller.value = _earth.rotation.y / 360;
                        //   // }
                        // },

                        // onLongPress: () {
                        //   _controller.stop();
                        //   _earthDoubleTapSizeController.forward();
                        // },

                        onLongPressUp: () async {
                          // _controller.forward();
                          // _startEarthZoomTimer();
                          // _startEarthRotationTimer();
                          // await Future.delayed(Duration(milliseconds: 5000)).then((value) {
                          //   _earthDoubleTapSizeController.reverse();
                          // });
                        },

                        // onLong

                        // onDoubleTap: () {
                        //   !isDoubleTap
                        //       ? ({
                        //           _controller.stop(),
                        //           _earthDoubleTapSizeController.reverse(),
                        //           isDoubleTap = !isDoubleTap,
                        //         })
                        //       : ({
                        //       _earthDoubleTapSizeController.forward(), isDoubleTap = !isDoubleTap
                        //   });
                        //   // _earthDoubleTapSizeController.forward();
                        //   // _earthSizeAnimationController.forward();
                        // },

                        // onScaleUpdate: (_) {
                        //
                        // },
                        child: Listener(
                            onPointerHover: (_) {
                              print("onPointerHover");
                            },
                            onPointerDown: (_) {
                              // if(isTapZoom) {
                              _earthDoubleTapSizeController.forward(from: 0.5);
                              // }
                              _earthZoomTimer.cancel();
                              _earthRotationTimer.cancel();
                            },
                            onPointerMove: (_) {
                              // _earthDoubleTapSizeController.forward();
                              // setState(() {
                              _controller.stop();
                              // });
                              _earthZoomTimer.cancel();
                              _earthRotationTimer.cancel();
                              updateMove = Vector2(_.delta.dx, _.delta.dy);
                              _earth.rotation.y =
                                  _earth.rotation.y + _.delta.dx / 2;
                              _earth.updateTransform();
                              // _scene.camera.position.setValues(_scene.camera.position.x + _.delta.dx, 0, 0);
                              _scene.update();
                              // if (_earth.rotation.y <= 0) {
                              //   _controller.value =
                              //       (_earth.rotation.y + 360) / 360;
                              // } else if (_earth.rotation.y >= 360) {
                              //   _controller.value =
                              //       (_earth.rotation.y - 360) / 360;
                              // } else
                              //   _controller.value = _earth.rotation.y / 360;
                            },
                            onPointerUp: (_) {
                              _startEarthRotationTimer();
                              _startEarthZoomTimer();
                              _earthZoomTimer;
                              // Future.delayed(Duration(milliseconds: 2000))
                              //     .then((value) {
                              //   _controller
                              //     ..forward()
                              //     ..repeat();
                              // });
                            },
                            child: Stack(
                              children: [
                                AnimatedBuilder(
                                  animation: _earthOpacityController,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Opacity(
                                      opacity: _earthOpacityController.value,
                                      child: child,
                                    );
                                  },
                                  child: ClipRRect(
                                      child: Cube(
                                          onSceneCreated: _onSceneCreated)),
                                ),
                                mapOfEarth(context, isTap),
                              ],
                            )),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: smallCardInfo(
                                  cardGradientFirstGreen,
                                  cardGradientSecondGreen,
                                  "Plants",
                                  "256k",
                                  "+4% of target",
                                  "res/bihance_pic/graph_green.svg",
                                  textColorLightGreen),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: smallCardInfo(
                                    cardGradientFirstBlue,
                                    cardGradientSecondBlue,
                                    "Users",
                                    "128k",
                                    "+22% of target",
                                    "res/bihance_pic/graph_blue.svg",
                                    textCountColorBlue)),
                            Container(),
                          ],
                        )),
                    ratio(context),
                    totalProgress(context),
                    areasAttention(context),
                    SizedBox(
                      height: 140,
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(bottom: 0, left: 0, child: bottomNavBar(context)),
        ],
      ),
    );
  }

  Widget mapOfEarth(BuildContext context, bool isTap) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 600),
      // transitionBuilder: (Widget child,
      //     Animation<double> animation) {
      //   return ScaleTransition(
      //       scale: animation, child: child);
      // },
      child: isTap
          ? Container(
            child: Stack(
              children: [
                Container(
                  // height: 200,
                  padding: EdgeInsets.only(bottom: 50),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: PhotoView(
                        initialScale: 0.16,
                        backgroundDecoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                      backImageGradientFirst,
                          backImageGradientSecond,
                          ]),
                  ),
                        imageProvider: AssetImage("res/3d_model/flutter8_cut_transparent.png"),
                      ),
                    ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: MediaQuery.of(context).size.width - 32,
                    height: 50,
                    decoration: BoxDecoration(
                      color: bottomNavBarMapColor,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
                      ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset("res/bihance_pic/stats_tree.svg"),
                        SvgPicture.asset("res/bihance_pic/planted_trees.svg"),
                      ],
                    ),
                    ),
                  ),
              ],
            ),
          )
          : const SizedBox(),
    );
  }

  void _startEarthRotationController() {
    _controller.forward();
  }

  void _startEarthRotationTimer() {
    if (!_earthRotationTimer.isActive) {
      _earthRotationTimer = Timer(Duration(seconds: 2), () {
        if (_earth.rotation.y <= 0) {
          _controller.value = (_earth.rotation.y + 360) / 360;
        } else if (_earth.rotation.y >= 360) {
          _controller.value = (_earth.rotation.y - 360) / 360;
        } else {
          _controller.value = _earth.rotation.y / 360;
        }
        _controller
          ..forward()
          ..repeat();
      });
    }
  }

  void _startEarthZoomTimer() {
    if (!_earthZoomTimer.isActive) {
      isReverseZoom = true;
      _earthZoomTimer = Timer(Duration(milliseconds: 0), () {
        _earthDoubleTapSizeController.reverse();
        isReverseZoom = false;
      });
    }
  }
}

Widget areasAttention(BuildContext context) {
  return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        height: 64,
        decoration: BoxDecoration(
          color: Color(0xff1D2621),
          borderRadius: BorderRadius.circular(13),
        ),
        width: MediaQuery.of(context).size.width - 16 - 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              "res/bihance_pic/icons/alert_circle.svg",
              width: 24,
              height: 24,
            ),
            Text(
              "Areas Requiring Attention",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 24,
            ),
            Transform.rotate(
              angle: 180 * math.pi / 180,
              child: Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Colors.white,
              ),
            )
          ],
        ),
      ));
}

Widget totalProgress(BuildContext context) {
  return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        height: 230,
        decoration: BoxDecoration(
          color: Color(0xff1D2621),
          borderRadius: BorderRadius.circular(25),
        ),
        width: MediaQuery.of(context).size.width - 16 - 16,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  "res/bihance_pic/total_progress.svg",
                  width: 100,
                  height: 100,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Total progress",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 58,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("res/bihance_pic/green_bullet.svg"),
                        SizedBox(
                          width: 9,
                        ),
                        SizedBox(
                            width: 150,
                            child: Text(
                              "to normalize the oxygen situation",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("res/bihance_pic/red_bullet.svg"),
                        SizedBox(
                          width: 9,
                        ),
                        SizedBox(
                            width: 150,
                            child: Text(
                              "to rise temperature of the planet",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            )),
                      ],
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "150K",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: textColorLightGreen,
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "  /1,2M",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: bottomNavBarTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Plants",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: bottomNavBarTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "418",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "  /1500",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: bottomNavBarTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "CO2 (ppm)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: bottomNavBarTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 42,
                )
              ],
            )
          ],
        ),
      ));
}

Widget ratio(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("O2 to CO2 Ratio",
                  style: TextStyle(color: Colors.white, fontSize: 17)),
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.all(16),
            height: 368,
            decoration: BoxDecoration(
              color: Color(0xff1D2621),
              borderRadius: BorderRadius.circular(25),
            ),
            width: MediaQuery.of(context).size.width - 16 - 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "All",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                    Text(
                      "Month",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                    Text(
                      "Week",
                      style:
                          TextStyle(fontSize: 17, color: textColorLightGreen),
                    ),
                    Text(
                      "Day",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                    SizedBox(
                      width: 24,
                    ),
                    Icon(
                      Icons.more_horiz,
                      size: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 27, horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "+24%",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.red),
                          ),
                          SvgPicture.asset(
                              "res/bihance_pic/icons/co2_rating.svg"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "+4%",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: textColorLightGreen),
                          ),
                          SvgPicture.asset(
                              "res/bihance_pic/icons/o2_rating.svg"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "-20%",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.red),
                          ),
                          Text(
                            "Difference",
                            style: TextStyle(
                                fontSize: 12,
                                color: bottomNavBarTextColor,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                    child: SvgPicture.asset(
                  "res/bihance_pic/ratio_graph_full.svg",
                  // width: 296, height: 191,
                )),
                // Padding(
                //   padding: const EdgeInsets.only(top: 15.0),
                //   child: Container(
                //     width: 296, height: 191,
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                //       children: [
                //         Column(
                //           children: [
                //             Text(
                //               "17",
                //               style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //             Text(
                //               "MON",
                //               style: TextStyle(
                //                 color: bottomNavBarTextColor,
                //                 fontSize: 10,
                //                 fontWeight: FontWeight.w400,
                //               ),
                //             )
                //           ],
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "18",
                //               style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //             Text("TUE",
                //                 style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 10,
                //                   fontWeight: FontWeight.w400,
                //                 ))
                //           ],
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "19",
                //               style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //             Text("WED",
                //                 style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 10,
                //                   fontWeight: FontWeight.w400,
                //                 ))
                //           ],
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "20",
                //               style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //             Text("THU",
                //                 style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 10,
                //                   fontWeight: FontWeight.w400,
                //                 ))
                //           ],
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "21",
                //               style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //             Text("FRI",
                //                 style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 10,
                //                   fontWeight: FontWeight.w400,
                //                 ))
                //           ],
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "22",
                //               style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //             Text("SAT",
                //                 style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 10,
                //                   fontWeight: FontWeight.w400,
                //                 ))
                //           ],
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               "23",
                //               style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w800),
                //             ),
                //             Text("SUN",
                //                 style: TextStyle(
                //                   color: bottomNavBarTextColor,
                //                   fontSize: 10,
                //                   fontWeight: FontWeight.w400,
                //                 ))
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            )),
      ],
    ),
  );
}

Widget bottomNavBar(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return Container(
    width: size.width,
    height: 110,
    // color: Colors.white,
    child: Stack(
      children: [
        // SvgPicture.asset("res/bihance_pic/bottom_nav_bar.svg", fit: BoxFit.fill,),
        CustomPaint(
          size: Size(size.width, 110),
          painter: BNBCustomPainter(),
        ),
        Center(
            heightFactor: 0,
            child: Transform.rotate(
              angle: -math.pi / 4,
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: bottomNavBarButtonColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.close),
              ),
            )),
        Container(
          width: size.width,
          height: 80,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              bottomNavBarIcon("res/bihance_pic/icons/home.svg", "Home", true,
                  bottomNavBarSelectTextColor),
              bottomNavBarIcon("res/bihance_pic/icons/search.svg", "Search",
                  true, bottomNavBarTextColor),
              SizedBox(
                width: size.width * 0.20,
                child: bottomNavBarIcon("res/bihance_pic/icons/search.svg",
                    "Plant", false, bottomNavBarTextColor),
              ),
              bottomNavBarIcon("res/bihance_pic/icons/rating.svg", "Rating",
                  true, bottomNavBarTextColor),
              bottomNavBarIcon("res/bihance_pic/icons/profile.svg", "Profile",
                  true, bottomNavBarTextColor),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget bottomNavBarIcon(
    String path, String title, bool isIconVisible, Color textColor) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Opacity(
        opacity: isIconVisible ? 1 : 0,
        child: SvgPicture.asset(
          path,
          height: 30,
          width: 30,
        ),
      ),
      Text(title, style: TextStyle(fontSize: 10, color: textColor))
    ],
  );
}

Widget smallCardInfo(Color firstColor, Color secondColor, String title,
    String count, String target, String path, Color textColor) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gradient: LinearGradient(colors: [
          firstColor,
          secondColor,
        ])),
    height: 210,
    width: 200,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: 14,
          ),
          Row(
            children: [
              Text(
                count,
                style: TextStyle(
                    fontSize: 34,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                target,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                SvgPicture.asset(path),
              ],
            ),
          ),
        ],
      ),
    ),
  );
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

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = bottomNavBarColor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 10);
    path.quadraticBezierTo(size.width * 0.0, 10, size.width * 0.0, 25);
    path.quadraticBezierTo(size.width * 0.0, 10, size.width * 0.06, 10);
    path.quadraticBezierTo(size.width * 0.12, 10, size.width * 0.36, 10);
    path.quadraticBezierTo(size.width * 0.4, 10, size.width * 0.44, 30);
    path.quadraticBezierTo(size.width * 0.44, 30, size.width * 0.465, 40);
    path.quadraticBezierTo(size.width * 0.48, 44, size.width * 0.50, 44);
    path.quadraticBezierTo(size.width * 0.51, 44, size.width * 0.52, 43);
    path.quadraticBezierTo(size.width * 0.54, 40, size.width * 0.56, 30);
    path.quadraticBezierTo(size.width * 0.6, 10, size.width * 0.64, 10);
    path.quadraticBezierTo(size.width * 0.8, 10, size.width * 0.94, 10);
    path.quadraticBezierTo(size.width * 1, 10, size.width * 1, 25);
    path.quadraticBezierTo(size.width * 1, 25, size.width * 1, 25);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
