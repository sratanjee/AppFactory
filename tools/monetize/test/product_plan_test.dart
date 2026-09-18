import 'package:monetize/product_plan.dart';
import 'package:scaffold/spec.dart';
import 'package:test/test.dart';

Spec _make({
  String weeklyPrice = '',
  String annualPrice = '',
  String lifetimePrice = '',
  String freeTrial = 'none',
}) => Spec(
      appName: 'Test',
      iosSubtitle: '',
      androidShortDescription: '',
      slug: 'test-app',
      bundleIdRaw: 'com.appfactory.testapp',
      storeCategory: '',
      developerAccount: 'A',
      factoryCategory: 'utility',
      job: '',
      who: '',
      where: '',
      whyPay: '',
      screens: const [],
      dataModelRaw: '',
      backendMode: 'no',
      syncMode: 'none',
      nativeSurfaces: NativeSurfacesSpec(
        homeWidget: false,
        lockScreenOrGlance: false,
        liveActivityOrOngoing: false,
        watchOrWearTile: false,
        camera: false,
        notifications: false,
        shareExtension: false,
        appIntents: false,
      ),
      monetization: MonetizationSpec(
        paywallPlacement: '',
        freeTrial: freeTrial,
        weeklyPrice: weeklyPrice,
        annualPrice: annualPrice,
        lifetimePrice: lifetimePrice,
        revenueCatEntitlement: 'pro',
        gatedVsFree: '',
        benefits: const [],
      ),
      onboardingSteps: const [],
      designNotes: DesignNotesSpec(
        accentHex: '',
        iconConcept: '',
        toneOfCopy: '',
        differsFromSiblings: '',
      ),
      storeSeeds: StoreSeedsSpec(
        primaryKeyword: '',
        secondaryKeywords: const [],
        screenshotStory: const [],
      ),
      outOfScope: const [],
      doneChecks: const [],
    );

void main() {
  test('all-three spec (wash-quote shape) produces monthly + annual + lifetime', () {
    final plan = ProductPlan.fromSpec(_make(
      weeklyPrice: r'none (monthly instead: $9.99/mo)',
      annualPrice: r'$59.99/yr (pre-selected, saving shown against monthly)',
      lifetimePrice: r'$79 one-time (third option)',
      freeTrial: '7-day, on annual only',
    ));
    expect(plan.products.map((p) => p.rcPackageId), [
      r'$rc_monthly',
      r'$rc_annual',
      r'$rc_lifetime',
    ]);
    final annual = plan.products.firstWhere(
      (p) => p.rcPackageId == r'$rc_annual',
    );
    expect(annual.freeTrialDays, 7);
    expect(annual.priceUsd, 59.99);
    expect(plan.products.last.priceUsd, 79.0);
    expect(plan.products.last.kind, ProductKind.nonConsumable);
  });

  test('kidney-care shape produces annual + lifetime, no monthly', () {
    final plan = ProductPlan.fromSpec(_make(
      weeklyPrice: 'none (no monthly tier either)',
      annualPrice: r'$29.99/yr',
      lifetimePrice: r'$49.99 one-time',
      freeTrial: '7-day, on annual only',
    ));
    expect(plan.products.map((p) => p.rcPackageId), [
      r'$rc_annual',
      r'$rc_lifetime',
    ]);
  });

  test('schedule-e shape produces lifetime only, no trial', () {
    final plan = ProductPlan.fromSpec(_make(
      weeklyPrice: 'none',
      annualPrice: 'none in v1',
      lifetimePrice: r'$39.99 one-time (the only option on the v1 paywall)',
      freeTrial: 'none',
    ));
    expect(plan.products, hasLength(1));
    expect(plan.products.single.rcPackageId, r'$rc_lifetime');
    expect(plan.products.single.freeTrialDays, 0);
  });

  test('trucker-log provisional annual, no lifetime', () {
    final plan = ProductPlan.fromSpec(_make(
      weeklyPrice: r'none (monthly instead: $12.99/mo, provisional)',
      annualPrice: r'$99.99/yr (pre-selected)',
      lifetimePrice: 'none in v1',
      freeTrial: '7-day, on annual only',
    ));
    expect(plan.products.map((p) => p.rcPackageId), [
      r'$rc_monthly',
      r'$rc_annual',
    ]);
  });
}
