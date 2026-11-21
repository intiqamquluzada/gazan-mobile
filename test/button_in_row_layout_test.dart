import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/core/theme/app_theme.dart';
import 'package:qazan/features/business/domain/panel_models.dart';
import 'package:qazan/features/business/presentation/spend_customer_window.dart';

/// The app theme gives buttons an infinite minimum width (full-width pills).
/// A themed button placed straight in a Row therefore cannot be laid out and
/// the whole row breaks — this is what broke the cashier "gifts" screen.
void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  testWidgets('a themed button without a size override breaks a Row',
      (WidgetTester tester) async {
    final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
    final void Function(FlutterErrorDetails)? previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await tester.pumpWidget(host(Row(children: <Widget>[
        const Expanded(child: Text('Müştəri')),
        FilledButton(onPressed: () {}, child: const Text('Ver')),
      ])));
    } finally {
      FlutterError.onError = previous;
    }
    expect(errors, isNotEmpty);
    expect(errors.first.exceptionAsString(), contains('BoxConstraints'));
  });

  testWidgets('the content-sized override lays out inside a Row',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(Row(children: <Widget>[
      const Expanded(child: Text('Müştəri')),
      FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
        onPressed: () {},
        child: const Text('Ver'),
      ),
    ])));
    expect(tester.takeException(), isNull);
    expect(find.text('Ver'), findsOneWidget);
  });

  testWidgets('the cashier customer window renders its rewards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const SpendSession session = SpendSession(
      id: 's1',
      customerId: 'u1',
      customerName: 'Aysel Məmmədova',
      coinBalance: 450,
      cards: <SpendCard>[
        SpendCard(
            programTitle: '5 qəhvəyə 1 hədiyyə',
            stamps: 5,
            stampsRequired: 5,
            rewardsAvailable: 1),
      ],
      rewards: <SpendReward>[
        SpendReward(kind: 'CARD', id: 'c1', title: 'Pulsuz qəhvə', coinCost: 0),
        SpendReward(kind: 'COIN', id: 'r1', title: 'Desert', coinCost: 200),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showSpendCustomerWindow(context, session),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Pulsuz qəhvə'), findsOneWidget);
    expect(find.byType(FilledButton), findsNWidgets(2));
  });
}
