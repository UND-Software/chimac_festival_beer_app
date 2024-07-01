import 'dart:io';

import 'package:chimaek_festival/utils/constants.dart';
import 'package:chimaek_festival/utils/util.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:mutex/mutex.dart';

class CommandProvider with ChangeNotifier {

  final Mutex _mutex = Mutex();

  final String settingFileName = 'setting.conf';
  List<String> urpFileNames = [];
  List<bool> isBeerReady = [true, true, true];
  bool isPowerOnTimeOut = false;
  bool isBrakeReleaseTimeOut = false;
  bool isTimerStart = false;
  bool isPlayingProgram = false;
  // 홈 버튼을 길게 눌렀다가 뗏을 때 바뀌는 값
  bool isPausing = false;

  //final String ip = '220.81.122.102';
  //final int port = 54662;
  final String ip = '192.168.0.29';
  final int port = 29999;

  Socket? _socket;

  RobotMode robotModeData = RobotMode.DISCONNECTED;
  SafetyStatus safetyStatusData = SafetyStatus.NORMAL;
  CurrentProgramState currentProgramState = CurrentProgramState.STOPPED;
  CurrentCommandState currentCommandState = CurrentCommandState.NONE;

  String sendMessage = '';
  String logData = '';
  String commandReplyData = '';
  String commandString = '';

  bool isConnected = false;
  bool connectionFail = false;
  bool disconnect = false;
  bool isLocalControlMode = false;
  bool isSafetyError = false;

  late File settingFile;

  // 현재 작업 (0~3: 대기중, 1잔, 2잔, 3잔)
  int currentTaskNum = 0;

  int commandError = 0;

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
      FileManager fileManager = FileManager(settingFileName);

      final String config = await fileManager.readFile();

