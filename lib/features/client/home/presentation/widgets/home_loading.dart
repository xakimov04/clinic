import 'dart:io';

import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeLoading extends StatelessWidget {
  final String text;
  const HomeLoading({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: Platform.isIOS
                ? CupertinoActivityIndicator(
                    animating: true,
                    color: ColorConstants.primaryColor,
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryColor.withOpacity(0.8)),
                  ),
          ),
          16.h,
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ColorConstants.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
