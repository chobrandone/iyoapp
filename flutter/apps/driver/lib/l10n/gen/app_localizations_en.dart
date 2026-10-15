// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get placeholderBadge => 'Driver';

  @override
  String get placeholderFlowLabel => 'Driver · 00';

  @override
  String get placeholderTitle => 'Drive with iyodriver. Earn on your schedule.';

  @override
  String get placeholderSubtitle => 'Accept rides and rental handovers in Douala and Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Today\'s earnings: $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Local time (Douala): $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Payout number: $phone';
  }

  @override
  String get placeholderPrimary => 'Get started';

  @override
  String get placeholderSecondary => 'Switch to Français';

  @override
  String get badge => 'Driver';

  @override
  String flow(String step) {
    return 'Driver · $step';
  }

  @override
  String get flowPlain => 'Driver';

  @override
  String get tabHome => 'Home';

  @override
  String get tabEarnings => 'Earnings';

  @override
  String get tabBookings => 'Bookings';

  @override
  String get tabAccount => 'Account';

  @override
  String get safety => 'Safety';

  @override
  String get welcomeHeroTitle => 'Drive.\nEarn.';

  @override
  String get welcomeBadge => 'Rides + rental handovers';

  @override
  String get welcomeHeadline => 'Drive with iyodriver.\nEarn on your schedule.';

  @override
  String get welcomeBody =>
      'Accept rides and rental handovers in Douala and Yaoundé, and get paid to your mobile money.';

  @override
  String get getStarted => 'Get started';

  @override
  String get alreadyDriver => 'Already a driver?';

  @override
  String get logIn => 'Log in';

  @override
  String get signUpTitle => 'Create your driver account';

  @override
  String get signUpSubtitle => 'We\'ll check your documents before your first ride.';

  @override
  String get fieldFullName => 'Full name (as on your ID)';

  @override
  String get fieldMobile => 'Mobile number';

  @override
  String get agreeTerms => 'I agree to the Driver Terms and Privacy Policy.';

  @override
  String get createAndVerify => 'Create account & verify';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in with your mobile number. We\'ll text you a code.';

  @override
  String get sendCode => 'Send code';

  @override
  String get newDriver => 'New driver?';

  @override
  String get createAccount => 'Create an account';

  @override
  String get verifyTitle => 'Check your messages';

  @override
  String verifySubtitle(String phone) {
    return 'Enter the code sent to $phone.';
  }

  @override
  String demoCodeHint(String code) {
    return 'Demo mode · use code $code';
  }

  @override
  String resendIn(String time) {
    return 'Didn\'t get a code? Resend in $time';
  }

  @override
  String get resendNow => 'Didn\'t get a code? Resend';

  @override
  String get wrongNumber => 'Wrong number? Change it';

  @override
  String get verifyContinue => 'Verify & continue';

  @override
  String get otpInvalid => 'That code is not right. Check the SMS and try again.';

  @override
  String get wrongApp =>
      'This number is registered as a rider. Use the iyodriver app to book rides.';

  @override
  String get identityTitle => 'Identity and vehicle';

  @override
  String get identitySubtitle => 'Tell us who you are and what you drive.';

  @override
  String stepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get fieldCity => 'City';

  @override
  String get fieldLicence => 'Driving licence number';

  @override
  String get fieldNationalId => 'National ID card number (CNI)';

  @override
  String get vehicleSection => 'Your vehicle';

  @override
  String get fieldMake => 'Make';

  @override
  String get fieldModel => 'Model';

  @override
  String get fieldYear => 'Year';

  @override
  String get fieldColor => 'Colour';

  @override
  String get fieldPlate => 'Number plate';

  @override
  String get plateHelper => 'Format: LT 123 AB';

  @override
  String get plateInvalid => 'Enter a plate like LT 123 AB.';

  @override
  String get yearInvalid => 'Enter a year between 1990 and next year.';

  @override
  String get fieldCategory => 'Ride category';

  @override
  String get categoryStandard => 'Standard · 4 seats';

  @override
  String get categoryComfort => 'Comfort · 4 seats';

  @override
  String get categoryXl => 'XL · 6 seats';

  @override
  String get continueToDocuments => 'Continue to documents';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get documentsSubtitle =>
      'Take a clear photo of each document. We review them within 24 hours.';

  @override
  String get docNationalIdFront => 'National ID · front';

  @override
  String get docNationalIdBack => 'National ID · back';

  @override
  String get docDrivingLicence => 'Driving licence';

  @override
  String get docVehicleRegistration => 'Vehicle registration (carte grise)';

  @override
  String get docInsurance => 'Insurance certificate';

  @override
  String get docRoadworthiness => 'Roadworthiness (visite technique)';

  @override
  String get docProfilePhoto => 'Profile photo';

  @override
  String get docMissing => 'Not uploaded';

  @override
  String docUploading(String percent) {
    return 'Uploading… $percent%';
  }

  @override
  String get docPending => 'Uploaded · waiting for review';

  @override
  String get docApproved => 'Approved';

  @override
  String docRejected(String reason) {
    return 'Rejected · $reason';
  }

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get submitForReview => 'Submit for review';

  @override
  String get documentsMissingError => 'Upload every document before submitting.';

  @override
  String get reviewTitle => 'Under review';

  @override
  String get reviewSubtitle =>
      'We\'re checking your documents. You\'ll get a notification when it\'s done.';

  @override
  String get reviewDemo => 'Demo mode: approval is simulated in a few seconds.';

  @override
  String get actionNeededTitle => 'Action needed';

  @override
  String get actionNeededSubtitle => 'One or more documents need to be uploaded again.';

  @override
  String get fixDocuments => 'Update documents';

  @override
  String get approvedTitle => 'You\'re approved';

  @override
  String get approvedSubtitle => 'Welcome to iyodriver. You can go online and accept rides.';

  @override
  String get startDriving => 'Start driving';

  @override
  String get offlineTitle => 'You\'re offline';

  @override
  String get offlineSubtitle => 'Go online to start receiving ride requests.';

  @override
  String get onlineTitle => 'You\'re online';

  @override
  String get onlineSubtitle => 'Looking for rides near you.';

  @override
  String get goOnline => 'Go online';

  @override
  String get goOffline => 'Go offline';

  @override
  String get acceptingRequests => 'Accepting ride requests';

  @override
  String get busyAreaTitle => 'You\'re in a busy area';

  @override
  String get busyAreaBody =>
      'Akwa & Bonanjo · Stay nearby for your next ride. Keep your phone mounted safely.';

  @override
  String get today => 'Today';

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips',
      one: '1 trip',
    );
    return '$_temp0';
  }

  @override
  String onlineFor(String time) {
    return '$time online';
  }

  @override
  String get rating => 'Rating';

  @override
  String get lastTrips => 'Last 100 trips';

  @override
  String get locationNeeded => 'Location is needed to go online';

  @override
  String get locationNeededBody =>
      'Allow location \"all the time\" so riders can find you while you are online.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get onlineNotificationTitle => 'You\'re online';

  @override
  String get onlineNotificationBody => 'iyodriver is sharing your location with nearby riders.';

  @override
  String get newRequest => 'New ride request';

  @override
  String pickupIn(String minutes, String distance) {
    return 'Pickup · $minutes min · $distance';
  }

  @override
  String tripLength(String distance, String minutes) {
    return 'Trip · $distance · about $minutes min';
  }

  @override
  String youEarn(String amount) {
    return 'You earn $amount';
  }

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String secondsLeft(String seconds) {
    return '$seconds s to accept';
  }

  @override
  String toPickupTitle(String name) {
    return 'Pick up $name';
  }

  @override
  String toPickupSubtitle(String place, String minutes) {
    return '$place · $minutes min away';
  }

  @override
  String get navigate => 'Navigate';

  @override
  String get imHere => 'I\'ve arrived';

  @override
  String get cancelRide => 'Cancel ride';

  @override
  String get cancelTitle => 'Cancel this ride?';

  @override
  String get cancelBody => 'Frequent cancellations lower your acceptance rate.';

  @override
  String get cancelReasonNoShow => 'Rider did not show up';

  @override
  String get cancelReasonUnsafe => 'I feel unsafe';

  @override
  String get cancelReasonVehicle => 'Vehicle problem';

  @override
  String get cancelReasonOther => 'Other reason';

  @override
  String get keepRide => 'Keep the ride';

  @override
  String arrivedTitle(String name) {
    return 'Waiting for $name';
  }

  @override
  String waitTime(String time) {
    return 'Wait time · $time';
  }

  @override
  String pinLabel(String name) {
    return 'Ask $name for their 4-digit pickup PIN';
  }

  @override
  String pinWrong(String count) {
    return 'Wrong PIN · $count attempts left';
  }

  @override
  String get pinLocked => 'PIN locked after too many attempts. Support has been alerted.';

  @override
  String pinDemoHint(String pin) {
    return 'Demo mode · the rider PIN is $pin';
  }

  @override
  String get startRide => 'Start ride';

  @override
  String liveTitle(String place) {
    return 'Drive to $place';
  }

  @override
  String liveSubtitle(String minutes, String distance) {
    return '$minutes min · $distance left';
  }

  @override
  String get completeRide => 'Complete ride';

  @override
  String get completeTitle => 'Ride complete';

  @override
  String completeSubtitle(String place, String payment) {
    return '$place · $payment';
  }

  @override
  String get earnings => 'Your earnings';

  @override
  String get fare => 'Fare';

  @override
  String get commission => 'iyodriver commission';

  @override
  String collectCash(String amount, String name) {
    return 'Collect $amount in cash from $name';
  }

  @override
  String rateRider(String name) {
    return 'How was $name?';
  }

  @override
  String get done => 'Done';

  @override
  String get riderCancelled => 'The rider cancelled';

  @override
  String get riderCancelledBody => 'You will not be charged for this ride.';

  @override
  String get backHome => 'Back to home';

  @override
  String chatWith(String name) {
    return 'Chat with $name';
  }

  @override
  String get chatPrivacy => 'Your phone number stays private.';

  @override
  String get writeMessage => 'Write a message…';

  @override
  String get send => 'Send';

  @override
  String callRider(String name) {
    return 'Call $name';
  }

  @override
  String messageRider(String name) {
    return 'Message $name';
  }

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentMtn => 'MTN MoMo';

  @override
  String get paymentOrange => 'Orange Money';

  @override
  String get paymentCard => 'Card';

  @override
  String riderRating(String rating) {
    return '★ $rating · Verified rider';
  }

  @override
  String get earningsTitle => 'Earnings';

  @override
  String get earningsSubtitle => 'Paid to your mobile money every week.';

  @override
  String get recentTrips => 'Recent trips';

  @override
  String get noTripsTitle => 'No trips yet';

  @override
  String get noTripsBody => 'Go online to receive your first ride request.';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get bookingsSubtitle => 'Your trips and rental handovers.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubtitle => 'Profile, vehicle and payouts.';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get language => 'Language';

  @override
  String get signOut => 'Sign out';

  @override
  String get componentGallery => 'Component gallery (dev)';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';
}
