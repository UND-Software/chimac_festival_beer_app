import 'dart:async';

import 'package:chimaek_festival/screens/splash_screen.dart';
import 'package:chimaek_festival/screens/widgets/popup_alarm.dart';
import 'package:chimaek_festival/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chimaek_festival/screens/main_screen.dart'; // 위의 코드가 main.dart 파일에 있다고 가정
import 'package:chimaek_festival/providers/command_provider.dart';

void main() {
  testWidgets('Test button press based on provider state', (WidgetTester orderTester) async {
    await orderTester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CommandProvider(),
        child: MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    await orderTester.pump(const Duration(seconds: 10));
    await orderTester.pumpAndSettle();

    final powerOnBtnFinder = find.byKey(const Key('power on btn'));
    final orderBtnFinder = find.byKey(const Key('order btn'));
    final confirmBtnFinder = find.byKey(const Key('popup confirm btn'));
    print('find btn widgets!');

    // Helper function to wait until the provider state is a specific value
    Future<void> waitForPowerState(WidgetTester tester, RobotMode desiredState, Duration timeout) async {
      bool isTimeout = false;
      await Future.any([
        Future.delayed(timeout).then((_) {
          isTimeout = true;
        }),
        Future.doWhile(() async {
          if (isTimeout) {
            return false;
          }
          if (Provider.of<CommandProvider>(tester.element(find.byType(MainScreen)), listen: false).robotModeData == desiredState) {
            return false;
          }
          await tester.pump();
          return true;
        })
      ]);
      if (isTimeout) {
        throw TimeoutException('[error] State did not reach [$desiredState] within $timeout');
      }
    }

    Future<void> waitForTaskState(WidgetTester tester, int desiredState, Duration timeout) async {
      bool isTimeout = false;
      await Future.any([
        Future.delayed(timeout).then((_) {
          isTimeout = true;
        }),
        Future.doWhile(() async {
          if (isTimeout) {
            return false;
          }
          if (Provider.of<CommandProvider>(tester.element(find.byType(MainScreen)), listen: false).currentTaskNum == desiredState) {
            return false;
          }
          await tester.pump();
          return true;
        })
      ]);
      if (isTimeout) {
        throw TimeoutException('[error] State did not reach [$desiredState] within $timeout');
      }
    }

    await orderTester.tap(powerOnBtnFinder);
    
      // Wait until the popup appears
    print('waiting popup...');
    expect(find.text('확인'), findsOneWidget);  
    print('find popup window!');
      // Press the confirm button on the popup
    await orderTester.tap(confirmBtnFinder);
    await orderTester.pumpAndSettle();

    print('power on..');
    

    await waitForPowerState(orderTester, RobotMode.RUNNING, const Duration(seconds: 10));
    print('power on complete!');

    final cp = Provider.of<CommandProvider>(orderTester.element(find.byType(MainScreen)), listen: false);

    // Repeat the process 5 times for demonstration purposes
    for (int i = 1; i <= 10; i++) {
      // Wait until the state is 'a'
      await waitForTaskState(orderTester, 0, const Duration(seconds: 5));

      // Press Button A
      await orderTester.tap(orderBtnFinder);
      await orderTester.pumpAndSettle();

      // Wait until the popup appears
      expect(find.text('확인'), findsOneWidget);

      // Press the confirm button on the popup
      await orderTester.tap(confirmBtnFinder);
      await orderTester.pumpAndSettle();

      await waitForTaskState(orderTester, 1, Duration(seconds: 10));

      if (cp.logData.toLowerCase().contains('fail')) {
        print('$i : [error] ${cp.logData}');
      }

      print('실행 횟수 : $i');
    }

    // Verify the state at the end
    // expect(Provider.of<MyProvider>(tester.element(find.byType(MyHomePage)), listen: false).state, 'a');
  });
}
