
import 'package:chimaek_festival/providers/command_provider.dart';
import 'package:flutter/material.dart';

class EditUrpPathDialog extends StatelessWidget{

  List<String> pathName = ['1잔 A', '1잔 B', '1잔 C',
    '2잔 A', '2잔 B', '2잔 C', '3잔', '홈위치'];
  late CommandProvider cp;
  final int textFieldCount = 8;
  late final List<TextEditingController> _controllers = List.generate(
    textFieldCount,
    (index) => TextEditingController(),

  );

  EditUrpPathDialog(this.cp){
    int i=0;
    for(var controller in _controllers.toList()){
      controller.text = cp.urpFileNames[i++].trim();
      // controller.text = controller.text.t
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: const Text('티칭 프로그램 경로 수정'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            for (int i = 0; i < textFieldCount; i++)
              Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Text(pathName[i]),
                    const Spacer(),
                    SizedBox(
                      width: 270,
                      child: TextField(
                        controller: _controllers[i],
                        // decoration: InputDecoration(
                        //   labelText: cp.urpFileNames[i],
                        // ),
                      ),
                    ),
                  ],
                )
              )
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
            for(int i=0; i<textFieldCount; i++){
              cp.urpFileNames[i] = _controllers[i].text;
            }
            cp.saveUrpPath();
            
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