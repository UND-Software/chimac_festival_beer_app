import 'dart:io';

import 'package:chimaek_festival/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class CommandProvider with ChangeNotifier {

  String settingFileName = 'setting.conf';
  List<String> urpFileNames = [];

  Socket? _socket;

  RobotMode robotModeData = RobotMode.DISCONNECTED;
  SafetyStatus safetyStatusData = SafetyStatus.ERROR;
  CurrentTaskState currentTaskState = CurrentTaskState.STOP;

  String sendMessage = '';
  String logData = '';
  String commandReplyData = '';

  bool isConnected = false;
  late File settingFile;

  // 현재 작업 (0~3: 대기중, 1잔, 2잔, 3잔)
  int currentTaskNum = 0;
  
  Timer? timer;


  Future<void> initCommand() async{
    try {
      final file = File(settingFileName);

      if (!(await file.exists())) {
        print('File does not exist.');
        return;
      }

      urpFileNames = await file.readAsLines();
    } catch (e) {
      print('Error reading file: $e');
      return;
    }
    //notifyListeners();
  }

  Future<bool> connectRobot() async{
    
    try{
      _socket = await Socket.connect('192.168.0.8', 29999).timeout(Duration(seconds: 10));

      _socket!.listen((data) {
        
        commandReplyData = String.fromCharCodes(data);
        print('Received: $commandReplyData');
        isConnected = true;

        }, onError: (error) {
          logData = 'Connection error: $error';
          _disconnectFromServer();
        }, onDone: () {
          logData = 'Connection closed by server';
          _disconnectFromServer();
        }
      );
      notifyListeners();

      if(isConnected){
        startPeriodicCommand();
        return true;
      }
      return false;
    }
    catch(e){
      logData = 'error : connect fail';
      notifyListeners();
      return false;
    }
    
  }

  // 1초마다 로봇상태와 안전상태 확인 명령어를 보냄
  void startPeriodicCommand() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _sendCommand(Command.ROBOT_MODE);
      await _sendCommand(Command.SAFETY_STATUS);

      if (currentTaskNum != 0){
        await _sendCommand(Command.PROGRAM_STATE);
      }
    });
  }

  // 
  Future<String> _sendCommand(Command command, {String fileName = ''}) async {
    String commandString = command.command;

    if(fileName != ''){
      commandString += ' $fileName';
    }

    _socket!.write('$commandString\n');
    
    // 응답 대기 및 처리
    _socket!.listen((data) {
      final commandReplyData = String.fromCharCodes(data);

      if (commandString.compareTo(Command.ROBOT_MODE.command) == 0){
        robotModeData = RobotMode.getRobotModeByString(commandReplyData);
      }
      else if (commandString.compareTo(Command.SAFETY_STATUS.command) == 0){
        safetyStatusData = SafetyStatus.getSafetyStatusByString(commandReplyData);
      }
      else if (commandString.compareTo(Command.PROGRAM_STATE.command) == 0){
        currentTaskState = CurrentTaskState.getCurrentTaskStateByString(commandReplyData);

        if (CurrentTaskState.getCurrentTaskStateByString(commandReplyData)==CurrentTaskState.STOP){
          currentTaskNum = 0;
        }
      }
      else{
        sendMessage = commandString;
      }
      notifyListeners();
    });
    
    return commandReplyData;
  }


  Future<void> handleButtonPress(Command command) async {
    
    // 주기적인 명령어 전송 멈춤
    timer?.cancel();

    if(command==Command.POWER_OFF){
      // 버튼 명령어 전송
      await _sendCommand(command);
    }

    else{
      // 현재 작업중일 때 동작X
      if (currentTaskNum != 0){
        return;
      }

      switch (command){
        case Command.POWER_ON:
          logData = await _sendPowerOnCommand();
          break;
        case Command.ORDER_ONE:
          logData = await _sendOrderCommand(0);
          break;
        case Command.ORDER_TWO:
          logData = await _sendOrderCommand(1);
          break;
        case Command.ORDER_THREE:
          logData = await _sendOrderCommand(2);
          break;
        case Command.GO_HOME:
          logData = await _sendGoHomeCommand();
          break;
        case Command.PAUSE:
          if(currentTaskNum == 4){
            logData = await _sendCommand(command);
          }
        default:
      }
    }
    notifyListeners();
    // 잠시 대기 후 주기적인 명령어 전송 재개
    await Future.delayed(const Duration(seconds: 1));
    startPeriodicCommand();
  }


  Future<String> _sendOrderCommand(int commandNum) async{

    commandReplyData = await _sendCommand(Command.LOAD, fileName: urpFileNames[commandNum]);
    if (commandReplyData.compareTo(Command.LOAD.success) != 0){
      logData = commandReplyData;
      return logData;
    }
    commandReplyData = await _sendCommand(Command.PLAY);
    if (commandReplyData.compareTo(Command.PLAY.success) != 0){
      logData = commandReplyData;
      return logData;
    }
    currentTaskNum = commandNum+1;

    return logData;
  }

  Future<String> _sendGoHomeCommand() async{
    
    if (currentTaskState == CurrentTaskState.STOP && currentTaskNum == 0){
      commandReplyData = await _sendCommand(Command.LOAD, fileName: urpFileNames[3]);
      if (commandReplyData.compareTo(Command.LOAD.success) != 0){
        logData = commandReplyData;
        return logData;
      }
    }

    if(currentTaskNum == 4){
      commandReplyData = await _sendCommand(Command.PLAY);
      if (commandReplyData.compareTo(Command.PLAY.success) != 0){
        logData = commandReplyData;
        return logData;
      }
    }

    currentTaskNum = 4;

    return commandReplyData;
  }

  Future<String> _sendPauseGoHomeCommand() async{
    if (currentTaskState == CurrentTaskState.PLAYING){
      commandReplyData = await _sendCommand(Command.PLAY);
      if (commandReplyData.compareTo(Command.PLAY.success) != 0){
        logData = commandReplyData;
        return logData;
      }
    }
    return 'error : 현재 작동중이 아닙니다.';
  }


  Future<String> _sendPowerOnCommand() async{
    commandReplyData = await _sendCommand(Command.POWER_ON);
    if (commandReplyData.compareTo(Command.POWER_ON.success) != 0){
      return commandReplyData;
    }

    while(true){
      await Future.delayed(const Duration(seconds: 1));
      commandReplyData = await _sendCommand(Command.ROBOT_MODE);

      notifyListeners();

      if (commandReplyData.compareTo(RobotMode.IDLE.value) == 0){
        commandReplyData = await _sendCommand(Command.BRAKE_RELEASING);
        break;
      }
    }

    while(true){
      await Future.delayed(const Duration(seconds: 1));
      commandReplyData = await _sendCommand(Command.ROBOT_MODE);

      notifyListeners();

      if (commandReplyData.compareTo(RobotMode.RUNNING.value) == 0){
        break;
      }
    }
    return commandReplyData;
  }

  void _disconnectFromServer() {
    if (_socket != null) {
      _socket!.destroy();
      isConnected = false;
    }
  }

  @override
  void dispose() {
    _disconnectFromServer();
    super.dispose();
  }
}