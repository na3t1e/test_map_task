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
            Container(
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                onChanged: (value) => lat = double.parse(value),
                controller: latController,
                cursorColor: color,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "X",
                ),
              ),
            ),
            /// поле ввода Y
            Container(
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                onChanged: (value) => long = double.parse(value),
                controller: longController,
                cursorColor: color,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Y",
                ),
              ),
            ),
          ],
        ),
        actions: [
          /// кнопка для поиска плитки
          IconButton(
            onPressed: () {
              ///рассчитываются поля плитки по формуле
              if (lat != 0 && long != 0) {
                setState(() {
                  print((((pow(2, 19 + 8) / 2) * (1 + long! / 180)) / 256));
                  x = (((pow(2, 19 + 8) / 2) * (1 + long! / 180)) / 256)
                      .floor();
                  y = (((pow(2, 19 + 8) / 2) *
                              (1 -
                                  log(
                                      tan(pi / 4 + ((pi * lat!) / 180) / 2) *
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
                });
              }
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
                "Координаты плитки: $x   $y",
              ),
              /// картинка плитки
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: url != null
                    ? CachedNetworkImage(
                        imageUrl: url!,
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          width: 200,
                          color: color,
                          child: const Center(
                              child: Text("Ошибка загрузки картинки")),
                        ),
                      )
                    : Container(
                        height: 200,
                        width: 200,
                        color: colorLight,
                        child: const Center(child: Text("Здесь будет  плитка")),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
