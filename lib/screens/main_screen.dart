import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/command_provider.dart';
import '../utils/constants.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    //CommandProvider cp = Provider.of(context)<CommandProvider>();

    return Consumer<CommandProvider>(
      builder: (context, cp, _){
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: Colors.orange,
            title: SizedBox(
              width: 200,
              child: Image.asset('images/magbot+und.png'),

            ),

            actions: [
              CircularColorWidget(color : cp.isConnected ? Colors.green : Colors.red, diameter: 50, connectState: '',),
              const SizedBox(width: 10,),
              IconButton(
                iconSize: 80,
                onPressed: ()=>{
                
              },
              icon: const Icon(Icons.menu))
            ],
          ),
          body: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Row(
                            children : [
                              Padding(padding: EdgeInsets.all(30),
                                child: Text('맥주 주문',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.w500
                                  ),
                                )
                              ),
                              Spacer()
                            ]
                          ),
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(width: 10,height:50,),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child : OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.orange, width: 3),
                                    ),
                                    onPressed: ()=>{
                                      if(!cp.isConnected){
                                        _showConfirmDialog(context, PopUpData.CHECK_CONNECT)
                                      }
                                      else{
                                        _showConfirmDialog(context, PopUpData.CHECK_ONE).then((ok){
                                            if(ok!){
                                              cp.handleButtonPress(Command.ORDER_ONE);
                                            }
                                          }
                                        )
                                      }
                                    },
                                  child: const Text('1 잔',
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800
                                      ),
                                    )
                                  ),
                                ) 
                              ),
                              const SizedBox(width: 20,),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child : OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.orange, width: 3),
                                    ),
                                    onPressed: ()=>{
                                      if(!cp.isConnected){
                                        _showConfirmDialog(context, PopUpData.CHECK_CONNECT)
                                      }
                                      else{
                                        _showConfirmDialog(context, PopUpData.CHECK_TWO).then((ok){
                                            if(ok!){
                                              cp.handleButtonPress(Command.ORDER_TWO);
                                            }
                                          }
                                        )
                                      }
                                    },
                                  child: const Text('2 잔',
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800
                                      ),
                                    )
                                  ),
                                ) 
                              ),
                              const SizedBox(width: 20,),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child : OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.orange, width: 3),
                                    ),
                                    onPressed: ()=>{
                                      if(!cp.isConnected){
                                        _showConfirmDialog(context, PopUpData.CHECK_CONNECT)
                                      }
                                      else{
                                        _showConfirmDialog(context, PopUpData.CHECK_THREE).then((ok){
                                            if(ok!){
                                              cp.handleButtonPress(Command.ORDER_THREE);
                                            }
                                          }
                                        )
                                      }
                                    },
                                  child: const Text('3 잔',
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800
                                      ),
                                    )
                                  ),
                                ) 
                              ),
                              const SizedBox(width: 10,),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            color: const Color.fromARGB(255, 227, 227, 227),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 100,
                                    width: 180,
                                    child: ElevatedButton(onPressed: ()=>{
                                          if(cp.robotModeData==RobotMode.POWER_OFF){
                                            cp.handleButtonPress(Command.POWER_ON)
                                          }
                                          else if(cp.robotModeData == RobotMode.POWER_ON || cp.robotModeData == RobotMode.RUNNING || cp.robotModeData == RobotMode.IDLE){
                                            cp.handleButtonPress(Command.POWER_OFF)
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange
                                        ),
                                        child: Text(cp.robotModeData==RobotMode.POWER_OFF ? '전원 ON' : 
                                        (cp.robotModeData == RobotMode.POWER_ON || cp.robotModeData == RobotMode.RUNNING || cp.robotModeData == RobotMode.IDLE) ? '전원 OFF' : cp.robotModeData.ko,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600
                                            ),

                                          )
                                        ),
                                    ),
                                    const SizedBox(width: 20,),
                                    SizedBox(
                                    height: 100,
                                    width: 180,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.deferToChild,
                                      onTapUp: (_)=>{
                                        
                                        cp.handleButtonPress(Command.PAUSE)
                                      },
                                      child: ElevatedButton(
                                        onPressed: ()=>{

                                        },
                                        onLongPress: ()=>{
                                          if(cp.isConnected){
                                            cp.handleButtonPress(Command.GO_HOME)
                                          }
                                        },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange
                                        ),
                                        child: const Text('홈 이동',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600
                                            ),
                                          )
                                        ),
                                      )
                                    ),
                                    const SizedBox(width: 20,),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: ListBody(
                                          children: [
                                            Text('send message : ${cp.sendMessage}'),
                                            Text('reply message : ${cp.commandReplyData}'),
                                            Text('send message : ${cp.logData}'),
                                          ],
                                        ),
                                      )
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      )
                    ],              
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color.fromARGB(92, 255, 153, 0),
                    child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      const Text('로봇 상태',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10,),
                          SizedBox(
                            height: 100,
                            child: ElevatedButton(
                              onPressed: ()=>{
                                if(!cp.isConnected){
                                  cp.connectRobot()
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  
                                  CircularColorWidget(color : cp.robotModeData.color, 
                                    diameter: 30, connectState: ''),
                                  Text(cp.robotModeData.ko,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width : 10)
                                ]
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                        ],
                      ),
                      
                      const SizedBox(height: 20,),
                      const Text('안전 상태',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10,),
                          SizedBox(
                            height: 100,
                            child: ElevatedButton(
                              onPressed: ()=>{},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width : 25),
                                  CircularColorWidget(color : cp.safetyStatusData.color, 
                                    diameter: 30, connectState: ''),
                                  Text(cp.safetyStatusData.ko,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width : 25)
                                ]
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      const Text('작업 현황',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10,),
                          SizedBox(
                            height: 100,
                            child: ElevatedButton(
                              onPressed: ()=>{},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width : 25),
                                  Text((cp.currentTaskNum != 4 && cp.currentTaskNum != 0) ? '${cp.currentTaskNum+1}잔' : 
                                  (cp.currentTaskNum == 0 ? '대기 중' : '홈 이동'),
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width : 25)
                                ]
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        );
      },
    );
  }
  
  Future<bool?> _showConfirmDialog(BuildContext context, PopUpData popupData) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // user must tap button to close the dialog
      builder: (BuildContext context) {
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
      },
    );
  }
}


// ignore: must_be_immutable
class CircularColorWidget extends StatelessWidget {
  Color color;
  final double diameter;
  String connectState = '';

  CircularColorWidget({super.key, required this.color, required this.diameter, required this.connectState});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children : [
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ]
    );
  }

  
}