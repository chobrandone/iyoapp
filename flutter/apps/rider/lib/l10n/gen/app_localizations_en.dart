// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get placeholderFlowLabel => 'Rider · 00';

  @override
  String get placeholderTitle => 'Your city. Your way.';

  @override
  String get placeholderSubtitle => 'Rides and car rentals across Douala and Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Sample fare: $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Local time (Douala): $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Support line: $phone';
  }

  @override
  String get placeholderPrimary => 'Get started';

  @override
  String get placeholderSecondary => 'Switch to Français';

  @override
  String flowStart(String step) {
    return 'Start · $step';
  }

  @override
  String flowAccount(String step) {
    return 'Account · $step';
  }

  @override
  String flowRider(String step) {
    return 'Rider · $step';
  }

  @override
  String get flowRiderPlain => 'Rider';

  @override
  String get flowSafety => 'Rider · Safety';

  @override
  String get flowSafetySent => 'Rider · Safety sent';

  @override
  String get tabHome => 'Home';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabSafety => 'Safety';

  @override
  String get tabAccount => 'Account';

  @override
  String get recenterMap => 'Recenter map';

  @override
  String ratingTrips(String rating, String trips) {
    return '★ $rating · $trips trips';
  }

  @override
  String callPerson(String name) {
    return 'Call $name';
  }

  @override
  String messagePerson(String name) {
    return 'Message $name';
  }

  @override
  String get tileMessage => 'Message';

  @override
  String get tileShareTrip => 'Share trip';

  @override
  String get tileSafety => 'Safety';

  @override
  String get read => 'Read';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get writeMessage => 'Write a message…';

  @override
  String get send => 'Send';

  @override
  String get attach => 'Attach';

  @override
  String get welcomeHeroTitle => 'Your city.\nYour way.';

  @override
  String get welcomeBadge => 'Rides + rentals';

  @override
  String get welcomeHeadline => 'A little less waiting.\nA lot more going.';

  @override
  String get welcomeBody => 'Book a ride or find a car for a few days. Wherever life takes you, go with iyodriver.';

  @override
  String get welcomeGetStarted => 'Get started';

  @override
  String get welcomeHaveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log in';

  @override
  String get signUpTitle => 'Let\'s get acquainted';

  @override
  String get signUpSubtitle => 'A few details, and you\'re ready to go.';

  @override
  String get signUpBadge => 'Rider account';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldEmail => 'Email address';

  @override
  String get fieldEmailHelper => 'Receipts and rental confirmations go here.';

  @override
  String get fieldMobile => 'Mobile number';

  @override
  String get fieldPassword => 'Password';

  @override
  String get passwordRule => '✓ 8+ characters, a number and a symbol';

  @override
  String get showPassword => 'Show password';

  @override
  String get agreeTerms => 'I agree to the Terms of Service and Privacy Policy.';

  @override
  String get alreadyRegistered => 'Already registered?';

  @override
  String get createAndVerify => 'Create account & verify';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in with your mobile number. We\'ll text you a code.';

  @override
  String get loginSendCode => 'Send code';

  @override
  String get noAccount => 'New to iyodriver?';

  @override
  String get createAccount => 'Create an account';

  @override
  String get verifyTitle => 'Check your messages';

  @override
  String verifySubtitle(String phone) {
    return 'Enter the code sent to $phone.';
  }

  @override
  String get otpLabel => 'Verification code';

  @override
  String resendIn(String time) {
    return 'Didn\'t get a code? Resend in $time';
  }

  @override
  String get resendNow => 'Didn\'t get a code? Resend';

  @override
  String get wrongNumber => 'Wrong number?';

  @override
  String get changeIt => 'Change it';

  @override
  String get saferStartTitle => 'A safer start';

  @override
  String get saferStartBody => 'Verification helps keep every iyodriver journey connected to a real person.';

  @override
  String get verifyContinue => 'Verify & continue';

  @override
  String homeGreeting(String name) {
    return 'Where to, $name?';
  }

  @override
  String homeYouAreAt(String place) {
    return 'You\'re at $place';
  }

  @override
  String get serviceRide => 'Ride';

  @override
  String get serviceRent => 'Rent a car';

  @override
  String get whereTo => 'Where are you going?';

  @override
  String get savedHome => 'Home';

  @override
  String get savedWork => 'Work';

  @override
  String recentDestination(String area) {
    return 'Recent destination · $area';
  }

  @override
  String nearbyRides(String fare, String minutes) {
    return 'Nearby rides from $fare · Pickup in about $minutes min';
  }

  @override
  String get planTitle => 'Plan your ride';

  @override
  String get planSubtitle => 'Confirm where we\'ll meet you.';

  @override
  String get fieldPickup => 'Pickup';

  @override
  String get fieldDestination => 'Destination';

  @override
  String get currentLocation => '✓ Current location';

  @override
  String get editPickup => 'Edit pickup';

  @override
  String get whenWho => 'Now · 1 rider';

  @override
  String routeSummary(String distance, String minutes) {
    return '$distance · About $minutes minutes in current traffic';
  }

  @override
  String get confirmRoute => 'Confirm route';

  @override
  String arrivingTitle(String name) {
    return '$name is on the way';
  }

  @override
  String arrivingSubtitle(String minutes, String distance) {
    return 'Arriving in $minutes min · $distance away';
  }

  @override
  String pickupPin(String pin) {
    return 'Your pickup PIN · $pin';
  }

  @override
  String pinCardBody(String place, String name) {
    return 'Meet at $place. Share this PIN with $name before starting your ride.';
  }

  @override
  String get checkPlate => 'Check the number plate and driver before getting in.';

  @override
  String standardFare(String fare) {
    return 'Standard fare · $fare';
  }

  @override
  String get viewPickupDetails => 'View pickup details';

  @override
  String get onWayTitle => 'You\'re on your way';

  @override
  String arriveAt(String place, String time) {
    return '$place · Arrive $time';
  }

  @override
  String timeLeft(String minutes, String distance) {
    return '$minutes min left · $distance';
  }

  @override
  String tripFooter(String fare, String method, String trip) {
    return '$fare · $method · Trip $trip';
  }

  @override
  String get arrivedTitle => 'You\'ve arrived';

  @override
  String get arrivedSubtitle => 'Thanks for riding with iyodriver.';

  @override
  String get paymentComplete => '✓ Payment complete';

  @override
  String get rideFare => 'Ride fare';

  @override
  String get bookingFee => 'Booking fee';

  @override
  String receiptSent(String method) {
    return '$method · Receipt sent to your email';
  }

  @override
  String get howWasRide => 'How was your ride?';

  @override
  String starsLabel(String count) {
    return '$count of 5 stars';
  }

  @override
  String get noTip => 'No tip';

  @override
  String get submitRating => 'Submit rating & finish';

  @override
  String chatWith(String name) {
    return 'Chat with $name';
  }

  @override
  String chatSubtitle(String ride, String place) {
    return '$ride · Pickup at $place';
  }

  @override
  String arrivingIn(String minutes) {
    return 'Arriving in $minutes min';
  }

  @override
  String get privacyNote => 'Today · Your phone number stays private.';

  @override
  String get imHere => 'I\'m here';

  @override
  String get callDriver => 'Call driver';

  @override
  String chatFooter(String number) {
    return 'Keep messages about your pickup. For urgent danger, call $number.';
  }

  @override
  String get noDriversTitle => 'No drivers nearby';

  @override
  String noDriversSubtitle(String area) {
    return 'There\'s high demand around $area right now.';
  }

  @override
  String get tryAgainShortly => 'Let\'s try again shortly';

  @override
  String get noMatchBody => 'We couldn\'t match your request with an available driver. You haven\'t been charged.';

  @override
  String toPlace(String place) {
    return 'To $place';
  }

  @override
  String get requestNotBooked => 'Request not booked';

  @override
  String get noDriversHint => 'Try a nearby pickup spot or request again in a few minutes. Availability can change quickly.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get changePickup => 'Change pickup';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Updates on your rides and rentals.';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get badgeNew => 'New';

  @override
  String get badgeRentalUpdate => 'Rental update';

  @override
  String get notificationsFooter => 'Manage push and email updates in your account.';

  @override
  String get activityTitle => 'Your activity';

  @override
  String get activitySubtitle => 'All your journeys, in one place.';

  @override
  String get filterRides => 'Rides';

  @override
  String get filterRentals => 'Rentals';

  @override
  String get upcomingRental => 'Upcoming rental';

  @override
  String get recentJourneys => 'Recent journeys';

  @override
  String perDay(String rate) {
    return '$rate / day';
  }

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get activityFooter => 'Select a journey to view its receipt or get help.';

  @override
  String get safetyTitle => 'Your safety comes first';

  @override
  String get safetySubtitle => 'Help is always within reach.';

  @override
  String activeTrip(String trip) {
    return 'Active trip · $trip';
  }

  @override
  String emergencyHelp(String number) {
    return 'Emergency help · Call $number';
  }

  @override
  String get emergencyHelpBody => 'For immediate danger or urgent medical help.';

  @override
  String get alertNotEmergency => 'An alert does not automatically call emergency services.';

  @override
  String get shareLiveTrip => 'Share live trip';

  @override
  String get shareLiveTripBody => 'Let someone follow your journey.';

  @override
  String get trustedContactSelected => 'Trusted contact · Selected';

  @override
  String get trustedContactHelper => 'Live location, driver, vehicle and trip link will be sent.';

  @override
  String get messagePreview => 'Message preview';

  @override
  String get defaultAlertMessage => 'I need help. Please check on me and follow my live iyodriver trip.';

  @override
  String currentLocationAt(String place) {
    return 'Current location: $place';
  }

  @override
  String get sendAlert => 'Send security alert';

  @override
  String get sendAlertFooter => 'Sends your live location and trip details to your trusted contact and iyodriver safety team.';

  @override
  String get alertSentTitle => 'Your alert has been sent';

  @override
  String get alertSentSubtitle => 'You\'re not alone. Stay somewhere safe.';

  @override
  String get alertActive => 'Security alert active';

  @override
  String sentTodayAt(String time) {
    return 'Sent today at $time';
  }

  @override
  String contactNotified(String name) {
    return '$name notified';
  }

  @override
  String get contactNotifiedBody => 'Message and live trip link delivered.';

  @override
  String get safetyTeamNotified => 'iyodriver safety team notified';

  @override
  String get safetyTeamBody => 'Your trip details and location were shared.';

  @override
  String get liveSharingOn => 'Live location sharing is on';

  @override
  String alertSentHint(String number) {
    return 'If you\'re in immediate danger, call $number. Your alert has not contacted emergency services.';
  }

  @override
  String callEmergency(String number) {
    return 'Call emergency services · $number';
  }

  @override
  String get returnToTrip => 'Return to live trip';

  @override
  String get savedTitle => 'Saved places';

  @override
  String get savedSubtitle => 'Less typing. More getting there.';

  @override
  String get otherFavourites => 'Other favourites';

  @override
  String get savedFooter => 'Tap a place to edit its name or address. Saved places are only visible to you.';

  @override
  String get addPlace => 'Add a place';

  @override
  String get tcTitle => 'Trusted contacts';

  @override
  String get tcSubtitle => 'Keep the people you trust in the loop.';

  @override
  String get shareJourney => 'Share your journey';

  @override
  String get shareJourneyBody1 => 'Send a live trip link to your contacts from any active ride.';

  @override
  String get shareJourneyBody2 => 'Contacts can see your route, driver and estimated arrival when you choose to share.';

  @override
  String yourContacts(String count, String max) {
    return 'Your contacts · $count of $max';
  }

  @override
  String get statusVerified => 'Verified';

  @override
  String get invitationPending => 'Invitation pending';

  @override
  String shareTripsWith(String name) {
    return 'Share trips with $name · On';
  }

  @override
  String get resendInvitation => 'Resend invitation';

  @override
  String get inControl => 'You\'re in control';

  @override
  String get inControlBody => 'Sharing starts only when you send a trip link. You can stop sharing or remove a contact at any time.';

  @override
  String tcFooter(String number) {
    return 'Trusted contacts are not emergency responders. For immediate danger, call $number.';
  }

  @override
  String get addTrustedContact => 'Add trusted contact';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletSubtitle => 'Simple, secure payments for every journey.';

  @override
  String get rideCredit => 'Ride credit';

  @override
  String get creditApplied => 'Applied automatically to your next ride.';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get badgeDefault => 'Default';

  @override
  String get cashMethod => 'Cash';

  @override
  String get cashBody => 'Pay your driver at the end of the ride';

  @override
  String walletNumber(String number) {
    return 'Wallet $number';
  }

  @override
  String get recentPayments => 'Recent payments';

  @override
  String get walletFooter => 'Rental deposits are temporary holds, not charges.';

  @override
  String get addPaymentMethod => 'Add payment method';

  @override
  String get supportTitle => 'iyodriver support';

  @override
  String supportSubtitle(String caseId, String topic) {
    return 'Case $caseId · $topic';
  }

  @override
  String supportAgent(String name) {
    return '$name · Support specialist';
  }

  @override
  String get repliesWithin => 'Usually replies within a few minutes';

  @override
  String get conversationOpen => 'Conversation open';

  @override
  String supportFooter(String number) {
    return 'This chat is not an emergency service. If you are in immediate danger, call $number.';
  }

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubtitle => 'Your profile, payments and safety settings.';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuWallet => 'Wallet';

  @override
  String get menuSavedPlaces => 'Saved places';

  @override
  String get menuTrustedContacts => 'Trusted contacts';

  @override
  String get menuSupport => 'Help & support';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuScreens => 'All screens (dev)';
}
