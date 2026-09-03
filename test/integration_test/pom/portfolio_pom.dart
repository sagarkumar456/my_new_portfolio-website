import 'package:flutter_test/flutter_test.dart';

class PortfolioPagePOM {
  final WidgetTester tester;

  PortfolioPagePOM(this.tester);

  // -- Locators --
  Finder get loginBtn => find.text('LOGIN');
  Finder get registerBtn => find.text('REGISTER');
  Finder get emailBtn => find.text('EMAIL ME');
  Finder get downloadResumeBtn => find.textContaining('DOWNLOAD RESUME');
  
  // Section Headers
  Finder get profileSummarySection => find.text('Profile Summary');
  Finder get experienceSection => find.text('Professional Experience');

  // -- Actions --
  Future<void> clickLogin() async {
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();
  }

  Future<void> scrollToExperience() async {
    await tester.ensureVisible(experienceSection);
    await tester.pumpAndSettle();
  }

  Future<void> verifyResumeButtonVisible() async {
    expect(downloadResumeBtn, findsOneWidget, reason: 'Resume button missing');
  }
}