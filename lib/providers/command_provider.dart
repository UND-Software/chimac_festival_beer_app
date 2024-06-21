import 'dart:io';

import 'package:chimaek_festival/utils/constants.dart';
import 'package:chimaek_festival/utils/util.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mutex/mutex.dart';

class CommandProvider with ChangeNotifier {

  final Mutex _mutex = Mutex();

  final String settingFileName = 'setting.conf';
  List<String> urpFileNames = [];
  List<bool> isBeerReady = [true, true, true];
  bool isTimeOut = false;
  bool isTimerStart = false;

  final String ip = '220.81.122.102';
  final int port = 54662;
  // final String ip = '192.168.0.8';
  // final int port = 29999;

  Socket? _socket;

  RobotMode robotModeData = RobotMode.DISCONNECTED;
  SafetyStatus safetyStatusData = SafetyStatus.ERROR;
  CurrentProgramState currentProgramState = CurrentProgramState.STOPPED;
  CurrentCommandState currentCommandState = CurrentCommandState.NONE;

  String sendMessage = '';
  String logData = '';
  String commandReplyData = '';
  String commandString = '';

  bool isConnected = false;
  late File settingFile;

  // 현재 작업 (0~3: 대기중, 1잔, 2잔, 3잔)
  int currentTaskNum = 0;
  
  Timer? timer;

  
  // setting.conf 파일에 있는 로봇 urp 파일 경로들을 불러옴.
  // 위에서 부터 차례대로
  // 1잔-1번/2번/3번
  // 2잔-1,2번/1,3번/2,3번
  // 3잔-1,2,3번
  // 홈위치 
  // 각각의 경우의 수에 대한 urp 파일(8개)를 읽는다.
  Future<void> initCommand() async{
    try {
      final String config = await rootBundle.loadString('setting.conf');
      urpFileNames = config.split('\n');
    } catch (e) {
      throw Exception("Error loading setting.conf: $e");
    }
    notifyListeners();
  }

  Future<bool> connectRobot() async {
    try {
      print('Trying to connect to $ip:$port');
      _socket = await Socket.connect(ip, port).timeout(const Duration(seconds: 5));
      print('Connection established');
      isConnected = true;

      _socket!.listen((data) {
        onServerResponse(String.fromCharCodes(data));
      }, onError: (error) {
        print('Data error: $error');
        _disconnectFromServer();
      }, onDone: () {
        print('Connection closed by server');
        _disconnectFromServer();
      });

      if(isConnected) {
        startPeriodicCommand();
        return true;
      }
    } catch (e) {
      print('Connection failed: $e');
    }
    return false;
  }

