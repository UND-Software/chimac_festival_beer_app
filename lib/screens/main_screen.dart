import 'package:chimaek_festival/screens/widgets/edit_urp_path.dart';
import 'package:chimaek_festival/screens/widgets/popup_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          // 연결 끊김 팝업
          if(!cp.isConnected){
            if(cp.disconnect){
              _showConfirmDialog(context, PopUpData.ALARM_DISCONNECT);
            }
            else{
              _showConfirmDialog(context, PopUpData.ALARM_FAIL_CONNECT);
            }
          }
          // 홈 이동 완료 팝업
          if(cp.isPausing){
            if(cp.currentProgramState==CurrentProgramState.STOPPED){
              _showConfirmDialog(context, PopUpData.CHECK_GO_HOME);
              cp.isPausing = false;
            }
          }
          // 명령 시간초과 팝업
          if(cp.isPowerOnTimeOut){
              _showConfirmDialog(context, PopUpData.CHECK_ERROR_POWER_ON);
            }
          else if(cp.isBrakeReleaseTimeOut){
            _showConfirmDialog(context, PopUpData.CHECK_ERROR_BRAKE_RELEASE);
          }             
          // 로컬 제어 경고 팝업
          if(cp.isLocalControlMode){
            cp.isLocalControlMode = false;
            _showConfirmDialog(context, PopUpData.CHECK_ERROR_LOCAL_CONTROL_MODE);
          }
          // 안전모드 에러 경고 팝업
          if(cp.isSafetyError){
            cp.isSafetyError = false;
            _showConfirmDialog(context, PopUpData.CHECK_SAFETY_ERROR).then((ok)=>{
              cp.initStateByError()
            });
          }
          // 준비된 맥주 기기 수가 주문 수 보다 모자랄 경우 팝업
          if(!cp.isOrderAvailable){
            cp.isOrderAvailable = true;
            _showConfirmDialog(context, PopUpData.CHECK_BEER_AVAILABLE);
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
              PopupMenuButton<String>(
                icon: const Icon(
                    Icons.menu,
                    size: 50,
                  ),
                onSelected: (String result) {
                  // 선택된 항목에 따라 동작을 정의합니다.
                  switch (result) {
                    case 'URP 경로 수정':
                      // 옵션 1을 선택했을 때의 동작
                      if(cp.isConnected){
                        _showEditPathDialog(context, cp);
                      }
                      else{
                        _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION);
                      }
                      break;
                    case '앱 종료':
                      // 옵션 2를 선택했을 때의 동작
                      if(cp.currentProgramState==CurrentProgramState.PLAYING){
                        _showConfirmDialog(context, PopUpData.CHECK_EXIT_ROBOT_WORKING);
                      }
                      else{
                        _showConfirmDialog(context, PopUpData.CHECK_EXIT_APP).then((ok)=>{
                          SystemNavigator.pop()
                        });
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'URP 경로 수정',
                    child: Text('URP 경로 수정'),
                  ),
                  const PopupMenuItem<String>(
                    value: '앱 종료',
                    child: Text('앱 종료'),
                  ),
                ],
              ),
              const SizedBox(width: 20,)
            ],
          ),
          body: 
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
                                              _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION)
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
                                              _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION)
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
                                              _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION)
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
                                              _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION)
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
                                              _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION)
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
                                              _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION)
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
      _showConfirmDialog(context, PopUpData.CHECK_ERROR_CONNECTION);
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