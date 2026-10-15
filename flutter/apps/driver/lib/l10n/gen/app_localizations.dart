import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @placeholderBadge.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get placeholderBadge;

  /// No description provided for @placeholderFlowLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver · 00'**
  String get placeholderFlowLabel;

  /// No description provided for @placeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Drive with iyodriver. Earn on your schedule.'**
  String get placeholderTitle;

  /// No description provided for @placeholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accept rides and rental handovers in Douala and Yaoundé.'**
  String get placeholderSubtitle;

  /// No description provided for @placeholderSampleFare.
  ///
  /// In en, this message translates to:
  /// **'Today\'s earnings: {fare}'**
  String placeholderSampleFare(String fare);

  /// No description provided for @placeholderSampleTime.
  ///
  /// In en, this message translates to:
  /// **'Local time (Douala): {time}'**
  String placeholderSampleTime(String time);

  /// No description provided for @placeholderSamplePhone.
  ///
  /// In en, this message translates to:
  /// **'Payout number: {phone}'**
  String placeholderSamplePhone(String phone);

  /// No description provided for @placeholderPrimary.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get placeholderPrimary;

  /// No description provided for @placeholderSecondary.
  ///
  /// In en, this message translates to:
  /// **'Switch to Français'**
  String get placeholderSecondary;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get badge;

  /// No description provided for @flow.
  ///
  /// In en, this message translates to:
  /// **'Driver · {step}'**
  String flow(String step);

  /// No description provided for @flowPlain.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get flowPlain;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get tabEarnings;

  /// No description provided for @tabBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get tabBookings;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @welcomeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Drive.\nEarn.'**
  String get welcomeHeroTitle;

  /// No description provided for @welcomeBadge.
  ///
  /// In en, this message translates to:
  /// **'Rides + rental handovers'**
  String get welcomeBadge;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Drive with iyodriver.\nEarn on your schedule.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Accept rides and rental handovers in Douala and Yaoundé, and get paid to your mobile money.'**
  String get welcomeBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @alreadyDriver.
  ///
  /// In en, this message translates to:
  /// **'Already a driver?'**
  String get alreadyDriver;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your driver account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll check your documents before your first ride.'**
  String get signUpSubtitle;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name (as on your ID)'**
  String get fieldFullName;

  /// No description provided for @fieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get fieldMobile;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Driver Terms and Privacy Policy.'**
  String get agreeTerms;

  /// No description provided for @createAndVerify.
  ///
  /// In en, this message translates to:
  /// **'Create account & verify'**
  String get createAndVerify;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in with your mobile number. We\'ll text you a code.'**
  String get loginSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @newDriver.
  ///
  /// In en, this message translates to:
  /// **'New driver?'**
  String get newDriver;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your messages'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phone}.'**
  String verifySubtitle(String phone);

  /// No description provided for @demoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Demo mode · use code {code}'**
  String demoCodeHint(String code);

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get a code? Resend in {time}'**
  String resendIn(String time);

  /// No description provided for @resendNow.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get a code? Resend'**
  String get resendNow;

  /// No description provided for @wrongNumber.
  ///
  /// In en, this message translates to:
  /// **'Wrong number? Change it'**
  String get wrongNumber;

  /// No description provided for @verifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & continue'**
  String get verifyContinue;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Check the SMS and try again.'**
  String get otpInvalid;

  /// No description provided for @wrongApp.
  ///
  /// In en, this message translates to:
  /// **'This number is registered as a rider. Use the iyodriver app to book rides.'**
  String get wrongApp;

  /// No description provided for @identityTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity and vehicle'**
  String get identityTitle;

  /// No description provided for @identitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us who you are and what you drive.'**
  String get identitySubtitle;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(String current, String total);

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// No description provided for @fieldLicence.
  ///
  /// In en, this message translates to:
  /// **'Driving licence number'**
  String get fieldLicence;

  /// No description provided for @fieldNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID card number (CNI)'**
  String get fieldNationalId;

  /// No description provided for @vehicleSection.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get vehicleSection;

  /// No description provided for @fieldMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get fieldMake;

  /// No description provided for @fieldModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get fieldModel;

  /// No description provided for @fieldYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get fieldYear;

  /// No description provided for @fieldColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get fieldColor;

  /// No description provided for @fieldPlate.
  ///
  /// In en, this message translates to:
  /// **'Number plate'**
  String get fieldPlate;

  /// No description provided for @plateHelper.
  ///
  /// In en, this message translates to:
  /// **'Format: LT 123 AB'**
  String get plateHelper;

  /// No description provided for @plateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a plate like LT 123 AB.'**
  String get plateInvalid;

  /// No description provided for @yearInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a year between 1990 and next year.'**
  String get yearInvalid;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Ride category'**
  String get fieldCategory;

  /// No description provided for @categoryStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard · 4 seats'**
  String get categoryStandard;

  /// No description provided for @categoryComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort · 4 seats'**
  String get categoryComfort;

  /// No description provided for @categoryXl.
  ///
  /// In en, this message translates to:
  /// **'XL · 6 seats'**
  String get categoryXl;

  /// No description provided for @continueToDocuments.
  ///
  /// In en, this message translates to:
  /// **'Continue to documents'**
  String get continueToDocuments;

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTitle;

  /// No description provided for @documentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of each document. We review them within 24 hours.'**
  String get documentsSubtitle;

  /// No description provided for @docNationalIdFront.
  ///
  /// In en, this message translates to:
  /// **'National ID · front'**
  String get docNationalIdFront;

  /// No description provided for @docNationalIdBack.
  ///
  /// In en, this message translates to:
  /// **'National ID · back'**
  String get docNationalIdBack;

  /// No description provided for @docDrivingLicence.
  ///
  /// In en, this message translates to:
  /// **'Driving licence'**
  String get docDrivingLicence;

  /// No description provided for @docVehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration (carte grise)'**
  String get docVehicleRegistration;

  /// No description provided for @docInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance certificate'**
  String get docInsurance;

  /// No description provided for @docRoadworthiness.
  ///
  /// In en, this message translates to:
  /// **'Roadworthiness (visite technique)'**
  String get docRoadworthiness;

  /// No description provided for @docProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get docProfilePhoto;

  /// No description provided for @docMissing.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get docMissing;

  /// No description provided for @docUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading… {percent}%'**
  String docUploading(String percent);

  /// No description provided for @docPending.
  ///
  /// In en, this message translates to:
  /// **'Uploaded · waiting for review'**
  String get docPending;

  /// No description provided for @docApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get docApproved;

  /// No description provided for @docRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected · {reason}'**
  String docRejected(String reason);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitForReview;

  /// No description provided for @documentsMissingError.
  ///
  /// In en, this message translates to:
  /// **'Upload every document before submitting.'**
  String get documentsMissingError;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re checking your documents. You\'ll get a notification when it\'s done.'**
  String get reviewSubtitle;

  /// No description provided for @reviewDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: approval is simulated in a few seconds.'**
  String get reviewDemo;

  /// No description provided for @actionNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get actionNeededTitle;

  /// No description provided for @actionNeededSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One or more documents need to be uploaded again.'**
  String get actionNeededSubtitle;

  /// No description provided for @fixDocuments.
  ///
  /// In en, this message translates to:
  /// **'Update documents'**
  String get fixDocuments;

  /// No description provided for @approvedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re approved'**
  String get approvedTitle;

  /// No description provided for @approvedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to iyodriver. You can go online and accept rides.'**
  String get approvedSubtitle;

  /// No description provided for @startDriving.
  ///
  /// In en, this message translates to:
  /// **'Start driving'**
  String get startDriving;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineTitle;

  /// No description provided for @offlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go online to start receiving ride requests.'**
  String get offlineSubtitle;

  /// No description provided for @onlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re online'**
  String get onlineTitle;

  /// No description provided for @onlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for rides near you.'**
  String get onlineSubtitle;

  /// No description provided for @goOnline.
  ///
  /// In en, this message translates to:
  /// **'Go online'**
  String get goOnline;

  /// No description provided for @goOffline.
  ///
  /// In en, this message translates to:
  /// **'Go offline'**
  String get goOffline;

  /// No description provided for @acceptingRequests.
  ///
  /// In en, this message translates to:
  /// **'Accepting ride requests'**
  String get acceptingRequests;

  /// No description provided for @busyAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in a busy area'**
  String get busyAreaTitle;

  /// No description provided for @busyAreaBody.
  ///
  /// In en, this message translates to:
  /// **'Akwa & Bonanjo · Stay nearby for your next ride. Keep your phone mounted safely.'**
  String get busyAreaBody;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 trip} other{{count} trips}}'**
  String tripsCount(int count);

  /// No description provided for @onlineFor.
  ///
  /// In en, this message translates to:
  /// **'{time} online'**
  String onlineFor(String time);

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @lastTrips.
  ///
  /// In en, this message translates to:
  /// **'Last 100 trips'**
  String get lastTrips;

  /// No description provided for @locationNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location is needed to go online'**
  String get locationNeeded;

  /// No description provided for @locationNeededBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location \"all the time\" so riders can find you while you are online.'**
  String get locationNeededBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @onlineNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re online'**
  String get onlineNotificationTitle;

  /// No description provided for @onlineNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'iyodriver is sharing your location with nearby riders.'**
  String get onlineNotificationBody;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New ride request'**
  String get newRequest;

  /// No description provided for @pickupIn.
  ///
  /// In en, this message translates to:
  /// **'Pickup · {minutes} min · {distance}'**
  String pickupIn(String minutes, String distance);

  /// No description provided for @tripLength.
  ///
  /// In en, this message translates to:
  /// **'Trip · {distance} · about {minutes} min'**
  String tripLength(String distance, String minutes);

  /// No description provided for @youEarn.
  ///
  /// In en, this message translates to:
  /// **'You earn {amount}'**
  String youEarn(String amount);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @secondsLeft.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s to accept'**
  String secondsLeft(String seconds);

  /// No description provided for @toPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up {name}'**
  String toPickupTitle(String name);

  /// No description provided for @toPickupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{place} · {minutes} min away'**
  String toPickupSubtitle(String place, String minutes);

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @imHere.
  ///
  /// In en, this message translates to:
  /// **'I\'ve arrived'**
  String get imHere;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get cancelRide;

  /// No description provided for @cancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this ride?'**
  String get cancelTitle;

  /// No description provided for @cancelBody.
  ///
  /// In en, this message translates to:
  /// **'Frequent cancellations lower your acceptance rate.'**
  String get cancelBody;

  /// No description provided for @cancelReasonNoShow.
  ///
  /// In en, this message translates to:
  /// **'Rider did not show up'**
  String get cancelReasonNoShow;

  /// No description provided for @cancelReasonUnsafe.
  ///
  /// In en, this message translates to:
  /// **'I feel unsafe'**
  String get cancelReasonUnsafe;

  /// No description provided for @cancelReasonVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle problem'**
  String get cancelReasonVehicle;

  /// No description provided for @cancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get cancelReasonOther;

  /// No description provided for @keepRide.
  ///
  /// In en, this message translates to:
  /// **'Keep the ride'**
  String get keepRide;

  /// No description provided for @arrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}'**
  String arrivedTitle(String name);

  /// No description provided for @waitTime.
  ///
  /// In en, this message translates to:
  /// **'Wait time · {time}'**
  String waitTime(String time);

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask {name} for their 4-digit pickup PIN'**
  String pinLabel(String name);

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN · {count} attempts left'**
  String pinWrong(String count);

  /// No description provided for @pinLocked.
  ///
  /// In en, this message translates to:
  /// **'PIN locked after too many attempts. Support has been alerted.'**
  String get pinLocked;

  /// No description provided for @pinDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Demo mode · the rider PIN is {pin}'**
  String pinDemoHint(String pin);

  /// No description provided for @startRide.
  ///
  /// In en, this message translates to:
  /// **'Start ride'**
  String get startRide;

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Drive to {place}'**
  String liveTitle(String place);

  /// No description provided for @liveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {distance} left'**
  String liveSubtitle(String minutes, String distance);

  /// No description provided for @completeRide.
  ///
  /// In en, this message translates to:
  /// **'Complete ride'**
  String get completeRide;

  /// No description provided for @completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride complete'**
  String get completeTitle;

  /// No description provided for @completeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{place} · {payment}'**
  String completeSubtitle(String place, String payment);

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Your earnings'**
  String get earnings;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'iyodriver commission'**
  String get commission;

  /// No description provided for @collectCash.
  ///
  /// In en, this message translates to:
  /// **'Collect {amount} in cash from {name}'**
  String collectCash(String amount, String name);

  /// No description provided for @rateRider.
  ///
  /// In en, this message translates to:
  /// **'How was {name}?'**
  String rateRider(String name);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @riderCancelled.
  ///
  /// In en, this message translates to:
  /// **'The rider cancelled'**
  String get riderCancelled;

  /// No description provided for @riderCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'You will not be charged for this ride.'**
  String get riderCancelledBody;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @chatWith.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String chatWith(String name);

  /// No description provided for @chatPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your phone number stays private.'**
  String get chatPrivacy;

  /// No description provided for @writeMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get writeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @callRider.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String callRider(String name);

  /// No description provided for @messageRider.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String messageRider(String name);

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentMtn.
  ///
  /// In en, this message translates to:
  /// **'MTN MoMo'**
  String get paymentMtn;

  /// No description provided for @paymentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange Money'**
  String get paymentOrange;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentCard;

  /// No description provided for @riderRating.
  ///
  /// In en, this message translates to:
  /// **'★ {rating} · Verified rider'**
  String riderRating(String rating);

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTitle;

  /// No description provided for @earningsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paid to your mobile money every week.'**
  String get earningsSubtitle;

  /// No description provided for @recentTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent trips'**
  String get recentTrips;

  /// No description provided for @noTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get noTripsTitle;

  /// No description provided for @noTripsBody.
  ///
  /// In en, this message translates to:
  /// **'Go online to receive your first ride request.'**
  String get noTripsBody;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsTitle;

  /// No description provided for @bookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your trips and rental handovers.'**
  String get bookingsSubtitle;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile, vehicle and payouts.'**
  String get accountSubtitle;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @componentGallery.
  ///
  /// In en, this message translates to:
  /// **'Component gallery (dev)'**
  String get componentGallery;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @safetySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safetySheetTitle;

  /// No description provided for @shareTrip.
  ///
  /// In en, this message translates to:
  /// **'Share trip'**
  String get shareTrip;

  /// No description provided for @shareTripBody.
  ///
  /// In en, this message translates to:
  /// **'Send a live link of this trip to someone you trust.'**
  String get shareTripBody;

  /// No description provided for @shareTripSubject.
  ///
  /// In en, this message translates to:
  /// **'My iyodriver trip'**
  String get shareTripSubject;

  /// No description provided for @shareTripText.
  ///
  /// In en, this message translates to:
  /// **'Follow my iyodriver trip live (link valid until {time}): {link}'**
  String shareTripText(String time, String link);

  /// No description provided for @reportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report an incident'**
  String get reportIncident;

  /// No description provided for @reportIncidentBody.
  ///
  /// In en, this message translates to:
  /// **'Tell the iyodriver safety team what happened.'**
  String get reportIncidentBody;

  /// No description provided for @callPolice.
  ///
  /// In en, this message translates to:
  /// **'Call police · {number}'**
  String callPolice(String number);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create a share link. Try again.'**
  String get shareFailed;

  /// No description provided for @flowIncident.
  ///
  /// In en, this message translates to:
  /// **'Driver · 17'**
  String get flowIncident;

  /// No description provided for @incidentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an incident'**
  String get incidentTitle;

  /// No description provided for @incidentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The safety team reviews every report. Urgent reports are seen first.'**
  String get incidentSubtitle;

  /// No description provided for @incidentCategory.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get incidentCategory;

  /// No description provided for @incidentAccident.
  ///
  /// In en, this message translates to:
  /// **'Road accident'**
  String get incidentAccident;

  /// No description provided for @incidentRiderBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Rider behaviour'**
  String get incidentRiderBehaviour;

  /// No description provided for @incidentVehicleDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage to the vehicle'**
  String get incidentVehicleDamage;

  /// No description provided for @incidentTheft.
  ///
  /// In en, this message translates to:
  /// **'Theft or aggression'**
  String get incidentTheft;

  /// No description provided for @incidentLostItem.
  ///
  /// In en, this message translates to:
  /// **'Lost item'**
  String get incidentLostItem;

  /// No description provided for @incidentPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment problem'**
  String get incidentPayment;

  /// No description provided for @incidentOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get incidentOther;

  /// No description provided for @incidentDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened'**
  String get incidentDescription;

  /// No description provided for @incidentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Where, when, who was involved…'**
  String get incidentDescriptionHint;

  /// No description provided for @incidentUrgent.
  ///
  /// In en, this message translates to:
  /// **'This is urgent'**
  String get incidentUrgent;

  /// No description provided for @incidentUrgentBody.
  ///
  /// In en, this message translates to:
  /// **'The safety team calls you back as soon as possible.'**
  String get incidentUrgentBody;

  /// No description provided for @incidentAbout.
  ///
  /// In en, this message translates to:
  /// **'About: {what}'**
  String incidentAbout(String what);

  /// No description provided for @incidentAboutTrip.
  ///
  /// In en, this message translates to:
  /// **'your current trip'**
  String get incidentAboutTrip;

  /// No description provided for @incidentAboutRental.
  ///
  /// In en, this message translates to:
  /// **'rental {ref}'**
  String incidentAboutRental(String ref);

  /// No description provided for @incidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location is attached: {where}'**
  String incidentLocation(String where);

  /// No description provided for @incidentNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable; describe where you are.'**
  String get incidentNoLocation;

  /// No description provided for @incidentEmergency.
  ///
  /// In en, this message translates to:
  /// **'In danger? Call {number} first.'**
  String incidentEmergency(String number);

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get sendReport;

  /// No description provided for @pickCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose what happened.'**
  String get pickCategory;

  /// No description provided for @flowReportSent.
  ///
  /// In en, this message translates to:
  /// **'Driver · 18'**
  String get flowReportSent;

  /// No description provided for @reportSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report sent'**
  String get reportSentTitle;

  /// No description provided for @reportSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you. The safety team has your report and trip details.'**
  String get reportSentSubtitle;

  /// No description provided for @reportReference.
  ///
  /// In en, this message translates to:
  /// **'Reference {ref} · {time}'**
  String reportReference(String ref, String time);

  /// No description provided for @reportUrgentNote.
  ///
  /// In en, this message translates to:
  /// **'Marked urgent: keep your phone on, the team will call you.'**
  String get reportUrgentNote;

  /// No description provided for @reportNextNote.
  ///
  /// In en, this message translates to:
  /// **'You can keep driving. We may contact you for more details.'**
  String get reportNextNote;

  /// No description provided for @backToTrip.
  ///
  /// In en, this message translates to:
  /// **'Back to the trip'**
  String get backToTrip;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @segmentRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get segmentRentals;

  /// No description provided for @segmentTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get segmentTrips;

  /// No description provided for @noRentalsTitle.
  ///
  /// In en, this message translates to:
  /// **'No rental deliveries'**
  String get noRentalsTitle;

  /// No description provided for @noRentalsBody.
  ///
  /// In en, this message translates to:
  /// **'Cars you are asked to deliver or collect appear here.'**
  String get noRentalsBody;

  /// No description provided for @rentalFor.
  ///
  /// In en, this message translates to:
  /// **'For {name}'**
  String rentalFor(String name);

  /// No description provided for @rentalRef.
  ///
  /// In en, this message translates to:
  /// **'Rental {ref}'**
  String rentalRef(String ref);

  /// No description provided for @deliverAt.
  ///
  /// In en, this message translates to:
  /// **'Deliver {date}'**
  String deliverAt(String date);

  /// No description provided for @collectBy.
  ///
  /// In en, this message translates to:
  /// **'Collect {date}'**
  String collectBy(String date);

  /// No description provided for @flightArrives.
  ///
  /// In en, this message translates to:
  /// **'Flight {flight} · lands {time}'**
  String flightArrives(String flight, String time);

  /// No description provided for @airportRequirements.
  ///
  /// In en, this message translates to:
  /// **'Meet the rider at arrivals with a name sign. Check the flight status before you leave.'**
  String get airportRequirements;

  /// No description provided for @rentalStatusToDeliver.
  ///
  /// In en, this message translates to:
  /// **'To deliver'**
  String get rentalStatusToDeliver;

  /// No description provided for @rentalStatusAwaitingRider.
  ///
  /// In en, this message translates to:
  /// **'Awaiting rider'**
  String get rentalStatusAwaitingRider;

  /// No description provided for @rentalStatusWithRider.
  ///
  /// In en, this message translates to:
  /// **'With rider'**
  String get rentalStatusWithRider;

  /// No description provided for @rentalStatusReturnCheck.
  ///
  /// In en, this message translates to:
  /// **'Return check'**
  String get rentalStatusReturnCheck;

  /// No description provided for @rentalStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rentalStatusDone;

  /// No description provided for @flowRental.
  ///
  /// In en, this message translates to:
  /// **'Driver · 16'**
  String get flowRental;

  /// No description provided for @deliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Deliver {car}'**
  String deliveryTitle(String car);

  /// No description provided for @deliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hand the car to {name} and record its condition together.'**
  String deliverySubtitle(String name);

  /// No description provided for @collectTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect {car}'**
  String collectTitle(String car);

  /// No description provided for @collectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inspect the car with {name} before you take it back.'**
  String collectSubtitle(String name);

  /// No description provided for @navigateTo.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigateTo;

  /// No description provided for @startHandover.
  ///
  /// In en, this message translates to:
  /// **'Start handover checklist'**
  String get startHandover;

  /// No description provided for @startReturn.
  ///
  /// In en, this message translates to:
  /// **'Start return inspection'**
  String get startReturn;

  /// No description provided for @waitingRiderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm in the app.'**
  String waitingRiderConfirm(String name);

  /// No description provided for @rentalWithRider.
  ///
  /// In en, this message translates to:
  /// **'The rider has the car until {date}.'**
  String rentalWithRider(String date);

  /// No description provided for @rentalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Rental closed. Thank you.'**
  String get rentalCompleted;

  /// No description provided for @depositToHold.
  ///
  /// In en, this message translates to:
  /// **'Deposit: {amount}'**
  String depositToHold(String amount);

  /// No description provided for @handoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Handover checklist'**
  String get handoverTitle;

  /// No description provided for @returnTitle.
  ///
  /// In en, this message translates to:
  /// **'Return inspection'**
  String get returnTitle;

  /// No description provided for @checklistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take the five photos, then record fuel, odometer and any damage.'**
  String get checklistSubtitle;

  /// No description provided for @photoFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get photoFront;

  /// No description provided for @photoBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get photoBack;

  /// No description provided for @photoLeft.
  ///
  /// In en, this message translates to:
  /// **'Left side'**
  String get photoLeft;

  /// No description provided for @photoRight.
  ///
  /// In en, this message translates to:
  /// **'Right side'**
  String get photoRight;

  /// No description provided for @photoInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get photoInterior;

  /// No description provided for @photosRequired.
  ///
  /// In en, this message translates to:
  /// **'All five photos are required.'**
  String get photosRequired;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retakePhoto;

  /// No description provided for @fuelLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuel level'**
  String get fuelLabel;

  /// No description provided for @fuelValue.
  ///
  /// In en, this message translates to:
  /// **'{n}/8'**
  String fuelValue(String n);

  /// No description provided for @odometerLabel.
  ///
  /// In en, this message translates to:
  /// **'Odometer (km)'**
  String get odometerLabel;

  /// No description provided for @odometerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the odometer reading.'**
  String get odometerInvalid;

  /// No description provided for @damageLabel.
  ///
  /// In en, this message translates to:
  /// **'Damage notes'**
  String get damageLabel;

  /// No description provided for @damageHint.
  ///
  /// In en, this message translates to:
  /// **'Scratches, dents, warning lights… Leave empty if none.'**
  String get damageHint;

  /// No description provided for @checkDocuments.
  ///
  /// In en, this message translates to:
  /// **'Car papers in the glovebox'**
  String get checkDocuments;

  /// No description provided for @checkSpare.
  ///
  /// In en, this message translates to:
  /// **'Spare tyre and jack'**
  String get checkSpare;

  /// No description provided for @checkClean.
  ///
  /// In en, this message translates to:
  /// **'Interior clean'**
  String get checkClean;

  /// No description provided for @depositHoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep from deposit (FCFA)'**
  String get depositHoldLabel;

  /// No description provided for @depositHoldHelper.
  ///
  /// In en, this message translates to:
  /// **'0 releases the full deposit. Up to {amount}.'**
  String depositHoldHelper(String amount);

  /// No description provided for @depositHoldInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between 0 and {amount}.'**
  String depositHoldInvalid(String amount);

  /// No description provided for @submitHandover.
  ///
  /// In en, this message translates to:
  /// **'Submit for rider confirmation'**
  String get submitHandover;

  /// No description provided for @uploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos… {percent}%'**
  String uploadingPhotos(String percent);

  /// No description provided for @inspectionFailed.
  ///
  /// In en, this message translates to:
  /// **'The inspection could not be sent. Check your connection and try again.'**
  String get inspectionFailed;

  /// No description provided for @menuReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report an incident'**
  String get menuReportIncident;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @homeOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You’re offline. Ready when you are.'**
  String get homeOfflineSubtitle;

  /// No description provided for @todaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today’s earnings'**
  String get todaysEarnings;

  /// No description provided for @completedTrips.
  ///
  /// In en, this message translates to:
  /// **'Completed trips'**
  String get completedTrips;

  /// No description provided for @offlineBadge.
  ///
  /// In en, this message translates to:
  /// **'Offline · No ride requests'**
  String get offlineBadge;

  /// No description provided for @nextRental.
  ///
  /// In en, this message translates to:
  /// **'Next rental · {when}'**
  String nextRental(String when);

  /// No description provided for @nextRentalDetail.
  ///
  /// In en, this message translates to:
  /// **'{place} · {car} · {days}'**
  String nextRentalDetail(String place, String car, String days);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String daysCount(String n);

  /// No description provided for @oneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// No description provided for @homeOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re online'**
  String get homeOnlineTitle;

  /// No description provided for @homeOnlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for riders nearby…'**
  String get homeOnlineSubtitle;

  /// No description provided for @busyAreaHeading.
  ///
  /// In en, this message translates to:
  /// **'You’re in a busy area'**
  String get busyAreaHeading;

  /// No description provided for @busyAreaText.
  ///
  /// In en, this message translates to:
  /// **'{area} · Stay nearby for your next ride. Keep your phone mounted safely.'**
  String busyAreaText(String area);

  /// No description provided for @todayAmount.
  ///
  /// In en, this message translates to:
  /// **'Today · {amount}'**
  String todayAmount(String amount);

  /// No description provided for @tripsOnline.
  ///
  /// In en, this message translates to:
  /// **'{trips} · {online} online'**
  String tripsOnline(String trips, String online);

  /// No description provided for @tripsN.
  ///
  /// In en, this message translates to:
  /// **'{n} trips'**
  String tripsN(String n);

  /// No description provided for @oneTrip.
  ///
  /// In en, this message translates to:
  /// **'1 trip'**
  String get oneTrip;

  /// No description provided for @requestTitle.
  ///
  /// In en, this message translates to:
  /// **'A new ride nearby'**
  String get requestTitle;

  /// No description provided for @requestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{category} · Accept within {seconds} seconds'**
  String requestSubtitle(String category, String seconds);

  /// No description provided for @estEarningsBadge.
  ///
  /// In en, this message translates to:
  /// **'Your est. earnings'**
  String get estEarningsBadge;

  /// No description provided for @requestMeta.
  ///
  /// In en, this message translates to:
  /// **'{pickup} min to pickup · Trip {trip} min · {distance}'**
  String requestMeta(String pickup, String trip, String distance);

  /// No description provided for @pickupSuffix.
  ///
  /// In en, this message translates to:
  /// **'{area} · Pickup'**
  String pickupSuffix(String area);

  /// No description provided for @dropoffSuffix.
  ///
  /// In en, this message translates to:
  /// **'{area} · Drop-off'**
  String dropoffSuffix(String area);

  /// No description provided for @verifiedRider.
  ///
  /// In en, this message translates to:
  /// **'★ {rating} · Verified rider'**
  String verifiedRider(String rating);

  /// No description provided for @askForPin.
  ///
  /// In en, this message translates to:
  /// **'Ask for the pickup PIN at the car'**
  String get askForPin;

  /// No description provided for @acceptRideSeconds.
  ///
  /// In en, this message translates to:
  /// **'Accept ride · {seconds}s'**
  String acceptRideSeconds(String seconds);

  /// No description provided for @declineRequest.
  ///
  /// In en, this message translates to:
  /// **'Decline request'**
  String get declineRequest;

  /// No description provided for @headToRider.
  ///
  /// In en, this message translates to:
  /// **'Head to {name}'**
  String headToRider(String name);

  /// No description provided for @headToSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{place} · {minutes} min · {distance}'**
  String headToSubtitle(String place, String minutes, String distance);

  /// No description provided for @navContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue for {distance}'**
  String navContinue(String distance);

  /// No description provided for @navTowards.
  ///
  /// In en, this message translates to:
  /// **'Towards {place}'**
  String navTowards(String place);

  /// No description provided for @navArriving.
  ///
  /// In en, this message translates to:
  /// **'Arriving at {place}'**
  String navArriving(String place);

  /// No description provided for @tileMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get tileMessage;

  /// No description provided for @tileShareTrip.
  ///
  /// In en, this message translates to:
  /// **'Share trip'**
  String get tileShareTrip;

  /// No description provided for @tileSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get tileSafety;

  /// No description provided for @pickupNote.
  ///
  /// In en, this message translates to:
  /// **'Pickup note: “{note}”'**
  String pickupNote(String note);

  /// No description provided for @stopSafely.
  ///
  /// In en, this message translates to:
  /// **'Please stop safely before contacting your rider.'**
  String get stopSafely;

  /// No description provided for @arrivedAtPickup.
  ///
  /// In en, this message translates to:
  /// **'I’ve arrived at pickup'**
  String get arrivedAtPickup;

  /// No description provided for @atPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re at the pickup'**
  String get atPickupTitle;

  /// No description provided for @atPickupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} has been notified you’ve arrived.'**
  String atPickupSubtitle(String name);

  /// No description provided for @askPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask {name} for the 4-digit pickup PIN'**
  String askPinLabel(String name);

  /// No description provided for @pinVerified.
  ///
  /// In en, this message translates to:
  /// **'✓ PIN verified · You can start the ride.'**
  String get pinVerified;

  /// No description provided for @confirmRiderNote.
  ///
  /// In en, this message translates to:
  /// **'Confirm the rider’s name before departure. Destination: {place}.'**
  String confirmRiderNote(String place);

  /// No description provided for @driveTo.
  ///
  /// In en, this message translates to:
  /// **'Drive to {place}'**
  String driveTo(String place);

  /// No description provided for @driveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arrive {time} · {minutes} min · {distance} left'**
  String driveSubtitle(String time, String minutes, String distance);

  /// No description provided for @tripInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress · {ref}'**
  String tripInProgress(String ref);

  /// No description provided for @endRide.
  ///
  /// In en, this message translates to:
  /// **'End ride at destination'**
  String get endRide;

  /// No description provided for @cancelThisRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel this ride'**
  String get cancelThisRide;

  /// No description provided for @navTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right in {distance}'**
  String navTurnRight(String distance);

  /// No description provided for @navInto.
  ///
  /// In en, this message translates to:
  /// **'Into {street}'**
  String navInto(String street);

  /// No description provided for @navOn.
  ///
  /// In en, this message translates to:
  /// **'On {street}'**
  String navOn(String street);

  /// No description provided for @mainEntrance.
  ///
  /// In en, this message translates to:
  /// **'{area} · Main entrance'**
  String mainEntrance(String area);

  /// No description provided for @earnTitle.
  ///
  /// In en, this message translates to:
  /// **'Your earnings'**
  String get earnTitle;

  /// No description provided for @earnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{range} · Net after service fees'**
  String earnSubtitle(String range);

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @weekSoFar.
  ///
  /// In en, this message translates to:
  /// **'This week so far'**
  String get weekSoFar;

  /// No description provided for @monthSoFar.
  ///
  /// In en, this message translates to:
  /// **'This month so far'**
  String get monthSoFar;

  /// No description provided for @yearSoFar.
  ///
  /// In en, this message translates to:
  /// **'This year so far'**
  String get yearSoFar;

  /// No description provided for @tripsDriving.
  ///
  /// In en, this message translates to:
  /// **'{trips} · {time} driving'**
  String tripsDriving(String trips, String time);

  /// No description provided for @nextPayout.
  ///
  /// In en, this message translates to:
  /// **'Next scheduled payout'**
  String get nextPayout;

  /// No description provided for @nextPayoutDetail.
  ///
  /// In en, this message translates to:
  /// **'{date} · {account}'**
  String nextPayoutDetail(String date, String account);

  /// No description provided for @payoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Payout history'**
  String get payoutHistory;

  /// No description provided for @paidTo.
  ///
  /// In en, this message translates to:
  /// **'Paid to {account}'**
  String paidTo(String account);

  /// No description provided for @payoutPending.
  ///
  /// In en, this message translates to:
  /// **'Being sent to {account}'**
  String payoutPending(String account);

  /// No description provided for @payoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed · {reason}'**
  String payoutFailed(String reason);

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @viewPayoutDetails.
  ///
  /// In en, this message translates to:
  /// **'View payout details'**
  String get viewPayoutDetails;

  /// No description provided for @noPayoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No payouts yet. Earnings are paid weekly, every Monday.'**
  String get noPayoutsYet;

  /// No description provided for @weekdayLetters.
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get weekdayLetters;

  /// No description provided for @monthLetters.
  ///
  /// In en, this message translates to:
  /// **'J,F,M,A,M,J,J,A,S,O,N,D'**
  String get monthLetters;

  /// No description provided for @weekN.
  ///
  /// In en, this message translates to:
  /// **'W{n}'**
  String weekN(String n);

  /// No description provided for @payoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Payout details'**
  String get payoutTitle;

  /// No description provided for @payoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{ref} · {range}'**
  String payoutSubtitle(String ref, String range);

  /// No description provided for @sentOn.
  ///
  /// In en, this message translates to:
  /// **'Sent on {date}'**
  String sentOn(String date);

  /// No description provided for @requestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested on {date}'**
  String requestedOn(String date);

  /// No description provided for @payoutBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Payout breakdown'**
  String get payoutBreakdown;

  /// No description provided for @rideFaresLine.
  ///
  /// In en, this message translates to:
  /// **'Ride fares · {trips}'**
  String rideFaresLine(String trips);

  /// No description provided for @rentalHandoverEarnings.
  ///
  /// In en, this message translates to:
  /// **'Rental handover earnings'**
  String get rentalHandoverEarnings;

  /// No description provided for @tipsLine.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tipsLine;

  /// No description provided for @serviceFeesLine.
  ///
  /// In en, this message translates to:
  /// **'Service fees'**
  String get serviceFeesLine;

  /// No description provided for @netPayout.
  ///
  /// In en, this message translates to:
  /// **'Net payout'**
  String get netPayout;

  /// No description provided for @mobileMoneyTransfer.
  ///
  /// In en, this message translates to:
  /// **'{name} · Mobile money transfer'**
  String mobileMoneyTransfer(String name);

  /// No description provided for @transferTimeline.
  ///
  /// In en, this message translates to:
  /// **'Transfer timeline'**
  String get transferTimeline;

  /// No description provided for @tlCreated.
  ///
  /// In en, this message translates to:
  /// **'Payout created'**
  String get tlCreated;

  /// No description provided for @tlCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'{time} · Weekly earnings calculated'**
  String tlCreatedBody(String time);

  /// No description provided for @tlSent.
  ///
  /// In en, this message translates to:
  /// **'Transfer sent'**
  String get tlSent;

  /// No description provided for @tlSentBody.
  ///
  /// In en, this message translates to:
  /// **'{time} · Reference {ref}'**
  String tlSentBody(String time, String ref);

  /// No description provided for @tlDelivered.
  ///
  /// In en, this message translates to:
  /// **'Transfer delivered'**
  String get tlDelivered;

  /// No description provided for @tlDeliveredBody.
  ///
  /// In en, this message translates to:
  /// **'{time} · Funds delivered'**
  String tlDeliveredBody(String time);

  /// No description provided for @tlWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the operator'**
  String get tlWaiting;

  /// No description provided for @payoutHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Quote {ref} when contacting support.'**
  String payoutHelp(String ref);

  /// No description provided for @downloadStatement.
  ///
  /// In en, this message translates to:
  /// **'Download statement'**
  String get downloadStatement;

  /// No description provided for @statementTitle.
  ///
  /// In en, this message translates to:
  /// **'iyodriver payout {ref}'**
  String statementTitle(String ref);

  /// No description provided for @bookingsHeading.
  ///
  /// In en, this message translates to:
  /// **'Your bookings'**
  String get bookingsHeading;

  /// No description provided for @bookingsSub.
  ///
  /// In en, this message translates to:
  /// **'Upcoming handovers and completed trips.'**
  String get bookingsSub;

  /// No description provided for @segUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get segUpcoming;

  /// No description provided for @segHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get segHistory;

  /// No description provided for @airportPickupConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Airport pickup · {status}'**
  String airportPickupConfirmed(String status);

  /// No description provided for @addressPickupStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivery · {status}'**
  String addressPickupStatus(String status);

  /// No description provided for @statusConfirmedShort.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmedShort;

  /// No description provided for @rentalWhenWhere.
  ///
  /// In en, this message translates to:
  /// **'{when} · {place}'**
  String rentalWhenWhere(String when, String place);

  /// No description provided for @returnWhenWhere.
  ///
  /// In en, this message translates to:
  /// **'Return: {when} · {place}'**
  String returnWhenWhere(String when, String place);

  /// No description provided for @viewHandoverRequirements.
  ///
  /// In en, this message translates to:
  /// **'View handover requirements'**
  String get viewHandoverRequirements;

  /// No description provided for @viewReturnSteps.
  ///
  /// In en, this message translates to:
  /// **'View return inspection'**
  String get viewReturnSteps;

  /// No description provided for @todaysCompletedRides.
  ///
  /// In en, this message translates to:
  /// **'Today’s completed rides'**
  String get todaysCompletedRides;

  /// No description provided for @statusCompletedShort.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompletedShort;

  /// No description provided for @bookingsFootnote.
  ///
  /// In en, this message translates to:
  /// **'Ride amounts show net earnings after service fees. View all past bookings in History.'**
  String get bookingsFootnote;

  /// No description provided for @noUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing booked yet'**
  String get noUpcomingTitle;

  /// No description provided for @noUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'Rental handovers assigned to you appear here.'**
  String get noUpcomingBody;

  /// No description provided for @pastRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get pastRentals;

  /// No description provided for @pastRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get pastRides;

  /// No description provided for @perDayBadge.
  ///
  /// In en, this message translates to:
  /// **'{price} / day'**
  String perDayBadge(String price);

  /// No description provided for @carSpecs.
  ///
  /// In en, this message translates to:
  /// **'{fuel} · {gearbox} · {seats} seats'**
  String carSpecs(String fuel, String gearbox, String seats);

  /// No description provided for @fuelPetrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get fuelPetrol;

  /// No description provided for @fuelDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get fuelDiesel;

  /// No description provided for @fuelHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get fuelHybrid;

  /// No description provided for @fuelElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get fuelElectric;

  /// No description provided for @gearAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get gearAutomatic;

  /// No description provided for @gearManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get gearManual;

  /// No description provided for @accountHeading.
  ///
  /// In en, this message translates to:
  /// **'Driver account'**
  String get accountHeading;

  /// No description provided for @accountSub.
  ///
  /// In en, this message translates to:
  /// **'Your profile and road-ready documents.'**
  String get accountSub;

  /// No description provided for @driverMeta.
  ///
  /// In en, this message translates to:
  /// **'★ {rating} · {trips} · Driver {ref}'**
  String driverMeta(String rating, String trips, String ref);

  /// No description provided for @verifiedDriver.
  ///
  /// In en, this message translates to:
  /// **'Verified driver'**
  String get verifiedDriver;

  /// No description provided for @yourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get yourVehicle;

  /// No description provided for @vehicleSpecs.
  ///
  /// In en, this message translates to:
  /// **'{colour} · {year} · {seats} seats'**
  String vehicleSpecs(String colour, String year, String seats);

  /// No description provided for @plateServices.
  ///
  /// In en, this message translates to:
  /// **'{plate} · Ride & rental'**
  String plateServices(String plate);

  /// No description provided for @categoryApproved.
  ///
  /// In en, this message translates to:
  /// **'{category} · Approved'**
  String categoryApproved(String category);

  /// No description provided for @categoryInReview.
  ///
  /// In en, this message translates to:
  /// **'{category} · In review'**
  String categoryInReview(String category);

  /// No description provided for @documentsHeading.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsHeading;

  /// No description provided for @docVerifiedExpires.
  ///
  /// In en, this message translates to:
  /// **'Verified · Expires {date}'**
  String docVerifiedExpires(String date);

  /// No description provided for @docVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get docVerified;

  /// No description provided for @docRenewBy.
  ///
  /// In en, this message translates to:
  /// **'Renew by {date}'**
  String docRenewBy(String date);

  /// No description provided for @docInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get docInReview;

  /// No description provided for @docNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Action needed · {reason}'**
  String docNeedsAction(String reason);

  /// No description provided for @docNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded yet'**
  String get docNotUploaded;

  /// No description provided for @payoutDetailsRow.
  ///
  /// In en, this message translates to:
  /// **'Payout details'**
  String get payoutDetailsRow;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @vehicleChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Changes to vehicle details may require a new review before you can go online.'**
  String get vehicleChangeNote;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account details'**
  String get editAccount;

  /// No description provided for @moreSection.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreSection;

  /// No description provided for @flowSetup.
  ///
  /// In en, this message translates to:
  /// **'Driver setup · {step}'**
  String flowSetup(String step);

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s get you road-ready'**
  String get setupTitle;

  /// No description provided for @setupStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 · Identity & vehicle'**
  String get setupStep1;

  /// No description provided for @driverAccountBadge.
  ///
  /// In en, this message translates to:
  /// **'Driver account'**
  String get driverAccountBadge;

  /// No description provided for @legalName.
  ///
  /// In en, this message translates to:
  /// **'Legal name'**
  String get legalName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dateOfBirthHint;

  /// No description provided for @dobInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter your date of birth (you must be 21 or older).'**
  String get dobInvalid;

  /// No description provided for @vehicleMakeModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle make & model'**
  String get vehicleMakeModel;

  /// No description provided for @vehicleMakeModelHint.
  ///
  /// In en, this message translates to:
  /// **'Toyota Corolla · 2018 · Blanc'**
  String get vehicleMakeModelHint;

  /// No description provided for @vehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration'**
  String get vehicleRegistration;

  /// No description provided for @vehicleCheckedHelper.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle details will be checked with your documents.'**
  String get vehicleCheckedHelper;

  /// No description provided for @legalDetailsNote.
  ///
  /// In en, this message translates to:
  /// **'Your legal details are used for verification. Riders will only see your first name and vehicle details.'**
  String get legalDetailsNote;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & continue to documents'**
  String get saveAndContinue;

  /// No description provided for @vehicleSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get vehicleSheetTitle;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'Also needed for verification'**
  String get moreDetails;

  /// No description provided for @docsTitle.
  ///
  /// In en, this message translates to:
  /// **'A quick safety check'**
  String get docsTitle;

  /// No description provided for @setupStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 · Upload your documents'**
  String get setupStep2;

  /// No description provided for @docsReady.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} documents ready'**
  String docsReady(String n, String total);

  /// No description provided for @groupIdentity.
  ///
  /// In en, this message translates to:
  /// **'Photo ID & selfie'**
  String get groupIdentity;

  /// No description provided for @groupIdentityDone.
  ///
  /// In en, this message translates to:
  /// **'Identity photos received'**
  String get groupIdentityDone;

  /// No description provided for @groupLicence.
  ///
  /// In en, this message translates to:
  /// **'Driving licence'**
  String get groupLicence;

  /// No description provided for @groupLicenceDone.
  ///
  /// In en, this message translates to:
  /// **'Licence uploaded'**
  String get groupLicenceDone;

  /// No description provided for @groupVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle papers'**
  String get groupVehicle;

  /// No description provided for @groupVehicleDone.
  ///
  /// In en, this message translates to:
  /// **'Carte grise and visite technique uploaded'**
  String get groupVehicleDone;

  /// No description provided for @groupInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance certificate'**
  String get groupInsurance;

  /// No description provided for @groupInsuranceDone.
  ///
  /// In en, this message translates to:
  /// **'Insurance uploaded'**
  String get groupInsuranceDone;

  /// No description provided for @groupApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get groupApproved;

  /// No description provided for @groupInReview.
  ///
  /// In en, this message translates to:
  /// **'Uploaded · in review'**
  String get groupInReview;

  /// No description provided for @groupMissing.
  ///
  /// In en, this message translates to:
  /// **'{n} to upload'**
  String groupMissing(String n);

  /// No description provided for @nextDocument.
  ///
  /// In en, this message translates to:
  /// **'Next: {doc}'**
  String nextDocument(String doc);

  /// No description provided for @noFileYet.
  ///
  /// In en, this message translates to:
  /// **'No photo yet'**
  String get noFileYet;

  /// No description provided for @uploadTips.
  ///
  /// In en, this message translates to:
  /// **'Tips for a successful upload'**
  String get uploadTips;

  /// No description provided for @uploadTipsBody.
  ///
  /// In en, this message translates to:
  /// **'Keep all four corners visible. Use good lighting and avoid glare. Accepted: JPG, PNG or PDF, up to 10 MB.'**
  String get uploadTipsBody;

  /// No description provided for @reviewTimeNote.
  ///
  /// In en, this message translates to:
  /// **'After you submit, reviews usually take 1–2 working days. We’ll notify you when you’re approved.'**
  String get reviewTimeNote;

  /// No description provided for @uploadDoc.
  ///
  /// In en, this message translates to:
  /// **'Upload {doc} photo'**
  String uploadDoc(String doc);

  /// No description provided for @retakeDoc.
  ///
  /// In en, this message translates to:
  /// **'Retake {doc} photo'**
  String retakeDoc(String doc);

  /// No description provided for @identityLocked.
  ///
  /// In en, this message translates to:
  /// **'Verified details are locked. Contact support to change them.'**
  String get identityLocked;

  /// No description provided for @flowDriverRental.
  ///
  /// In en, this message translates to:
  /// **'Driver rental · {step}'**
  String flowDriverRental(String step);

  /// No description provided for @airportRentalPickup.
  ///
  /// In en, this message translates to:
  /// **'Airport rental pickup'**
  String get airportRentalPickup;

  /// No description provided for @addressRentalPickup.
  ///
  /// In en, this message translates to:
  /// **'Rental delivery'**
  String get addressRentalPickup;

  /// No description provided for @rentalReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Rental return'**
  String get rentalReturnTitle;

  /// No description provided for @confirmedBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirmed booking · {ref}'**
  String confirmedBooking(String ref);

  /// No description provided for @upcomingWhen.
  ///
  /// In en, this message translates to:
  /// **'Upcoming · {when}'**
  String upcomingWhen(String when);

  /// No description provided for @withRiderUntil.
  ///
  /// In en, this message translates to:
  /// **'With rider · until {when}'**
  String withRiderUntil(String when);

  /// No description provided for @carWithFuel.
  ///
  /// In en, this message translates to:
  /// **'{car} · {fuel}'**
  String carWithFuel(String car, String fuel);

  /// No description provided for @rentalPeriodDays.
  ///
  /// In en, this message translates to:
  /// **'{range} · {days}'**
  String rentalPeriodDays(String range, String days);

  /// No description provided for @pickupOn.
  ///
  /// In en, this message translates to:
  /// **'Pickup · {day}'**
  String pickupOn(String day);

  /// No description provided for @returnOn.
  ///
  /// In en, this message translates to:
  /// **'Return · {day}'**
  String returnOn(String day);

  /// No description provided for @timeAtPlace.
  ///
  /// In en, this message translates to:
  /// **'{time} · {place}'**
  String timeAtPlace(String time, String place);

  /// No description provided for @airportRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Airport pickup requirements'**
  String get airportRequirementsTitle;

  /// No description provided for @flightLine.
  ///
  /// In en, this message translates to:
  /// **'{flight} · {route}'**
  String flightLine(String flight, String route);

  /// No description provided for @landingLine.
  ///
  /// In en, this message translates to:
  /// **'Landing: {when} · {terminal}'**
  String landingLine(String when, String terminal);

  /// No description provided for @meetLine.
  ///
  /// In en, this message translates to:
  /// **'Meet at arrivals, {time}. Hold an iyodriver name sign for {name}.'**
  String meetLine(String time, String name);

  /// No description provided for @prepareCarNote.
  ///
  /// In en, this message translates to:
  /// **'Prepare a clean car with a full tank. Allow {minutes} min after landing and contact {name} if the flight is delayed.'**
  String prepareCarNote(String minutes, String name);

  /// No description provided for @prepareCarNoteAddress.
  ///
  /// In en, this message translates to:
  /// **'Prepare a clean car with a full tank. Call {name} if you are running late.'**
  String prepareCarNoteAddress(String name);

  /// No description provided for @navigateToPlace.
  ///
  /// In en, this message translates to:
  /// **'Navigate to {place}'**
  String navigateToPlace(String place);

  /// No description provided for @openHandover.
  ///
  /// In en, this message translates to:
  /// **'Start the handover'**
  String get openHandover;

  /// No description provided for @askHandoverPin.
  ///
  /// In en, this message translates to:
  /// **'Ask for the handover PIN at the car'**
  String get askHandoverPin;

  /// No description provided for @smoothHandover.
  ///
  /// In en, this message translates to:
  /// **'A smooth handover'**
  String get smoothHandover;

  /// No description provided for @handoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {place} · {date}'**
  String handoverSubtitle(String name, String place, String date);

  /// No description provided for @carPlateBadge.
  ///
  /// In en, this message translates to:
  /// **'{car} · {plate}'**
  String carPlateBadge(String car, String plate);

  /// No description provided for @checkIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity & licence checked'**
  String get checkIdentity;

  /// No description provided for @checkIdentityBody.
  ///
  /// In en, this message translates to:
  /// **'Name matches the booking'**
  String get checkIdentityBody;

  /// No description provided for @checkIdentityTap.
  ///
  /// In en, this message translates to:
  /// **'Tap once you have seen the ID and licence'**
  String get checkIdentityTap;

  /// No description provided for @checkDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit authorised'**
  String get checkDeposit;

  /// No description provided for @checkDepositBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} hold · {method}'**
  String checkDepositBody(String amount, String method);

  /// No description provided for @checkPhotos.
  ///
  /// In en, this message translates to:
  /// **'Vehicle condition photos'**
  String get checkPhotos;

  /// No description provided for @checkPhotosDone.
  ///
  /// In en, this message translates to:
  /// **'{n} photos saved · {damage}'**
  String checkPhotosDone(String n, String damage);

  /// No description provided for @checkPhotosTodo.
  ///
  /// In en, this message translates to:
  /// **'Take the 5 photos'**
  String get checkPhotosTodo;

  /// No description provided for @noNewDamage.
  ///
  /// In en, this message translates to:
  /// **'No new damage'**
  String get noNewDamage;

  /// No description provided for @damageNoted.
  ///
  /// In en, this message translates to:
  /// **'Damage noted'**
  String get damageNoted;

  /// No description provided for @checkFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel & mileage recorded'**
  String get checkFuel;

  /// No description provided for @checkFuelDone.
  ///
  /// In en, this message translates to:
  /// **'{fuel} · {km} km'**
  String checkFuelDone(String fuel, String km);

  /// No description provided for @checkFuelTodo.
  ///
  /// In en, this message translates to:
  /// **'Recorded with the photos'**
  String get checkFuelTodo;

  /// No description provided for @fullTank.
  ///
  /// In en, this message translates to:
  /// **'Full tank'**
  String get fullTank;

  /// No description provided for @tankEighths.
  ///
  /// In en, this message translates to:
  /// **'{n}/8 tank'**
  String tankEighths(String n);

  /// No description provided for @customerHandoverPin.
  ///
  /// In en, this message translates to:
  /// **'Customer handover PIN'**
  String get customerHandoverPin;

  /// No description provided for @handoverPinVerified.
  ///
  /// In en, this message translates to:
  /// **'✓ PIN verified · Rental agreement accepted'**
  String get handoverPinVerified;

  /// No description provided for @handoverReturnNote.
  ///
  /// In en, this message translates to:
  /// **'Return: {when} · {place}. Give {name} the keys after confirming all checks.'**
  String handoverReturnNote(String when, String place, String name);

  /// No description provided for @confirmHandoverStart.
  ///
  /// In en, this message translates to:
  /// **'Confirm handover & start rental'**
  String get confirmHandoverStart;

  /// No description provided for @handoverPinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN · {n} attempts left'**
  String handoverPinWrong(String n);

  /// No description provided for @handoverPinLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong PINs. The safety team has been told; call support.'**
  String get handoverPinLocked;

  /// No description provided for @handoverDone.
  ///
  /// In en, this message translates to:
  /// **'Handover complete. The rental has started.'**
  String get handoverDone;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
