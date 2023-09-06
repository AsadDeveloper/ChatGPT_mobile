import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../widgets/drop_down.dart';
import '../widgets/text_widget.dart';

class Services {
  static Future<void> showModalSheet({required BuildContext context}) async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        backgroundColor: scaffoldBackgroundColor,
        context: context,
        builder: (context) {
          return const Padding(
            padding: EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: TextWidget(
                  label: "choosen model:",
                  fontSize: 16,
                )),
                Flexible(flex: 2, child: DropDownWidget()),
              ],
            ),
          );
        });
  }
}
