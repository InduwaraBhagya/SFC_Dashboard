// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:sfc_dashboard/PlannedEvent/PlannedEventMain.dart';
// import 'package:sfc_dashboard/ServiceOrder/ServiceOrderMain.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     // await tester.pumpWidget(const PlannedEventMain(userId: 1));
//     // await tester.pumpWidget(const ServiceOrderMain());
//     await tester.pumpWidget(
//       MaterialApp(
//         home: PlannedEventMain(userId: 1),
//       ),
//     );
//     await tester.pumpWidget(
//       MaterialApp(
//         home: ServiceOrderMain(),
//       ),
//     );
//     // Verify that our counter starts at 0.
//     //expect(find.text('0'), findsOneWidget);
//     //expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     //await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sfc_dashboard/PlannedEvent/PlannedEventMain.dart';

void main() {
  testWidgets('PlannedEventMain loads successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
<<<<<<< HEAD
      const MaterialApp(
=======
      MaterialApp(
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
        home: PlannedEventMain(
          userId: 1,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets);
  });
}
