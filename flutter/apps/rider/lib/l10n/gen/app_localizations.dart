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

  /// No description provided for @placeholderFlowLabel.
  ///
  /// In en, this message translates to:
  /// **'Rider · 00'**
  String get placeholderFlowLabel;

  /// No description provided for @placeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your city. Your way.'**
  String get placeholderTitle;

  /// No description provided for @placeholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rides and car rentals across Douala and Yaoundé.'**
  String get placeholderSubtitle;

  /// No description provided for @placeholderSampleFare.
  ///
  /// In en, this message translates to:
  /// **'Sample fare: {fare}'**
  String placeholderSampleFare(String fare);

  /// No description provided for @placeholderSampleTime.
  ///
  /// In en, this message translates to:
  /// **'Local time (Douala): {time}'**
  String placeholderSampleTime(String time);

  /// No description provided for @placeholderSamplePhone.
  ///
  /// In en, this message translates to:
  /// **'Support line: {phone}'**
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

  /// No description provided for @flowStart.
  ///
  /// In en, this message translates to:
  /// **'Start · {step}'**
  String flowStart(String step);

  /// No description provided for @flowAccount.
  ///
  /// In en, this message translates to:
  /// **'Account · {step}'**
  String flowAccount(String step);

  /// No description provided for @flowRider.
  ///
  /// In en, this message translates to:
  /// **'Rider · {step}'**
  String flowRider(String step);

  /// No description provided for @flowRiderPlain.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get flowRiderPlain;

  /// No description provided for @flowSafety.
  ///
  /// In en, this message translates to:
  /// **'Rider · Safety'**
  String get flowSafety;

  /// No description provided for @flowSafetySent.
  ///
  /// In en, this message translates to:
  /// **'Rider · Safety sent'**
  String get flowSafetySent;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// No description provided for @tabSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get tabSafety;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @recenterMap.
  ///
  /// In en, this message translates to:
  /// **'Recenter map'**
  String get recenterMap;

  /// No description provided for @ratingTrips.
  ///
  /// In en, this message translates to:
  /// **'★ {rating} · {trips} trips'**
  String ratingTrips(String rating, String trips);

  /// No description provided for @callPerson.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String callPerson(String name);

  /// No description provided for @messagePerson.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String messagePerson(String name);

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

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

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

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @welcomeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your city.\nYour way.'**
  String get welcomeHeroTitle;

  /// No description provided for @welcomeBadge.
  ///
  /// In en, this message translates to:
  /// **'Rides + rentals'**
  String get welcomeBadge;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'A little less waiting.\nA lot more going.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Book a ride or find a car for a few days. Wherever life takes you, go with iyodriver.'**
  String get welcomeBody;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get welcomeHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get acquainted'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few details, and you\'re ready to go.'**
  String get signUpSubtitle;

  /// No description provided for @signUpBadge.
  ///
  /// In en, this message translates to:
  /// **'Rider account'**
  String get signUpBadge;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get fieldEmail;

  /// No description provided for @fieldEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'Receipts and rental confirmations go here.'**
  String get fieldEmailHelper;

  /// No description provided for @fieldMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get fieldMobile;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @passwordRule.
  ///
  /// In en, this message translates to:
  /// **'✓ 8+ characters, a number and a symbol'**
  String get passwordRule;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get agreeTerms;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered?'**
  String get alreadyRegistered;

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

  /// No description provided for @loginSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get loginSendCode;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New to iyodriver?'**
  String get noAccount;

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

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpLabel;

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
  /// **'Wrong number?'**
  String get wrongNumber;

  /// No description provided for @changeIt.
  ///
  /// In en, this message translates to:
  /// **'Change it'**
  String get changeIt;

  /// No description provided for @saferStartTitle.
  ///
  /// In en, this message translates to:
  /// **'A safer start'**
  String get saferStartTitle;

  /// No description provided for @saferStartBody.
  ///
  /// In en, this message translates to:
  /// **'Verification helps keep every iyodriver journey connected to a real person.'**
  String get saferStartBody;

  /// No description provided for @verifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & continue'**
  String get verifyContinue;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Where to, {name}?'**
  String homeGreeting(String name);

  /// No description provided for @homeYouAreAt.
  ///
  /// In en, this message translates to:
  /// **'You\'re at {place}'**
  String homeYouAreAt(String place);

  /// No description provided for @serviceRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get serviceRide;

  /// No description provided for @serviceRent.
  ///
  /// In en, this message translates to:
  /// **'Rent a car'**
  String get serviceRent;

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereTo;

  /// No description provided for @savedHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get savedHome;

  /// No description provided for @savedWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get savedWork;

  /// No description provided for @recentDestination.
  ///
  /// In en, this message translates to:
  /// **'Recent destination · {area}'**
  String recentDestination(String area);

  /// No description provided for @nearbyRides.
  ///
  /// In en, this message translates to:
  /// **'Nearby rides from {fare} · Pickup in about {minutes} min'**
  String nearbyRides(String fare, String minutes);

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your ride'**
  String get planTitle;

  /// No description provided for @planSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm where we\'ll meet you.'**
  String get planSubtitle;

  /// No description provided for @fieldPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get fieldPickup;

  /// No description provided for @fieldDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get fieldDestination;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'✓ Current location'**
  String get currentLocation;

  /// No description provided for @editPickup.
  ///
  /// In en, this message translates to:
  /// **'Edit pickup'**
  String get editPickup;

  /// No description provided for @whenWho.
  ///
  /// In en, this message translates to:
  /// **'Now · 1 rider'**
  String get whenWho;

  /// No description provided for @routeSummary.
  ///
  /// In en, this message translates to:
  /// **'{distance} · About {minutes} minutes in current traffic'**
  String routeSummary(String distance, String minutes);

  /// No description provided for @confirmRoute.
  ///
  /// In en, this message translates to:
  /// **'Confirm route'**
  String get confirmRoute;

  /// No description provided for @arrivingTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is on the way'**
  String arrivingTitle(String name);

  /// No description provided for @arrivingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arriving in {minutes} min · {distance} away'**
  String arrivingSubtitle(String minutes, String distance);

  /// No description provided for @pickupPin.
  ///
  /// In en, this message translates to:
  /// **'Your pickup PIN · {pin}'**
  String pickupPin(String pin);

  /// No description provided for @pinCardBody.
  ///
  /// In en, this message translates to:
  /// **'Meet at {place}. Share this PIN with {name} before starting your ride.'**
  String pinCardBody(String place, String name);

  /// No description provided for @checkPlate.
  ///
  /// In en, this message translates to:
  /// **'Check the number plate and driver before getting in.'**
  String get checkPlate;

  /// No description provided for @standardFare.
  ///
  /// In en, this message translates to:
  /// **'Standard fare · {fare}'**
  String standardFare(String fare);

  /// No description provided for @viewPickupDetails.
  ///
  /// In en, this message translates to:
  /// **'View pickup details'**
  String get viewPickupDetails;

  /// No description provided for @onWayTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re on your way'**
  String get onWayTitle;

  /// No description provided for @arriveAt.
  ///
  /// In en, this message translates to:
  /// **'{place} · Arrive {time}'**
  String arriveAt(String place, String time);

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left · {distance}'**
  String timeLeft(String minutes, String distance);

  /// No description provided for @tripFooter.
  ///
  /// In en, this message translates to:
  /// **'{fare} · {method} · Trip {trip}'**
  String tripFooter(String fare, String method, String trip);

  /// No description provided for @arrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve arrived'**
  String get arrivedTitle;

  /// No description provided for @arrivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks for riding with iyodriver.'**
  String get arrivedSubtitle;

  /// No description provided for @paymentComplete.
  ///
  /// In en, this message translates to:
  /// **'✓ Payment complete'**
  String get paymentComplete;

  /// No description provided for @rideFare.
  ///
  /// In en, this message translates to:
  /// **'Ride fare'**
  String get rideFare;

  /// No description provided for @bookingFee.
  ///
  /// In en, this message translates to:
  /// **'Booking fee'**
  String get bookingFee;

  /// No description provided for @receiptSent.
  ///
  /// In en, this message translates to:
  /// **'{method} · Receipt sent to your email'**
  String receiptSent(String method);

  /// No description provided for @howWasRide.
  ///
  /// In en, this message translates to:
  /// **'How was your ride?'**
  String get howWasRide;

  /// No description provided for @starsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} of 5 stars'**
  String starsLabel(String count);

  /// No description provided for @noTip.
  ///
  /// In en, this message translates to:
  /// **'No tip'**
  String get noTip;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit rating & finish'**
  String get submitRating;

  /// No description provided for @chatWith.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String chatWith(String name);

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{ride} · Pickup at {place}'**
  String chatSubtitle(String ride, String place);

  /// No description provided for @arrivingIn.
  ///
  /// In en, this message translates to:
  /// **'Arriving in {minutes} min'**
  String arrivingIn(String minutes);

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Today · Your phone number stays private.'**
  String get privacyNote;

  /// No description provided for @imHere.
  ///
  /// In en, this message translates to:
  /// **'I\'m here'**
  String get imHere;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call driver'**
  String get callDriver;

  /// No description provided for @chatFooter.
  ///
  /// In en, this message translates to:
  /// **'Keep messages about your pickup. For urgent danger, call {number}.'**
  String chatFooter(String number);

  /// No description provided for @noDriversTitle.
  ///
  /// In en, this message translates to:
  /// **'No drivers nearby'**
  String get noDriversTitle;

  /// No description provided for @noDriversSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There\'s high demand around {area} right now.'**
  String noDriversSubtitle(String area);

  /// No description provided for @tryAgainShortly.
  ///
  /// In en, this message translates to:
  /// **'Let\'s try again shortly'**
  String get tryAgainShortly;

  /// No description provided for @noMatchBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t match your request with an available driver. You haven\'t been charged.'**
  String get noMatchBody;

  /// No description provided for @toPlace.
  ///
  /// In en, this message translates to:
  /// **'To {place}'**
  String toPlace(String place);

  /// No description provided for @requestNotBooked.
  ///
  /// In en, this message translates to:
  /// **'Request not booked'**
  String get requestNotBooked;

  /// No description provided for @noDriversHint.
  ///
  /// In en, this message translates to:
  /// **'Try a nearby pickup spot or request again in a few minutes. Availability can change quickly.'**
  String get noDriversHint;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @changePickup.
  ///
  /// In en, this message translates to:
  /// **'Change pickup'**
  String get changePickup;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates on your rides and rentals.'**
  String get notificationsSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// No description provided for @badgeRentalUpdate.
  ///
  /// In en, this message translates to:
  /// **'Rental update'**
  String get badgeRentalUpdate;

  /// No description provided for @notificationsFooter.
  ///
  /// In en, this message translates to:
  /// **'Manage push and email updates in your account.'**
  String get notificationsFooter;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your activity'**
  String get activityTitle;

  /// No description provided for @activitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your journeys, in one place.'**
  String get activitySubtitle;

  /// No description provided for @filterRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get filterRides;

  /// No description provided for @filterRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get filterRentals;

  /// No description provided for @upcomingRental.
  ///
  /// In en, this message translates to:
  /// **'Upcoming rental'**
  String get upcomingRental;

  /// No description provided for @recentJourneys.
  ///
  /// In en, this message translates to:
  /// **'Recent journeys'**
  String get recentJourneys;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'{rate} / day'**
  String perDay(String rate);

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @activityFooter.
  ///
  /// In en, this message translates to:
  /// **'Select a journey to view its receipt or get help.'**
  String get activityFooter;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your safety comes first'**
  String get safetyTitle;

  /// No description provided for @safetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help is always within reach.'**
  String get safetySubtitle;

  /// No description provided for @activeTrip.
  ///
  /// In en, this message translates to:
  /// **'Active trip · {trip}'**
  String activeTrip(String trip);

  /// No description provided for @emergencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Emergency help · Call {number}'**
  String emergencyHelp(String number);

  /// No description provided for @emergencyHelpBody.
  ///
  /// In en, this message translates to:
  /// **'For immediate danger or urgent medical help.'**
  String get emergencyHelpBody;

  /// No description provided for @alertNotEmergency.
  ///
  /// In en, this message translates to:
  /// **'An alert does not automatically call emergency services.'**
  String get alertNotEmergency;

  /// No description provided for @shareLiveTrip.
  ///
  /// In en, this message translates to:
  /// **'Share live trip'**
  String get shareLiveTrip;

  /// No description provided for @shareLiveTripBody.
  ///
  /// In en, this message translates to:
  /// **'Let someone follow your journey.'**
  String get shareLiveTripBody;

  /// No description provided for @trustedContactSelected.
  ///
  /// In en, this message translates to:
  /// **'Trusted contact · Selected'**
  String get trustedContactSelected;

  /// No description provided for @trustedContactHelper.
  ///
  /// In en, this message translates to:
  /// **'Live location, driver, vehicle and trip link will be sent.'**
  String get trustedContactHelper;

  /// No description provided for @messagePreview.
  ///
  /// In en, this message translates to:
  /// **'Message preview'**
  String get messagePreview;

  /// No description provided for @defaultAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'I need help. Please check on me and follow my live iyodriver trip.'**
  String get defaultAlertMessage;

  /// No description provided for @currentLocationAt.
  ///
  /// In en, this message translates to:
  /// **'Current location: {place}'**
  String currentLocationAt(String place);

  /// No description provided for @sendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send security alert'**
  String get sendAlert;

  /// No description provided for @sendAlertFooter.
  ///
  /// In en, this message translates to:
  /// **'Sends your live location and trip details to your trusted contact and iyodriver safety team.'**
  String get sendAlertFooter;

  /// No description provided for @alertSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your alert has been sent'**
  String get alertSentTitle;

  /// No description provided for @alertSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re not alone. Stay somewhere safe.'**
  String get alertSentSubtitle;

  /// No description provided for @alertActive.
  ///
  /// In en, this message translates to:
  /// **'Security alert active'**
  String get alertActive;

  /// No description provided for @sentTodayAt.
  ///
  /// In en, this message translates to:
  /// **'Sent today at {time}'**
  String sentTodayAt(String time);

  /// No description provided for @contactNotified.
  ///
  /// In en, this message translates to:
  /// **'{name} notified'**
  String contactNotified(String name);

  /// No description provided for @contactNotifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Message and live trip link delivered.'**
  String get contactNotifiedBody;

  /// No description provided for @safetyTeamNotified.
  ///
  /// In en, this message translates to:
  /// **'iyodriver safety team notified'**
  String get safetyTeamNotified;

  /// No description provided for @safetyTeamBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip details and location were shared.'**
  String get safetyTeamBody;

  /// No description provided for @liveSharingOn.
  ///
  /// In en, this message translates to:
  /// **'Live location sharing is on'**
  String get liveSharingOn;

  /// No description provided for @alertSentHint.
  ///
  /// In en, this message translates to:
  /// **'If you\'re in immediate danger, call {number}. Your alert has not contacted emergency services.'**
  String alertSentHint(String number);

  /// No description provided for @callEmergency.
  ///
  /// In en, this message translates to:
  /// **'Call emergency services · {number}'**
  String callEmergency(String number);

  /// No description provided for @returnToTrip.
  ///
  /// In en, this message translates to:
  /// **'Return to live trip'**
  String get returnToTrip;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved places'**
  String get savedTitle;

  /// No description provided for @savedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Less typing. More getting there.'**
  String get savedSubtitle;

  /// No description provided for @otherFavourites.
  ///
  /// In en, this message translates to:
  /// **'Other favourites'**
  String get otherFavourites;

  /// No description provided for @savedFooter.
  ///
  /// In en, this message translates to:
  /// **'Tap a place to edit its name or address. Saved places are only visible to you.'**
  String get savedFooter;

  /// No description provided for @addPlace.
  ///
  /// In en, this message translates to:
  /// **'Add a place'**
  String get addPlace;

  /// No description provided for @tcTitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted contacts'**
  String get tcTitle;

  /// No description provided for @tcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the people you trust in the loop.'**
  String get tcSubtitle;

  /// No description provided for @shareJourney.
  ///
  /// In en, this message translates to:
  /// **'Share your journey'**
  String get shareJourney;

  /// No description provided for @shareJourneyBody1.
  ///
  /// In en, this message translates to:
  /// **'Send a live trip link to your contacts from any active ride.'**
  String get shareJourneyBody1;

  /// No description provided for @shareJourneyBody2.
  ///
  /// In en, this message translates to:
  /// **'Contacts can see your route, driver and estimated arrival when you choose to share.'**
  String get shareJourneyBody2;

  /// No description provided for @yourContacts.
  ///
  /// In en, this message translates to:
  /// **'Your contacts · {count} of {max}'**
  String yourContacts(String count, String max);

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @invitationPending.
  ///
  /// In en, this message translates to:
  /// **'Invitation pending'**
  String get invitationPending;

  /// No description provided for @shareTripsWith.
  ///
  /// In en, this message translates to:
  /// **'Share trips with {name} · On'**
  String shareTripsWith(String name);

  /// No description provided for @resendInvitation.
  ///
  /// In en, this message translates to:
  /// **'Resend invitation'**
  String get resendInvitation;

  /// No description provided for @inControl.
  ///
  /// In en, this message translates to:
  /// **'You\'re in control'**
  String get inControl;

  /// No description provided for @inControlBody.
  ///
  /// In en, this message translates to:
  /// **'Sharing starts only when you send a trip link. You can stop sharing or remove a contact at any time.'**
  String get inControlBody;

  /// No description provided for @tcFooter.
  ///
  /// In en, this message translates to:
  /// **'Trusted contacts are not emergency responders. For immediate danger, call {number}.'**
  String tcFooter(String number);

  /// No description provided for @addTrustedContact.
  ///
  /// In en, this message translates to:
  /// **'Add trusted contact'**
  String get addTrustedContact;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple, secure payments for every journey.'**
  String get walletSubtitle;

  /// No description provided for @rideCredit.
  ///
  /// In en, this message translates to:
  /// **'Ride credit'**
  String get rideCredit;

  /// No description provided for @creditApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied automatically to your next ride.'**
  String get creditApplied;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @badgeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get badgeDefault;

  /// No description provided for @cashMethod.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashMethod;

  /// No description provided for @cashBody.
  ///
  /// In en, this message translates to:
  /// **'Pay your driver at the end of the ride'**
  String get cashBody;

  /// No description provided for @walletNumber.
  ///
  /// In en, this message translates to:
  /// **'Wallet {number}'**
  String walletNumber(String number);

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent payments'**
  String get recentPayments;

  /// No description provided for @walletFooter.
  ///
  /// In en, this message translates to:
  /// **'Rental deposits are temporary holds, not charges.'**
  String get walletFooter;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get addPaymentMethod;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'iyodriver support'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Case {caseId} · {topic}'**
  String supportSubtitle(String caseId, String topic);

  /// No description provided for @supportAgent.
  ///
  /// In en, this message translates to:
  /// **'{name} · Support specialist'**
  String supportAgent(String name);

  /// No description provided for @repliesWithin.
  ///
  /// In en, this message translates to:
  /// **'Usually replies within a few minutes'**
  String get repliesWithin;

  /// No description provided for @conversationOpen.
  ///
  /// In en, this message translates to:
  /// **'Conversation open'**
  String get conversationOpen;

  /// No description provided for @supportFooter.
  ///
  /// In en, this message translates to:
  /// **'This chat is not an emergency service. If you are in immediate danger, call {number}.'**
  String supportFooter(String number);

  /// No description provided for @demoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Demo mode · use code {code}'**
  String demoCodeHint(String code);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Check the SMS and try again.'**
  String get otpInvalid;

  /// No description provided for @wrongApp.
  ///
  /// In en, this message translates to:
  /// **'This number is registered as a driver. Use the iyodriver Driver app.'**
  String get wrongApp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @currentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocationLabel;

  /// No description provided for @locatingYou.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get locatingYou;

  /// No description provided for @locationDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is off'**
  String get locationDeniedTitle;

  /// No description provided for @locationDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location so drivers can find you, or type your pickup address.'**
  String get locationDeniedBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @searchPlaces.
  ///
  /// In en, this message translates to:
  /// **'Search a place in Douala or Yaoundé'**
  String get searchPlaces;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No places found'**
  String get noPlacesFound;

  /// No description provided for @chooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a ride'**
  String get chooseTitle;

  /// No description provided for @chooseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{distance} · about {minutes} min to {place}'**
  String chooseSubtitle(String distance, String minutes, String place);

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String seats(String count);

  /// No description provided for @etaAway.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min away'**
  String etaAway(String minutes);

  /// No description provided for @noEta.
  ///
  /// In en, this message translates to:
  /// **'Limited availability'**
  String get noEta;

  /// No description provided for @upfrontPrice.
  ///
  /// In en, this message translates to:
  /// **'Upfront price · placeholder rates'**
  String get upfrontPrice;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @bookCategory.
  ///
  /// In en, this message translates to:
  /// **'Book {category} · {fare}'**
  String bookCategory(String category, String fare);

  /// No description provided for @quoteExpired.
  ///
  /// In en, this message translates to:
  /// **'Prices have changed. Here are fresh ones.'**
  String get quoteExpired;

  /// No description provided for @matchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Finding your driver'**
  String get matchingTitle;

  /// No description provided for @matchingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Asking drivers near {place}'**
  String matchingSubtitle(String place);

  /// No description provided for @matchingBody.
  ///
  /// In en, this message translates to:
  /// **'This usually takes less than a minute. Your price is fixed at {fare}.'**
  String matchingBody(String fare);

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @driverArrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} has arrived'**
  String driverArrivedTitle(String name);

  /// No description provided for @driverArrivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Meet at {place} and share your PIN'**
  String driverArrivedSubtitle(String place);

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
  /// **'Tell us why. No fee applies while the driver is on the way.'**
  String get cancelBody;

  /// No description provided for @cancelReasonWait.
  ///
  /// In en, this message translates to:
  /// **'Waiting too long'**
  String get cancelReasonWait;

  /// No description provided for @cancelReasonPlans.
  ///
  /// In en, this message translates to:
  /// **'My plans changed'**
  String get cancelReasonPlans;

  /// No description provided for @cancelReasonPickup.
  ///
  /// In en, this message translates to:
  /// **'Wrong pickup point'**
  String get cancelReasonPickup;

  /// No description provided for @cancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get cancelReasonOther;

  /// No description provided for @keepRide.
  ///
  /// In en, this message translates to:
  /// **'Keep my ride'**
  String get keepRide;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get confirmCancel;

  /// No description provided for @rideCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride cancelled'**
  String get rideCancelledTitle;

  /// No description provided for @rideCancelledByDriver.
  ///
  /// In en, this message translates to:
  /// **'Your driver cancelled. You have not been charged.'**
  String get rideCancelledByDriver;

  /// No description provided for @rideCancelledByYou.
  ///
  /// In en, this message translates to:
  /// **'You cancelled this ride.'**
  String get rideCancelledByYou;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

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

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile, payments and safety settings.'**
  String get accountSubtitle;

  /// No description provided for @menuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// No description provided for @menuWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get menuWallet;

  /// No description provided for @menuSavedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved places'**
  String get menuSavedPlaces;

  /// No description provided for @menuTrustedContacts.
  ///
  /// In en, this message translates to:
  /// **'Trusted contacts'**
  String get menuTrustedContacts;

  /// No description provided for @menuSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get menuSupport;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuScreens.
  ///
  /// In en, this message translates to:
  /// **'All screens (dev)'**
  String get menuScreens;
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
