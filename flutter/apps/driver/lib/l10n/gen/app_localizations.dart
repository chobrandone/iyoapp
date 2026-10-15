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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fr')];

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
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
