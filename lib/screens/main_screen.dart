import 'package:chimaek_festival/screens/widgets/edit_urp_path.dart';
import 'package:chimaek_festival/screens/widgets/popup_alarm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/command_provider.dart';
import '../utils/constants.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {


    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<CommandProvider>(
      builder: (context, cp, child){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(!cp.isConnected){
            if(cp.disconnect){
              _showConfirmDialog(context, PopUpData.ALARM_DISCONNECT);
            }
            else{
              _showConfirmDialog(context, PopUpData.ALARM_FAIL_CONNECT);
            }
          }
          if(cp.isPausing){
            if(cp.currentProgramState==CurrentProgramState.STOPPED){
              _showConfirmDialog(context, PopUpData.CHECK_GO_HOME);
              cp.isPausing = false;
            }
          }
        });
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: Colors.orange,
            title: SizedBox(
              width: 200,
              child: Image.asset('assets/images/magbot+und.png'),
            ),

            actions: [
              Column(
                children: [
                  Text('current command : ${cp.currentCommandState.value}'),
                  Text('current program state : ${cp.currentProgramState.value}'),
                ],
              ),
              GestureDetector(
                onTap: ()=>{
                  if(!cp.isConnected){
                    _showConfirmDialog(context, PopUpData.CHECK_CONNECT).then((ok)=>{
                      cp.connectRobot()
                    })
                  }
                },
                child: CircularColorWidget(color : cp.isConnected ? Colors.green : Colors.red, diameter: 50, connectState: '',),
              ),
              const SizedBox(width: 10,),
              IconButton(
                iconSize: 80,
                onPressed: ()=>{
                  _showEditPathDialog(context, cp)
              },
              icon: const Icon(Icons.menu))
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Row(
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
                                            side: BorderSide(color: cp.isPlayingProgram ? Colors.red : Colors.orange, width: 5),
                                          ),
                                          onPressed: ()=>{
                                            if(!cp.isConnected){
                                              _showConfirmDialog(context, PopUpData.CHECK_CONNECTION)
                                            }
                                            else{
                                              if(cp.currentTaskNum != 0){
                                                _showConfirmDialog(context, PopUpData.CHECK_WORKING)
                                              }
                                              else{
                                                _showConfirmDialog(context, PopUpData.CHECK_ONE).then((ok){
                                                    if(ok!){
                                                      cp.handleButtonPress(Command.ORDER_ONE);
                                                    }
                                                  }
                                                )
                                              }
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
                                          key : const Key('order btn'),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: cp.isPlayingProgram ? Colors.red : Colors.orange, width: 5),
                                          ),
                                          onPressed: ()=>{
                                            //TODO
                                            if(!cp.isConnected){
                                              _showConfirmDialog(context, PopUpData.CHECK_CONNECTION)
                                            }
                                            else{
                                              if(cp.currentTaskNum != 0){
                                                _showConfirmDialog(context, PopUpData.CHECK_WORKING)
                                              }
                                              else{
                                                _showConfirmDialog(context, PopUpData.CHECK_TWO).then((ok){
                                                    if(ok!){
                                                      cp.handleButtonPress(Command.ORDER_TWO);
                                                    }
                                                  }
                                                )
                                              }
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
                                            side: BorderSide(color: cp.isPlayingProgram ? Colors.red : Colors.orange, width: 5),
                                          ),
                                          onPressed: ()=>{
                                            if(!cp.isConnected){
                                              _showConfirmDialog(context, PopUpData.CHECK_CONNECTION)
                                            }
                                            else{
                                              if(cp.currentTaskNum != 0){
                                                _showConfirmDialog(context, PopUpData.CHECK_WORKING)
                                              }
                                              else{
                                                _showConfirmDialog(context, PopUpData.CHECK_THREE).then((ok){
                                                    if(ok!){
                                                      cp.handleButtonPress(Command.ORDER_THREE);
                                                    }
                                                  }
                                                )
                                              }
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
                                const Row(
                                  children : [
                                    Padding(padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
                                      child: Text('준비 상태',
                                        style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.w500
                                        ),
                                      )
                                    ),
                                    Spacer()
                                  ]
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text('1번',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text('2번',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text('3번',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                            side: BorderSide(color: cp.isBeerReady[0] ? Colors.green: Colors.red, width: 5),
                                          ),
                                          onPressed: ()=>{
                                            if(!cp.isConnected){
                                              _showConfirmDialog(context, PopUpData.CHECK_CONNECTION)
                                            }
                                            else{
                                              print('currentTaskNum : ${cp.currentTaskNum}'),
                                              if(cp.currentTaskNum != 0){
                                                _showConfirmDialog(context, PopUpData.CHECK_WORKING)
                                              }
                                              else{
                                                if(cp.isBeerReady[0]){
                                                  _showConfirmDialog(context, PopUpData.CHECK_STOP).then((ok){
                                                      if(ok!){
                                                        cp.isBeerReady[0] = false;
                                                      }
                                                    }
                                                  )
                                                }
                                                else{
                                                  _showConfirmDialog(context, PopUpData.CHECK_READY).then((ok){
                                                      if(ok!){
                                                        cp.isBeerReady[0] = true;
                                                      }
                                                    }
                                                  )
                                                }
                                              }
                                              
                                            }
                                          },
                                        child: Text(cp.isBeerReady[0] ? '준비' : '정지',
                                          style: const TextStyle(
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
                                            side: BorderSide(color: cp.isBeerReady[1] ? Colors.green: Colors.red, width: 5),
                                          ),
                                          onPressed: ()=>{
                                            if(!cp.isConnected){
                                              _showConfirmDialog(context, PopUpData.CHECK_CONNECTION)
                                            }
                                            else{
                                              print('currentTaskNum : ${cp.currentTaskNum}'),
                                              if(cp.currentTaskNum != 0){
                                                _showConfirmDialog(context, PopUpData.CHECK_WORKING),
                                              }
                                              else{
                                                if(cp.isBeerReady[1]){
                                                  _showConfirmDialog(context, PopUpData.CHECK_STOP).then((ok){
                                                      if(ok!){
                                                        cp.isBeerReady[1] = false;
                                                      }
                                                    }
                                                  )
                                                }
                                                else{
                                                  _showConfirmDialog(context, PopUpData.CHECK_READY).then((ok){
                                                      if(ok!){
                                                        cp.isBeerReady[1] = true;
                                                      }
                                                    }
                                                  )
                                                }
                                              }
                                              
                                            }
                                          },
                                      child: Text(cp.isBeerReady[1] ? '준비' : '정지',
                                          style: const TextStyle(
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
                                            side: BorderSide(color: cp.isBeerReady[2] ? Colors.green: Colors.red, width: 5),
                                          ),
                                          onPressed: ()=>{
                                            if(!cp.isConnected){
                                              _showConfirmDialog(context, PopUpData.CHECK_CONNECTION)
                                            }
                                            else{
                                              if(cp.currentTaskNum != 0){
                                                _showConfirmDialog(context, PopUpData.CHECK_WORKING)
                                              }
                                              else{
                                                if(cp.isBeerReady[2]){
                                                  _showConfirmDialog(context, PopUpData.CHECK_STOP).then((ok){
                                                      if(ok!){
                                                        cp.isBeerReady[2] = false;
                                                      }
                                                    }
                                                  )
                                                }
                                                else{
                                                  _showConfirmDialog(context, PopUpData.CHECK_READY).then((ok){
                                                      if(ok!){
                                                        cp.isBeerReady[2] = true;
                                                      }
                                                    }
                                                  )
                                                }
                                              }
                                              
                                            }
                                          },
                                        child: Text(cp.isBeerReady[2] ? '준비' : '정지',
                                          style: const TextStyle(
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
                                Container(
                                  color: const Color.fromARGB(255, 227, 227, 227),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 200,
                                          child: ElevatedButton(
                                            key : const Key('power on btn'),
                                            onPressed: ()=>{
                                                if(cp.robotModeData==RobotMode.POWER_OFF){
                                                  _showConfirmDialog(context, PopUpData.CHECK_POWER_ON).then((ok){
                                                      if(ok!){
                                                        cp.handleButtonPress(Command.POWER_ON);
                                                      }
                                                    }
                                                  )
                                                }
                                                else if(cp.robotModeData == RobotMode.POWER_ON || cp.robotModeData == RobotMode.RUNNING || cp.robotModeData == RobotMode.IDLE){
                                                  _showConfirmDialog(context, PopUpData.CHECK_POWER_OFF).then((ok){
                                                      if(ok!){
                                                        cp.handleButtonPress(Command.POWER_OFF);
                                                      }
                                                    }
                                                  )
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange
                                              ),
                                              child: Text(cp.robotModeData==RobotMode.POWER_OFF ? '전원 ON' : 
                                              (cp.robotModeData == RobotMode.POWER_ON || cp.robotModeData == RobotMode.IDLE || cp.robotModeData == RobotMode.BOOTING) ? '전원 켜는 중' : '전원 OFF',
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
                                            onLongPressUp: ()=>{
                                              if(cp.isConnected){
                                                  cp.setIsPausing(true),
                                                  cp.handleButtonPress(Command.PAUSE)
                                                }
                                            },
                                            onLongPressDown: (_)=>{
                                              if(cp.isConnected){
                                                  cp.handleButtonPress(Command.GO_HOME)
                                                }
                                            },
                                            child: ElevatedButton(
                                              onPressed: ()=>{

                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: cp.isPausing ? Colors.green : Colors.orange,
                                                
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
                                                  Text('log message : ${cp.logData}'),
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
                                        Text((cp.currentTaskNum != 4 && cp.currentTaskNum != 0) ? '${cp.currentTaskNum}잔' : 
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
                ),
                if (keyboardHeight > 0)
                Positioned(
                  bottom: keyboardHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: keyboardHeight,
                    color: Colors.transparent,
                  ),
                ),
              ]
            ),
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
        return PopUpAlarmDialog(popupData);
      },
    );
  }

  Future<bool?> _showEditPathDialog(BuildContext context, CommandProvider cp){
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return EditUrpPathDialog(cp);
      }
    );
  }

  Future<bool?>? _showNetworkAlarmDialog(CommandProvider cp, BuildContext context){
    if(!cp.isConnected){
      return cp.disconnect ?
        _showConfirmDialog(context, PopUpData.ALARM_DISCONNECT) :
        _showConfirmDialog(context, PopUpData.ALARM_FAIL_CONNECT);
    }
    else{
      return null;
    }
  }

  // TODO
  void onPressedOrderButton(CommandProvider cp, BuildContext context, int orderNum){

    PopUpData pd;

    if(!cp.isConnected){
      _showConfirmDialog(context, PopUpData.CHECK_CONNECTION);
    }
    else{
      if(cp.currentTaskNum != 0){
        _showConfirmDialog(context, PopUpData.CHECK_WORKING);
      }
      else{
        _showConfirmDialog(context, PopUpData.CHECK_TWO).then((ok){
            if(ok!){
              cp.handleButtonPress(Command.ORDER_TWO);
            }
          }
        );
      }
    }
  }
}



// ignore: must_be_immutable
class CircularColorWidget extends StatelessWidget {
  Color color;
  final double diameter;
  String connectState = '';
  late CommandProvider cp;

  CircularColorWidget({super.key, required this.color, required this.diameter, required this.connectState});

  @override
  Widget build(BuildContext context) {
    cp = Provider.of<CommandProvider>(context); 

    return 
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
  }
}