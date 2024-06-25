// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:test/test.dart';

// void main() {
//   group('App Test', () {



//     late FlutterDriver driver;

//     setUpAll(() async {
//       driver = await FlutterDriver.connect();
//     });

//     tearDownAll(() async {
//       driver.close();
//         });

//     test('navigate to second page and perform actions', () async {
//     // Wait for splash screen duration
//     await orderTester.pump(const Duration(seconds: 10));
//     await orderTester.pumpAndSettle();

//     final powerOnBtnFinder = find.byKey(const Key('power on btn'));
//     final orderBtnFinder = find.byKey(const Key('ordert btn'));
//     final confirmBtnFinder = find.byKey(const Key('popup confirm btn'));

//     // Helper function to wait until the provider state is a specific value
//     Future<void> waitForPowerState(WidgetTester tester, RobotMode desiredState) async {
//       while (Provider.of<CommandProvider>(tester.element(find.byType(MainScreen)), listen: false).robotModeData != desiredState) {
//         await tester.pump();
//       }
//     }

//     Future<void> waitForTaskState(WidgetTester tester, int desiredState) async {
//       while (Provider.of<CommandProvider>(tester.element(find.byType(MainScreen)), listen: false).currentTaskNum != desiredState) {
//         await tester.pump();
//       }
//     }

//     await orderTester.tap(powerOnBtnFinder);
//     await waitForPowerState(orderTester, RobotMode.RUNNING);

//     // Repeat the process 5 times for demonstration purposes
//     for (int i = 0; i < 10; i++) {
//       // Wait until the state is 'a'
//       await waitForTaskState(orderTester, 0);

//       // Press Button A
//       await orderTester.tap(orderBtnFinder);
//       await orderTester.pumpAndSettle();

//       // Wait until the popup appears
//       expect(find.text('확인'), findsOneWidget);

//       // Press the confirm button on the popup
//       await orderTester.tap(confirmBtnFinder);
//       await orderTester.pumpAndSettle();

//       // Wait until the state is 'a' again
//       await waitForTaskState(orderTester, 1);
//     }
//       // Perform actions on the second page
//       for (int i = 0; i < 5; i++) {
//         await driver.waitFor(buttonA);
//         await driver.tap(buttonA);

//         await driver.waitFor(find.text('Popup!'));
//         await driver.tap(confirmButton);

//         // Optional: Check the provider state if needed
//         // (requires a custom finder or text widget with the state)
//       }
//     });
//   });
// }
