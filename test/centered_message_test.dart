import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/widgets/centered_message.dart';

Widget makeTestableWidget({required Widget child}) {
  return MaterialApp(home: Scaffold(body: child));
}

Future<void> showCenteredMessage(
  WidgetTester tester, {
  required String buttonText,
  required String message,
  CenteredMessageType type = CenteredMessageType.success,
  IconData? icon,
}) async {
  await tester.pumpWidget(
    makeTestableWidget(
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              CenteredMessage.show(
                context,
                message,
                type: type,
                icon: icon,
                duration: const Duration(milliseconds: 10),
              );
            },
            child: Text(buttonText),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text(buttonText));
  await tester.pump();

  expect(find.text(message), findsOneWidget);
}

Future<void> finishCenteredMessageTimer(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump();
}

void main() {
  testWidgets('mostra un missatge de success per defecte', (tester) async {
    await showCenteredMessage(
      tester,
      buttonText: 'Mostrar missatge',
      message: 'Operació correcta',
    );

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await finishCenteredMessageTimer(tester);

    expect(find.text('Operació correcta'), findsNothing);
  });

  testWidgets('mostra un missatge d’error amb la icona correcta', (
    tester,
  ) async {
    await showCenteredMessage(
      tester,
      buttonText: 'Mostrar error',
      message: 'Hi ha hagut un error',
      type: CenteredMessageType.error,
    );

    expect(find.byIcon(Icons.error_rounded), findsOneWidget);

    await finishCenteredMessageTimer(tester);

    expect(find.text('Hi ha hagut un error'), findsNothing);
  });

  testWidgets('mostra un missatge de warning amb la icona correcta', (
    tester,
  ) async {
    await showCenteredMessage(
      tester,
      buttonText: 'Mostrar warning',
      message: 'Atenció',
      type: CenteredMessageType.warning,
    );

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    await finishCenteredMessageTimer(tester);

    expect(find.text('Atenció'), findsNothing);
  });

  testWidgets('mostra un missatge informatiu amb la icona correcta', (
    tester,
  ) async {
    await showCenteredMessage(
      tester,
      buttonText: 'Mostrar info',
      message: 'Informació important',
      type: CenteredMessageType.info,
    );

    expect(find.byIcon(Icons.info_rounded), findsOneWidget);

    await finishCenteredMessageTimer(tester);

    expect(find.text('Informació important'), findsNothing);
  });

  testWidgets('permet passar una icona personalitzada', (tester) async {
    await showCenteredMessage(
      tester,
      buttonText: 'Mostrar custom',
      message: 'Missatge amb icona custom',
      icon: Icons.star,
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    await finishCenteredMessageTimer(tester);

    expect(find.text('Missatge amb icona custom'), findsNothing);
  });

  testWidgets('el missatge desapareix després de la duració indicada', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeTestableWidget(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CenteredMessage.show(
                  context,
                  'Missatge temporal',
                  duration: const Duration(milliseconds: 500),
                );
              },
              child: const Text('Mostrar temporal'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Mostrar temporal'));
    await tester.pump();

    expect(find.text('Missatge temporal'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('Missatge temporal'), findsNothing);
  });

  testWidgets('mostra el fons enfosquit darrere del missatge', (tester) async {
    await showCenteredMessage(
      tester,
      buttonText: 'Mostrar overlay',
      message: 'Missatge amb overlay',
    );

    expect(find.text('Missatge amb overlay'), findsOneWidget);
    expect(find.byType(Positioned), findsWidgets);
    expect(find.byType(Stack), findsWidgets);

    await finishCenteredMessageTimer(tester);

    expect(find.text('Missatge amb overlay'), findsNothing);
  });
}