  // 1초마다 로봇상태와 안전상태 확인 명령어를 보냄
  void startPeriodicCommand() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _sendCommand(Command.ROBOT_MODE);
      await Future.delayed(const Duration(milliseconds: 500));
      await _sendCommand(Command.SAFETY_STATUS);
      await Future.delayed(const Duration(milliseconds: 500));
      if (currentTaskNum != 0){
        await _sendCommand(Command.PROGRAM_STATE);
      }
    });
  }

  Future<void> startTimeOutListener() async{

    await Future.delayed(const Duration(seconds: 5));

    isTimeOut = true;
  }

  // 
  Future<void> _sendCommand(Command command, {String fileName = ''}) async {
    await Future.delayed(const Duration(seconds: 1));
    commandString = command.command;

    if(fileName != ''){
      commandString += ' $fileName';
    }

    _socket!.write('$commandString\n');
    
    sendMessage = commandString;
    notifyListeners();

    return;
  }


  Future<void> handleButtonPress(Command command) async {
    
    // 주기적인 명령어 전송 멈춤
    //timer?.cancel();

    await Future.delayed(const Duration(seconds: 1));
    
    if(command==Command.POWER_OFF){
      // 버튼 명령어 전송
      await _sendCommand(command);
    }
    else if(currentCommandState != CurrentCommandState.NONE){
      return;
    }
    else{
      // 현재 맥주 주문 중일 때는 동작x
      // 홈위치 이동/ 대기 중 상태일때만 동작
      if (currentTaskNum != 0 && currentTaskNum != 4){
        return;
      }

      switch (command){
        case Command.POWER_ON:
          await _sendPowerOnCommand();
          break;
        case Command.ORDER_ONE:
          // await _sendOrderCommand(0);
          await _sendTestCommand(0);
          break;
        case Command.ORDER_TWO:
          // await _sendOrderCommand(1);
          await _sendTestCommand(1);
          break;
        case Command.ORDER_THREE:
          // await _sendOrderCommand(2);
          await _sendTestCommand(2);
          break;
        case Command.GO_HOME:
          await _sendGoHomeCommand();
          break;
        case Command.PAUSE:
          if(currentTaskNum == 4 && currentCommandState == CurrentCommandState.GOING_HOME){
            await _sendPauseGoHomeCommand();
          }
        default:
      }
    }
    notifyListeners();
    // 잠시 대기 후 주기적인 명령어 전송 재개
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> onServerResponse(String response) async {
    commandReplyData = response.replaceFirst('\n', ' ');

    // 로봇모드 확인 명령어 응답
    if (commandReplyData.toLowerCase().contains(Command.ROBOT_MODE.command)){
      robotModeData = RobotMode.getRobotModeByString(commandReplyData);

      if(currentCommandState == CurrentCommandState.POWERING_ON){
        // if(!isTimerStart) {
        //   isTimerStart = true;
        //   startTimeOutListener();
        // }
          
        if (commandReplyData.contains(RobotMode.IDLE.value)){
          await _sendCommand(Command.BRAKE_RELEASING);
          setCurrentCommandState(CurrentCommandState.BRAKE_RELEASING);
        }

        // 시간 초과
        // else if(isTimeOut){
        //   logData = '[error] powering on 시간초과. 다시 시도해주세요.';
        //   setCurrentCommandState(CurrentCommandState.NONE);
        //   startPeriodicCommand();
        //   isTimeOut = false;
        //   isTimerStart = false;
        // }
        // else{
        //   await _sendCommand(Command.ROBOT_MODE);
        // }
        notifyListeners();
      }
      
      else if(currentCommandState == CurrentCommandState.BRAKE_RELEASING){
        if (commandReplyData.contains(RobotMode.RUNNING.value)){
          logData = '[log] power on 명령 완료.';
          setCurrentCommandState(CurrentCommandState.NONE);
          notifyListeners();
          startPeriodicCommand();
        }

        // 시간 초과
        // else if(isTimeOut){
        //   logData = '[error] powering on 시간초과. 다시 시도해주세요.';
        //   setCurrentCommandState(CurrentCommandState.NONE);
        //   startPeriodicCommand();
        //   isTimeOut = false;
        //   isTimerStart = false;
        // }
        
        else{
          await _sendCommand(Command.ROBOT_MODE);
        }
        notifyListeners();
      }
    }
    // 안전상태 확인 명령어 응답
    else if (commandReplyData.toLowerCase().contains(Command.SAFETY_STATUS.command)){
      safetyStatusData = SafetyStatus.getSafetyStatusByString(commandReplyData);
    }
    // 프로그램 상태 명령어 확인 응답
    else if (containsSubstring(commandReplyData, CurrentProgramState.toList())){
      currentProgramState = CurrentProgramState.getCurrentProgramStateByString(commandReplyData);

      if (currentProgramState==CurrentProgramState.STOPPED){
        currentTaskNum = 0;
      }
    }
    // LOAD 명령어 응답
    else if (commandReplyData.toLowerCase().contains(Command.LOAD.command)){
      if (commandReplyData.toLowerCase().contains(Command.LOAD.success)){
        if (currentTaskNum == 4){
          logData = '[error] 홈 위치 urp 파일 로드 실패';
          
        }
        else{
          logData = '[error] urp 파일 로드 실패';
        }
        
        setCurrentCommandState(CurrentCommandState.NONE);
        currentTaskNum = 0;
        notifyListeners();
        return;
      }
      setCurrentCommandState(CurrentCommandState.LOADING);
      await _sendCommand(Command.PLAY);
    }
    // PLAY 명령어 응답
    else if (commandReplyData.toLowerCase().contains(Command.PLAY.command)){
      if (commandReplyData.toLowerCase().contains(Command.PLAY.success)){
        logData = '[error] play 명령어 실패';
        setCurrentCommandState(CurrentCommandState.NONE);
        currentTaskNum = 0;
        notifyListeners();
        return;
      }
      setCurrentCommandState(CurrentCommandState.NONE);
      logData = '[log] play 명령어 성공';
      currentTaskNum = 0;
      notifyListeners();
    }

    // POWER ON 명령어 응답
    else if (commandReplyData.toLowerCase().contains(Command.POWER_ON.command)){
      if (commandReplyData.toLowerCase().contains(Command.POWER_ON.success)){
        logData = '[error] power on 명령어 실패';
        return;
      }
      setCurrentCommandState(CurrentCommandState.POWERING_ON);
      await _sendCommand(Command.ROBOT_MODE);
    }
  }

  Future<void> _sendTestCommand(int commandNum) async{

    currentTaskNum = commandNum+1;

    await _sendCommand(Command.LOAD, fileName: urpFileNames[0]);

    notifyListeners();
  }

  Future<void> _sendOrderCommand(int commandNum) async{

    int urpFileNum;
    currentTaskNum = commandNum+1;

    // 1잔 주문
    if(commandNum == 0){
      urpFileNum = 0;
      urpFileNum += isBeerReady.indexWhere((element)=> element == true);
      currentTaskNum = 1;
    }
    // 2잔 주문
    else if(commandNum == 1){
      urpFileNum = 3;
      if(isBeerReady.where((element) => element == true).length < 2){
        logData = '[error] 주문 수 보다 작업 가능한 맥주 기기의 수가 부족합니다.';
      }

      urpFileNum += (2-isBeerReady.indexWhere((element)=> element == false));
      currentTaskNum = 2;
    }
    else{
      if(isBeerReady.where((element) => element == true).length < 3){
        logData = '[error] 주문 수 보다 작업 가능한 맥주 기기의 수가 부족합니다.';
      }
      urpFileNum = 6;
      currentTaskNum = 3;
    }

    await _sendCommand(Command.LOAD, fileName: urpFileNames[urpFileNum]);

    notifyListeners();
  }

  Future<String> _sendGoHomeCommand() async{
    // 이전 작업이 홈 이동이 아닐 때, urp 로드
    if (currentProgramState == CurrentProgramState.STOPPED && currentTaskNum == 0){
      await _sendCommand(Command.LOAD, fileName: urpFileNames[7]);
      if (!commandReplyData.toLowerCase().contains(Command.LOAD.success)){
        
        return '[error] go home urp 파일 로드 명령 실패';
      }
    }
    return commandString;
  }

  Future<String> _sendPauseGoHomeCommand() async{
    if (currentProgramState == CurrentProgramState.PLAYING){
      await _sendCommand(Command.PLAY);
      if (!commandReplyData.toLowerCase().contains(Command.PLAY.success)){
        return '[error] play 명령 실패.';
      }
      return '[log] 홈 이동 일시 정지';
    }
    return '[error] 현재 작동중이 아닙니다.';
  }


  Future<void> _sendPowerOnCommand() async{

    await _sendCommand(Command.POWER_ON);
    setCurrentCommandState(CurrentCommandState.POWERING_ON);
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

  Future<void> setCurrentCommandState(CurrentCommandState c) async{
    await _mutex.acquire();

    try{
      currentCommandState = c;
    }
    finally{
      _mutex.release();
    }
  }

  Future<void> editUrpPath() async {
    String content = '';

    for(String path in urpFileNames){
      content += path;
      content += '\n';
    }

    await settingFile.writeAsString(content);
  }
}