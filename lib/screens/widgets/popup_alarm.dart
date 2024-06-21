
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class PopUpAlarmDialog extends StatelessWidget{

  late PopUpData popupData;

  PopUpAlarmDialog(PopUpData data, {super.key}){
    popupData = data;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: Text(popupData.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(popupData.body),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style : ElevatedButton.styleFrom(
              backgroundColor: Colors.orange
            ),
          child: const Text('확인',
            style: TextStyle(
              color: Colors.white
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true); // Approve 버튼 클릭 시 true 반환
          },
        ),
        ElevatedButton(
          style : ElevatedButton.styleFrom(
              backgroundColor: Colors.orange
            ),
          child: const Text('취소',
            style: TextStyle(
              color: Colors.white
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(false); // Cancel 버튼 클릭 시 false 반환
          },
        ),
      ],
    );
  }
}