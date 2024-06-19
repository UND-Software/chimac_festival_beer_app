


// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum Command{
  POWER_ON(id:0, command: 'power on', success:"Powering on", failure:""),
  BRAKE_RELEASING(id:1, command: 'brake release', success:"Brake releasing", failure:""),
  POWER_OFF(id:2, command: 'power off', success: "Powering off" , failure:""),
  LOAD(id:3, command: 'load', success:"Loading program:", failure:""),
  GET_LOAD(id:3, command: 'load', success:"Loading program:", failure:""),
  PLAY(id:4, command: 'play', success:"Starting program", failure:"Failed to execute:play"),
  PAUSE(id:5, command: 'pause', success: "Pausing program", failure: "Failed to execute:pause"),
  STOP(id:6, command: 'stop', success: "Stopped", failure: "Failed to execute:stop"),
  SHUTDOWN(id:7, command: 'shutdown', success: "Shuttingdown", failure: ""),
  ROBOT_MODE(id:8, command: 'robotmode', success:"", failure:""),
  SAFETY_STATUS(id:9, command: 'safetystatus', success:"", failure:""),
  PROGRAM_STATE(id:10, command: 'programState', success:"", failure:""),

  ORDER_ONE(id:11, command: 'order 1', success:"", failure:""),
  ORDER_TWO(id:12, command: 'order 2', success:"", failure:""),
  ORDER_THREE(id:13, command: 'order 3', success:"", failure:""),
  GO_HOME(id:14, command: 'go home', success:"", failure:"");
  
  const Command({
    required this.id,
    required this.command,
    required this.success,
    required this.failure
  });

  final int id;
  final String command;
  final String success;
  final String failure;
}

enum RobotMode{
  ERROR(id:-1, ko:'에러', value : 'ERROR', color : Colors.red),
  NO_CONTROLLER(id:0, ko:'컨트롤러 없음', value : 'NO_CONTROLLER', color : Colors.red),
  DISCONNECTED(id:1, ko:'연결 끊김', value : 'DISCONNECTED', color : Colors.red),
  CONFIRM_SAFETY(id:2, ko:'안전 확인', value : 'CONFIRM_SAFETY', color : Colors.red),
  BOOTING(id:3, ko:'부팅 중', value : 'BOOTING', color : Colors.yellow),
  POWER_OFF(id:4, ko:'전원 꺼짐', value : 'POWER_OFF', color : Colors.yellow),
  POWER_ON(id:5, ko:'전원 켜짐', value : 'POWER_ON', color : Colors.green),
  IDLE(id:6, ko:'로봇 유휴', value : 'IDLE', color : Colors.yellow),
  BACKDRIVE(id:7, ko:'백드라이브', value : 'BACKDRIVE', color : Colors.black),
  RUNNING(id:8, ko:'작동 중', value : 'RUNNING', color : Colors.green);

  const RobotMode({
    required this.id,
    required this.ko,
    required this.value,
    required this.color
  });

  final int id;
  final String ko;
  final String value;
  final Color color;

  static RobotMode getRobotModeByString(String value){
    for(RobotMode robotMode in RobotMode.values){
      if (robotMode.value.compareTo(value)==0){
        return robotMode;
      }
    }
    return RobotMode.ERROR;
  }
}

enum SafetyStatus{
  ERROR(id:-1, ko:'에러', value : 'ERROR', color : Colors.red),
  NORMAL(id:0, ko:'정상', value:'NORMAL', color : Colors.green),
  REDUCED(id:1, ko:'성능 제한', value:'REDUCED', color : Colors.yellow),
  PROTECTIVE_STOP(id:2, ko:'PROTECTIVE_STOP', value:'PROTECTIVE_STOP', color : Colors.red),
  RECOVERY(id:3, ko:'복구', value:'RECOVERY', color : Colors.yellow),
  SAFEGUARD_STOP(id:4, ko:'SAFEGUARD_STOP', value:'SAFEGUARD_STOP', color : Colors.red),
  SYSTEM_EMERGENCY_STOP(id:5, ko:'시스템 긴급 정지', value:'SYSTEM_EMERGENCY_STOP', color : Colors.red),
  ROBOT_EMERGENCY_STOP(id:5, ko:'로봇 긴급 정지', value:'ROBOT_EMERGENCY_STOP', color : Colors.red),
  VIOLATION(id:6, ko:'제한 위반', value:'VIOLATION', color : Colors.red),
  FAULT(id:7, ko:'오류', value:'FAULT', color : Colors.red),
  AUTOMATIC_MODE_SAFEGUARD_STOP(id:8, ko:'AUTOMATIC_MODE_SAFEGUARD_STOP', value:'AUTOMATIC_MODE_SAFEGUARD_STOP', color : Colors.red),
  SYSTEM_THREE_POSITION_ENABLING_STOP(id:9, ko:'SYSTEM_THREE_POSITION_ENABLING_STOP', value:'SYSTEM_THREE_POSITION_ENABLING_STOP', color : Colors.red);

  const SafetyStatus({
    required this.id,
    required this.ko,
    required this.value,
    required this.color
  });

  final int id;
  final String ko;
  final String value;
  final Color color;

  static SafetyStatus getSafetyStatusByString(String value){
    for(SafetyStatus safetyStatus in SafetyStatus.values){
      if (safetyStatus.value.compareTo(value)==0){
        return safetyStatus;
      }
    }
    return SafetyStatus.ERROR;
  }
}

enum CurrentTaskState{
  ERROR(id:-1, ko:'에러', value : 'ERROR'),
  STOP(id:0, ko:'대기 중', value : 'STOP'),
  PLAYING(id:1, ko:'동작 중', value : 'PLAYING'),
  PAUSED(id:2, ko:'대기 중', value: 'PAUSED');

  const CurrentTaskState({
    required this.id,
    required this.ko,
    required this.value
  });

  final int id;
  final String ko;
  final String value;

  static CurrentTaskState getCurrentTaskStateByString(String value){
    for(CurrentTaskState currentTaskState in CurrentTaskState.values){
      if (currentTaskState.value.compareTo(value)==0){
        return currentTaskState;
      }
    }
    return CurrentTaskState.ERROR;
  }
}

enum PopUpData{
  CHECK_ONE(title : '주문 확인', body : '맥주 1잔 주문 맞나요?'),
  CHECK_TWO(title : '주문 확인', body : '맥주 2잔 주문 맞나요?'),
  CHECK_THREE(title : '주문 확인', body : '맥주 3잔 주문 맞나요?'),
  CHECK_CONNECT(title : '연결 확인', body : '로봇과 연결되지 않았습니다. 확인 부탁드립니다.'),
  ALARM_DISCONNECT(title : '연결 끊김', body : '로봇과 연결이 끊겼습니다. 다시 연결해주세요.'),
  CHECK_ERROR(title : '에러 발생', body : '확인 부탁드립니다.');

  const PopUpData({
    required this.title,
    required this.body
  });

  final String title;
  final String body;
    
}