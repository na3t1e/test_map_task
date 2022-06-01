import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double? lat;
  double? long;
  int x = 0;
  int y = 0;
  String? url;

  Color color = const Color.fromRGBO(21, 189, 213, 1);
  Color colorLight = const Color.fromRGBO(240, 248, 255, 1);

  late Offset tile = const Offset(234234.8, 46787654);

  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: colorLight,
        shadowColor: Colors.transparent,
        leading: IconButton(

            /// кнопка для сброса введенных данных
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {
                latController.clear();
                longController.clear();
                url = null;
                x = 0;
                y = 0;
              });
            },
            icon: Icon(Icons.cancel_outlined, color: color),
            iconSize: 32),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// поле ввода Х
            Input(controller: latController, color: color, text: "X"),

            /// поле ввода Y
            Input(controller: longController, color: color, text: "Y"),
          ],
        ),
        actions: [
          /// кнопка для поиска плитки
          IconButton(
            onPressed: () {
              lat = double.parse(latController.text);
              long = double.parse(longController.text);

              ///рассчитываются поля плитки по формуле
              setState(
                () {
                  print((((pow(2, 19 + 8) / 2) * (1 + long! / 180)) / 256));
                  x = (((pow(2, 19 + 8) / 2) * (1 + long! / 180)) / 256)
                      .floor();
                  y = (((pow(2, 19 + 8) / 2) *
                              (1 -
                                  log(tan(pi / 4 + ((pi * lat!) / 180) / 2) *
                                          pow(
                                              (1 -
                                                      0.0818191908426 *
                                                          sin(((pi * lat!) /
                                                              180))) /
                                                  (1 +
                                                      0.0818191908426 *
                                                          sin(((pi * lat!) /
                                                              180))),
                                              0.0818191908426 / 2)) /
                                      pi)) /
                          256)
                      .floor();

                  url =
                      "https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=$x&y=$y&z=19&scale=1&lang=ru_RU";
                },
              );
            },
            icon: const Icon(Icons.search),
            iconSize: 32,
            color: color,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 200),
        child: Center(
          child: Column(
            children: [
              /// рассчитнанные координаты
              Text(
                "Координаты плитки: $x   $y", style: TextStyle( fontSize: 24, fontWeight: FontWeight.w600,),
              ),
              /// картинка плитки
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: url != null
                    ? CachedNetworkImage(
                        imageUrl: url!,
                        errorWidget: (context, url, error) => Placeholder(
                          color: color,
                          text: "Ошибка загрузки картинки плитки",
                        ),
                      )
                    : Placeholder(
                        color: colorLight,
                        text: "Здесь будет картинка плитки",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Placeholder extends StatelessWidget {
  Color color;
  String text;

  Placeholder({required this.color, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      color: color,
      child: Center(
          child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w300, color: Colors.blueGrey),
      )),
    );
  }
}

class Input extends StatelessWidget {
  TextEditingController controller;
  Color color;
  String text;

  Input(
      {required this.controller,
      required this.color,
      required this.text,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            width: 1,
            color: Colors.blueGrey,
          )),
      padding: const EdgeInsets.only(left: 8),
      width: 100,
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
        ],
        controller: controller,
        cursorColor: color,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: text,
        ),
      ),
    );
  }
}