      if(config.isEmpty){
        urpFileNames.addAll(urpFileNames);
      }
      urpFileNames = config.split('\n');
    } catch (e) {
      throw Exception("Error loading setting.conf: $e");
    }
    notifyListeners();
  }

  void initStateByError(){
    setCurrentCommandState(CurrentCommandState.NONE);
    currentTaskNum = 0;
  }

  Future<void> saveUrpPath() async {

    FileManager fileManager = FileManager(settingFileName);

    String content = '';

    for(String path in urpFileNames){
      content += path;
      content += '\n';
    }

    fileManager.modifyFile(content);
  }

  Future<bool> connectRobot() async {
    connectionFail = false;
    disconnect = false;

    try {
      print('[LOG]Trying to connect to $ip:$port');
      _socket = await Socket.connect(ip, port).timeout(const Duration(seconds: 5));
      print('[LOG]Connection established');
      isConnected = true;

      _socket!.listen((data) {
        onServerResponse(String.fromCharCodes(data));
      }, onError: (error) {
        print('[LOG]Data error: $error');
      }, onDone: () {
        // 연결 끊기면 팝업창
        print('[LOG]Connection closed by server');
        _disconnectFromServer();
      });

      if(isConnected) {
        startPeriodicCommand();
        return true;
      }
    } catch (e) {
      // 연결 실패 시 팝업창
      print('[LOG]Connection failed: $e');
      connectionFail = true;
      notifyListeners();
    }
    return false;
  }

  // 1초마다 로봇상태와 안전상태 확인 명령어를 보냄
  void startPeriodicCommand() {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      if(isConnected) {
        await _sendCommand(Command.ROBOT_MODE);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if(isConnected){
        await _sendCommand(Command.SAFETY_STATUS);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (currentTaskNum != 0 && isPlayingProgram){
        await _sendCommand(Command.PROGRAM_STATE);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    });
  }

  Future<void> startTimeOutListener(int second, Command command) async{

    await Future.delayed(Duration(seconds: second));

    if(isTimerStart){
      if(command == Command.POWER_ON && currentCommandState == CurrentCommandState.POWERING_ON){
        isPowerOnTimeOut = true;
      }
      else if(command == Command.BRAKE_RELEASING && command == Command.POWER_ON && currentCommandState == CurrentCommandState.BRAKE_RELEASING){
        isBrakeReleaseTimeOut = true;
      }
    }
  }

  // 
  Future<void> _sendCommand(Command command, {String fileName = ''}) async {
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

    if(command==Command.POWER_OFF){
      // 버튼 명령어 전송
      await _sendCommand(command);
    }
    else {
      // 버튼 제어 가능 상태인지 확인
      if(!currentCommandState.available){
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
            await _sendOrderCommand(0);
            break;
          case Command.ORDER_TWO:
            // await _sendOrderCommand(1);
            await _sendOrderCommand(1);
            break;
          case Command.ORDER_THREE:
            // await _sendOrderCommand(2);
            await _sendOrderCommand(2);
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
      
    }
    
    notifyListeners();
    // 잠시 대기 후 주기적인 명령어 전송 재개
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> onServerResponse(String response) async {
    commandReplyData = response.replaceFirst('\n', ' ');

    // 원격 제어 모드가 아닐 경우 응답
    if (commandReplyData.contains('Command is not allowed')){
      isLocalControlMode = true;
      notifyListeners();
    }

    // 로봇모드 확인 명령어 응답
    if (commandReplyData.toLowerCase().contains(Command.ROBOT_MODE.command)){
      robotModeData = RobotMode.getRobotModeByString(commandReplyData);

      if(currentCommandState == CurrentCommandState.POWERING_ON){
        if(!isTimerStart) {
          isTimerStart = true;
          startTimeOutListener(15, Command.POWER_ON);
        }
          
        if (commandReplyData.contains(RobotMode.IDLE.value)){
          await _sendCommand(Command.BRAKE_RELEASING);
          setCurrentCommandState(CurrentCommandState.BRAKE_RELEASING);
        }

        // 시간 초과
        else if(isPowerOnTimeOut){
          logData = '[error] powering on 시간초과. 다시 시도해주세요.';

          notifyListeners();

          setCurrentCommandState(CurrentCommandState.NONE);
          isPowerOnTimeOut = false;
          isTimerStart = false;
        }
        // else{
        //   await _sendCommand(Command.ROBOT_MODE);
        // }
        notifyListeners();
      }
      
      else if(currentCommandState == CurrentCommandState.BRAKE_RELEASING){
        if(!isTimerStart) {
          isTimerStart = true;
          startTimeOutListener(15, Command.BRAKE_RELEASING);
        }

        if (commandReplyData.contains(RobotMode.RUNNING.value)){
          logData = '[log] power on 명령 완료.';
          setCurrentCommandState(CurrentCommandState.NONE);

        }
        else if(isBrakeReleaseTimeOut){
          logData = '[error] brake release 시간초과. 다시 시도해주세요.';
          setCurrentCommandState(CurrentCommandState.NONE);

          notifyListeners();

          isBrakeReleaseTimeOut = false;
          isTimerStart = false;
        }
        // 시간 초과
        // else if(isTimeOut){
        //   logData = '[error] powering on 시간초과. 다시 시도해주세요.';
        //   setCurrentCommandState(CurrentCommandState.NONE);
        //   startPeriodicCommand();
        //   isTimeOut = false;
        //   isTimerStart = false;
        // }
        
        notifyListeners();
      }
    }
    // 안전상태 확인 명령어 응답
    if (commandReplyData.toLowerCase().contains(Command.SAFETY_STATUS.command)){
      safetyStatusData = SafetyStatus.getSafetyStatusByString(commandReplyData);

      if(safetyStatusData != SafetyStatus.NORMAL){

      }
    }

    // 프로그램 시작 응답
    if (commandReplyData.contains("Starting program")){
      isPlayingProgram = true;
      if(currentTaskNum==4){
        setCurrentCommandState(CurrentCommandState.GOING_HOME);
      }
      else{
        setCurrentCommandState(CurrentCommandState.PLAYING);
      }
    }
    // Puase 명령어 응답
    if (commandReplyData.contains("Pausing program")){
      if(currentCommandState == CurrentCommandState.GOING_HOME){
        logData = '[log] pause 명령어 성공.';
        setCurrentCommandState(CurrentCommandState.PAUSING);
        notifyListeners();
      }
    }

    // 프로그램 상태 명령어 확인 응답
    if (containsSubstring(commandReplyData, CurrentProgramState.toList())){
      currentProgramState = CurrentProgramState.getCurrentProgramStateByString(commandReplyData);

      if (currentProgramState==CurrentProgramState.STOPPED && isPlayingProgram){
        
        currentTaskNum = 0;
        setCurrentCommandState(CurrentCommandState.NONE);
        isPlayingProgram = false;
      }
    }
    // LOAD 명령어 응답
    if (commandReplyData.toLowerCase().contains(Command.LOAD.command)){
      if (!commandReplyData.contains(Command.LOAD.success)){
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
      else{
        setCurrentCommandState(CurrentCommandState.LOADING);
        await _sendCommand(Command.PLAY);
      }
    }
    // PLAY 명령어 응답
    if (commandReplyData.toLowerCase().contains(Command.PLAY.command)){
      if (commandReplyData.contains(Command.PLAY.failure)){
        if(currentTaskNum != 4){
          logData = '[error] play 명령어 실패 / $commandReplyData';
          currentProgramState = CurrentProgramState.ERROR;
        }
        else{
          logData = '[error] go home 명령어 실패 / $commandReplyData';
          currentProgramState = CurrentProgramState.ERROR;
        }
        setCurrentCommandState(CurrentCommandState.NONE);
        currentTaskNum = 0;
        notifyListeners();
        return;
      }

      logData = '[log] play 명령어 성공';
      notifyListeners();
    }

    // POWER ON 명령어 응답
    if (commandReplyData.toLowerCase().contains(Command.POWER_ON.command)){
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
    notifyListeners();

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

  Future<void> _sendGoHomeCommand() async{
    // 이전 작업이 홈 이동이 아닐 때, urp 로드
    if (currentProgramState == CurrentProgramState.STOPPED && currentTaskNum == 0){
      await _sendCommand(Command.LOAD, fileName: urpFileNames[7]);
      currentTaskNum = 4;
      notifyListeners();
    }
    else if(currentCommandState == CurrentCommandState.PAUSING){
      await _sendCommand(Command.PLAY);
    }
  }

  Future<void> _sendPauseGoHomeCommand() async{
    if (currentProgramState == CurrentProgramState.PLAYING){
      await _sendCommand(Command.PAUSE);
    }
  }


  Future<void> _sendPowerOnCommand() async{

    await _sendCommand(Command.POWER_ON);
    setCurrentCommandState(CurrentCommandState.POWERING_ON);
  }

  void _disconnectFromServer() {
    isConnected = false;
    disconnect = true;
    robotModeData = RobotMode.DISCONNECTED;

    timer?.cancel();
    notifyListeners();

    if (_socket != null) {
      _socket!.destroy();
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


  void setIsPausing(bool p){
    isPausing = p;
    notifyListeners();
  }
}