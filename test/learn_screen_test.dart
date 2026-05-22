import 'package:dna/screens/guide_details_screen.dart';
import 'package:dna/screens/learn_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Learn screen renders guides and media tabs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LearnScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Guides'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('GenoScene Project Idea'), findsOneWidget);

    await tester.tap(find.text('Media'));
    await tester.pumpAndSettle();

    expect(find.text('What GenoScene Does'), findsOneWidget);
    expect(find.text('GenoScene Workflow'), findsOneWidget);
    expect(find.text('SNPs to Visible Traits'), findsOneWidget);
    expect(find.text('Forensic Support'), findsOneWidget);
  });

  testWidgets('Guide details supports next and previous navigation',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GuideDetailsScreen(currentIndex: 0)),
    );
    await tester.pumpAndSettle();

    expect(find.text('GenoScene Project Idea'), findsOneWidget);
    expect(find.text('1 of 8'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('What is DNA Phenotyping?'), findsOneWidget);
    expect(find.text('2 of 8'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);

    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();

    expect(find.text('GenoScene Project Idea'), findsOneWidget);
    expect(find.text('1 of 8'), findsOneWidget);
  });
}
