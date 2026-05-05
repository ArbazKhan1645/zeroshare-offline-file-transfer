import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zero_share/utils/color.dart';

class StackedWidgets extends StatelessWidget {
  final List<Widget> items;
  final TextDirection direction;
  final double size;
  final double xShift;

  const StackedWidgets({
    super.key,
    required this.items,
    this.direction = TextDirection.ltr,
    this.size = 40,
    this.xShift = 12,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = items
        .asMap()
        .map((index, item) {
          final left = size - xShift;

          final value = Container(
            width: size,
            height: size,
            margin: EdgeInsets.only(left: left * index),
            child: item,
          );

          return MapEntry(index, value);
        })
        .values
        .toList();

    return Stack(
      children: direction == TextDirection.ltr
          ? allItems.reversed.toList()
          : allItems,
    );
  }
}

class CustomStackImages extends StatelessWidget {
  final List<String> urlImages;

  const CustomStackImages({super.key, required this.urlImages});

  @override
  Widget build(BuildContext context) {
    return buildStackedImages();
  }

  Widget buildStackedImages({TextDirection direction = TextDirection.rtl}) {
    const double xShift = 16;

    final items = urlImages.map((urlImage) => buildImage(urlImage)).toList();

    return StackedWidgets(
      direction: direction,
      items: items,
      xShift: xShift,
    );
  }

  Widget buildImage(String urlImage) {
    const double borderSize = 2;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColor.colorWhite,
        border: Border.all(color: AppColor.colorWhite, width: borderSize),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.hardEdge,
        child: Image.file(File(urlImage), fit: BoxFit.cover),
      ),
    );
  }
}
