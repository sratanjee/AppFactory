/// All English-facing strings for Wash Quote & Invoice.
///
/// Kept as static consts so widgets pull from one place. Localization to
/// other languages is out of scope for v1; adding a locale means moving
/// these into an ARB file and switching to gen-l10n.
abstract final class AppStrings {
  // Tabs.
  static const tabJobs = 'Jobs';
  static const tabCustomers = 'Customers';
  static const tabServices = 'Services';
  static const tabMoney = 'Money';

  // Jobs screen.
  static const jobsTitle = 'Jobs';
  static const jobsSegmentQuotes = 'Quotes';
  static const jobsSegmentInvoices = 'Invoices';
  static const jobsHeroHeadline = 'New quote from the driveway';
  static const jobsHeroSubline =
      'Snap the surface, pick a service, send the PDF';
  static const jobsWaitingHeader = 'Waiting on the customer';
  static const jobsAcceptedHeader = 'Accepted this week';
  static const jobsEmptyHint = 'No quotes yet. Snap the driveway and price it.';
  static const jobsErrorRead =
      "Can't open your jobs. Force-quit and reopen.";
  static const jobsStatusSent = 'Sent';
  static const jobsStatusAccepted = 'Accepted';
  static const jobsStatusInvoiced = 'Invoiced';
  static const jobsStatusPaid = 'Paid';
  static const jobsStatusQuote = 'Quote';

  // Quote builder.
  static const builderTitle = 'New quote';
  static const builderCustomer = 'Customer';
  static const builderCustomerPick = 'Tap to pick or add';
  static const builderLines = 'Service lines';
  static const builderAddLine = 'Add service line';
  static const builderQtyLabel = 'Qty';
  static const builderTotalLabel = 'Total';
  static const builderDepositLabel = 'Deposit';
  static const builderPayVia = 'Pay via';
  static const builderBeforePhotos = 'Before photos';
  static const builderAddPhoto = 'Add photo';
  static const builderSave = 'Save quote';
  static const builderEmptyServices =
      'Add a service to start. Uses your prices.';
  static const builderEmptyServicesLink = 'Open Services';
  static const builderErrorSave = "Couldn't save. Try again.";
  static const builderNoCustomer = 'No customer';

  // Customer sheet.
  static const customerSheetTitle = 'Customer';
  static const customerName = 'Name';
  static const customerPhone = 'Phone';
  static const customerEmail = 'Email';
  static const customerAddress = 'Address';
  static const customerSave = 'Save customer';
  static const customerPickExisting = 'Pick an existing customer';
  static const customerAddNew = 'Add new customer';

  // Job detail.
  static const jobDetailTitle = 'Job';
  static const jobDetailSendPdf = 'Send PDF';
  static const jobDetailConvertInvoice = 'Convert to invoice';
  static const jobDetailAddAfterPhotos = 'Add after photos';
  static const jobDetailDepositLink = 'Deposit link';
  static const jobDetailMarkAccepted = 'Mark accepted';
  static const jobDetailMarkPaid = 'Mark paid';
  static const jobDetailDepositLinkError =
      "Deposit link didn't create. Send the PDF and try again.";
  static const jobDetailDepositLinkCreating = 'Creating deposit link';
  static const jobDetailDepositLinkReady = 'Deposit link ready';
  static const jobDetailPdfMissing = 'Add after photos';

  // Services.
  static const servicesTitle = 'Services';
  static const servicesAdd = 'Add service';
  static const servicesEmpty =
      'Add what you charge for. House soft wash, driveway, roof, deck.';
  static const servicesErrorSave = "Couldn't save that service.";
  static const servicesUnitSqft = 'per sq ft';
  static const servicesUnitLinft = 'per lin ft';
  static const servicesUnitFlat = 'flat';
  static const servicesUnitHour = 'per hour';
  static const servicesName = 'Service name';
  static const servicesUnit = 'Unit';
  static const servicesUnitPrice = 'Unit price';

  // Money.
  static const moneyTitle = 'Money';
  static const moneyPeriodWeek = 'This week';
  static const moneyPeriodMonth = 'This month';
  static const moneyPeriodAll = 'All time';
  static const moneyQuoted = 'Quoted';
  static const moneyAccepted = 'Accepted';
  static const moneyInvoiced = 'Invoiced';
  static const moneyPaid = 'Paid';
  static const moneyEmpty = 'Nothing here yet. Send your first quote.';
  static const moneyError = 'Totals unavailable. Force-quit and reopen.';

  // Onboarding.
  static const onboardingBusinessName = "What's the business called?";
  static const onboardingBusinessNameHint = 'Business name';
  static const onboardingLogoPick = 'Add logo';
  static const onboardingLogoChange = 'Change logo';
  static const onboardingServices = 'What do you charge for?';
  static const onboardingServicesHint =
      'Starter list. Edit prices to match yours.';
  static const onboardingPayVia = 'How do customers pay you?';
  static const onboardingPayViaHint = 'Venmo / Zelle / Square / check';
  static const onboardingDepositLabel = 'Default deposit';

  // Permissions.
  static const cameraRationale =
      'Photos of the surface go on the PDF so the price makes sense.';
  static const notificationsRationale =
      'Get a reminder to follow up on quotes that go cold.';
  static const cameraAllow = 'Allow camera';
  static const notificationsAllow = 'Allow reminders';
  static const notLater = 'Not now';

  // Common.
  static const cancel = 'Cancel';
  static const done = 'Done';
  static const save = 'Save';
  static const remove = 'Remove';
  static const retry = 'Try again';
  static const followUp = 'follow up?';
}
