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
  String get welcomeBody =>
      'Book a ride or find a car for a few days. Wherever life takes you, go with iyodriver.';

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
  String get saferStartBody =>
      'Verification helps keep every iyodriver journey connected to a real person.';

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
  String get noMatchBody =>
      'We couldn\'t match your request with an available driver. You haven\'t been charged.';

  @override
  String toPlace(String place) {
    return 'To $place';
  }

  @override
  String get requestNotBooked => 'Request not booked';

  @override
  String get noDriversHint =>
      'Try a nearby pickup spot or request again in a few minutes. Availability can change quickly.';

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
  String get defaultAlertMessage =>
      'I need help. Please check on me and follow my live iyodriver trip.';

  @override
  String currentLocationAt(String place) {
    return 'Current location: $place';
  }

  @override
  String get sendAlert => 'Send security alert';

  @override
  String get sendAlertFooter =>
      'Sends your live location and trip details to your trusted contact and iyodriver safety team.';

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
  String get savedFooter =>
      'Tap a place to edit its name or address. Saved places are only visible to you.';

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
  String get shareJourneyBody2 =>
      'Contacts can see your route, driver and estimated arrival when you choose to share.';

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
  String get inControlBody =>
      'Sharing starts only when you send a trip link. You can stop sharing or remove a contact at any time.';

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
  String demoCodeHint(String code) {
    return 'Demo mode · use code $code';
  }

  @override
  String get otpInvalid => 'That code is not right. Check the SMS and try again.';

  @override
  String get wrongApp => 'This number is registered as a driver. Use the iyodriver Driver app.';

  @override
  String get signOut => 'Sign out';

  @override
  String get currentLocationLabel => 'Current location';

  @override
  String get locatingYou => 'Finding your location…';

  @override
  String get locationDeniedTitle => 'Location is off';

  @override
  String get locationDeniedBody =>
      'Allow location so drivers can find you, or type your pickup address.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get searchPlaces => 'Search a place in Douala or Yaoundé';

  @override
  String get noPlacesFound => 'No places found';

  @override
  String get chooseTitle => 'Choose a ride';

  @override
  String chooseSubtitle(String distance, String minutes, String place) {
    return '$distance · about $minutes min to $place';
  }

  @override
  String seats(String count) {
    return '$count seats';
  }

  @override
  String etaAway(String minutes) {
    return '$minutes min away';
  }

  @override
  String get noEta => 'Limited availability';

  @override
  String get upfrontPrice => 'Upfront price · placeholder rates';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String bookCategory(String category, String fare) {
    return 'Book $category · $fare';
  }

  @override
  String get quoteExpired => 'Prices have changed. Here are fresh ones.';

  @override
  String get matchingTitle => 'Finding your driver';

  @override
  String matchingSubtitle(String place) {
    return 'Asking drivers near $place';
  }

  @override
  String matchingBody(String fare) {
    return 'This usually takes less than a minute. Your price is fixed at $fare.';
  }

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String driverArrivedTitle(String name) {
    return '$name has arrived';
  }

  @override
  String driverArrivedSubtitle(String place) {
    return 'Meet at $place and share your PIN';
  }

  @override
  String get cancelRide => 'Cancel ride';

  @override
  String get cancelTitle => 'Cancel this ride?';

  @override
  String get cancelBody => 'Tell us why. No fee applies while the driver is on the way.';

  @override
  String get cancelReasonWait => 'Waiting too long';

  @override
  String get cancelReasonPlans => 'My plans changed';

  @override
  String get cancelReasonPickup => 'Wrong pickup point';

  @override
  String get cancelReasonOther => 'Other reason';

  @override
  String get keepRide => 'Keep my ride';

  @override
  String get confirmCancel => 'Cancel ride';

  @override
  String get rideCancelledTitle => 'Ride cancelled';

  @override
  String get rideCancelledByDriver => 'Your driver cancelled. You have not been charged.';

  @override
  String get rideCancelledByYou => 'You cancelled this ride.';

  @override
  String get backHome => 'Back to home';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentMtn => 'MTN MoMo';

  @override
  String get paymentOrange => 'Orange Money';

  @override
  String get paymentCard => 'Card';

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

  @override
  String get noActiveTrip => 'No active trip';

  @override
  String get emergencyCallTitle => 'Call emergency services';

  @override
  String get emergencyPolice => 'Police';

  @override
  String get emergencyFire => 'Fire brigade';

  @override
  String get emergencyAmbulance => 'Ambulance';

  @override
  String get shareNeedsTrip => 'Available during a trip.';

  @override
  String get shareTripSubject => 'My iyodriver trip';

  @override
  String shareTripText(String time, String link) {
    return 'Follow my iyodriver trip live (link valid until $time): $link';
  }

  @override
  String get shareFailed => 'Could not create a share link. Try again.';

  @override
  String get contactsToNotify => 'Trusted contacts to text';

  @override
  String get noContactsYet => 'No trusted contacts yet.';

  @override
  String get addContactLink => 'Add a trusted contact';

  @override
  String get locationUnknown => 'Current location unavailable';

  @override
  String alertFailed(String number) {
    return 'The alert could not be sent. Check your connection, or call $number.';
  }

  @override
  String contactsNotifiedCount(String count) {
    return '$count trusted contacts notified';
  }

  @override
  String get noContactNotified => 'No trusted contact was texted';

  @override
  String get noContactNotifiedBody => 'Add trusted contacts so we can text them next time.';

  @override
  String get alertsOn => 'Alerts on';

  @override
  String get alertsOff => 'Alerts off';

  @override
  String textOnAlert(String name) {
    return 'Text $name if I raise an alert';
  }

  @override
  String get removeContact => 'Remove';

  @override
  String removeContactTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeContactBody => 'They will no longer be texted when you raise an alert.';

  @override
  String get contactName => 'Full name';

  @override
  String get contactPhone => 'Mobile number';

  @override
  String get contactRelationship => 'Relationship (optional)';

  @override
  String get contactRelationshipHint => 'Sister, friend, colleague…';

  @override
  String get saveContact => 'Save contact';

  @override
  String contactLimit(String max) {
    return 'You can add up to $max trusted contacts.';
  }

  @override
  String get contactDuplicate => 'This number is already one of your trusted contacts.';

  @override
  String get contactsEmptyTitle => 'Add someone you trust';

  @override
  String get contactsEmptyBody =>
      'They get a text with your live trip if you raise a safety alert.';

  @override
  String get flowRent => 'Rider · Rent';

  @override
  String get rentHomeTitle => 'Rent a car';

  @override
  String get rentHomeBody => 'Daily rentals with delivery to your address or the airport.';

  @override
  String get browseCars => 'Browse cars';

  @override
  String get myRentals => 'My rentals';

  @override
  String get rentTitle => 'Rent a car';

  @override
  String get rentSubtitle => 'Pick a car, then your dates and where we hand it over.';

  @override
  String get cityDouala => 'Douala';

  @override
  String get cityYaounde => 'Yaoundé';

  @override
  String get noCarsTitle => 'No cars available';

  @override
  String get noCarsBody => 'Try the other city or check again later.';

  @override
  String get airportPickupBadge => 'Airport pickup';

  @override
  String get placeholderPricing =>
      'Prices shown are placeholders until the fleet rates are confirmed.';

  @override
  String get transmissionAutomatic => 'Automatic';

  @override
  String get transmissionManual => 'Manual';

  @override
  String get fuelPetrol => 'Petrol';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybrid';

  @override
  String get fuelElectric => 'Electric';

  @override
  String seatsCount(String count) {
    return '$count seats';
  }

  @override
  String get carSpecs => 'Car details';

  @override
  String get specDailyRate => 'Daily rate';

  @override
  String get specDeposit => 'Deposit (held at handover)';

  @override
  String get specKmPerDay => 'Included distance';

  @override
  String kmPerDayValue(String km) {
    return '$km km / day';
  }

  @override
  String get specExtraKm => 'Extra distance';

  @override
  String perKm(String price) {
    return '$price / km';
  }

  @override
  String get specPlate => 'Plate';

  @override
  String get chooseDates => 'Choose dates';

  @override
  String get datesTitle => 'Dates and pickup';

  @override
  String get datesSubtitle => 'Rentals are charged per started day (24 h).';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'Return';

  @override
  String get pickDate => 'Pick a date';

  @override
  String daysCount(String days) {
    return '$days days';
  }

  @override
  String get oneDay => '1 day';

  @override
  String get pickupAddress => 'Address';

  @override
  String get pickupAirport => 'Airport';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get deliveryAddressHint => 'Street, area, landmark';

  @override
  String get airportLabel => 'Airport';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get flightNumber => 'Flight number';

  @override
  String get flightNumberHint => 'e.g. AF900';

  @override
  String get flightInvalid => 'Enter a flight number like AF900.';

  @override
  String get flightArrival => 'Arrival time';

  @override
  String airportFeeNote(String fee) {
    return 'Airport delivery: $fee. The driver waits with a name sign at arrivals.';
  }

  @override
  String get airportUnavailable => 'This car cannot be delivered to the airport.';

  @override
  String get periodInvalid => 'The return must be after the start, and the start in the future.';

  @override
  String get reviewAndPay => 'Review and pay';

  @override
  String get reviewTitle => 'Review your rental';

  @override
  String get reviewSubtitle =>
      'You pay the rental now. The deposit is held when the car is handed over.';

  @override
  String rentalDates(String start, String end) {
    return '$start → $end';
  }

  @override
  String rentalAmountLine(String days) {
    return 'Rental · $days';
  }

  @override
  String get airportFeeLine => 'Airport delivery';

  @override
  String get totalNow => 'Total to pay now';

  @override
  String get depositLater => 'Deposit held at handover';

  @override
  String kmAllowance(String km) {
    return 'Distance included: $km km';
  }

  @override
  String get paymentLabel => 'Payment';

  @override
  String get cashAtHandover => 'Cash is paid to the driver at handover.';

  @override
  String get rentalTerms => 'I accept the rental terms and the deposit hold.';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get bookCash => 'Book · pay cash at handover';

  @override
  String get carTaken =>
      'This car is already booked for those dates. Pick other dates or another car.';

  @override
  String get paymentMethodMissing => 'Add this payment method in your wallet first.';

  @override
  String bookingRef(String ref) {
    return 'Booking $ref';
  }

  @override
  String get rentalPendingTitle => 'Approve the payment';

  @override
  String rentalPendingBody(String amount) {
    return 'Confirm $amount on your phone to secure the car.';
  }

  @override
  String get rentalConfirmedTitle => 'Booking confirmed';

  @override
  String get rentalConfirmedBody => 'We are assigning the driver who will deliver your car.';

  @override
  String get rentalAssignedTitle => 'Driver assigned';

  @override
  String rentalAssignedBody(String date) {
    return 'Your driver brings the car on $date.';
  }

  @override
  String get handoverReadyTitle => 'Check the car';

  @override
  String get handoverReadyBody =>
      'The driver recorded the car’s condition. Check it with them, then confirm.';

  @override
  String get confirmHandover => 'Confirm handover';

  @override
  String get rentalActiveTitle => 'Enjoy the drive';

  @override
  String rentalActiveBody(String date) {
    return 'Return the car by $date.';
  }

  @override
  String get returnCar => 'Return the car';

  @override
  String get returnRequested => 'Return requested. The driver will inspect the car with you.';

  @override
  String get returnReadyTitle => 'Check the return';

  @override
  String get returnReadyBody =>
      'Check the return inspection. Your deposit is released when you confirm.';

  @override
  String get confirmReturn => 'Confirm return';

  @override
  String get rentalCompletedTitle => 'Rental complete';

  @override
  String get depositReleased => 'Deposit released in full';

  @override
  String depositPartiallyHeld(String amount) {
    return '$amount kept from the deposit';
  }

  @override
  String get rentalCancelledTitle => 'Booking cancelled';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get cancelBookingTitle => 'Cancel this booking?';

  @override
  String get cancelBookingBody => 'You can cancel free of charge until the rental starts.';

  @override
  String get keepBooking => 'Keep booking';

  @override
  String get inspectionHandover => 'Handover inspection';

  @override
  String get inspectionReturn => 'Return inspection';

  @override
  String get fuelLevel => 'Fuel';

  @override
  String fuelEighths(String n) {
    return '$n/8 tank';
  }

  @override
  String get odometer => 'Odometer';

  @override
  String kmValue(String km) {
    return '$km km';
  }

  @override
  String get photosTaken => 'Photos';

  @override
  String photosCount(String n) {
    return '$n of 5 sides';
  }

  @override
  String get damageNotes => 'Damage notes';

  @override
  String get noDamage => 'No damage noted';

  @override
  String get depositHoldProposed => 'Kept from deposit';

  @override
  String get statusPendingPayment => 'Awaiting payment';

  @override
  String get statusDriverAssigned => 'Driver assigned';

  @override
  String get statusActive => 'Active';

  @override
  String get statusReturnPending => 'Return check';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get rentalsEmptyTitle => 'No rentals yet';

  @override
  String get rentalsEmptyBody => 'Your bookings appear here.';

  @override
  String get rentalFailed => 'The booking could not be made. Try again.';

  @override
  String pickupAt(String place) {
    return 'Pickup: $place';
  }

  @override
  String get rentalReportProblem => 'Report a problem';
}
