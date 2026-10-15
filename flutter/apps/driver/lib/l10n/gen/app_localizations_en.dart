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
  String get welcomeBody => 'Accept rides and rental handovers in Douala and Yaoundé, and get paid to your mobile money.';

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
  String get wrongApp => 'This number is registered as a rider. Use the iyodriver app to book rides.';

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
  String get documentsSubtitle => 'Take a clear photo of each document. We review them within 24 hours.';

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
  String get reviewSubtitle => 'We\'re checking your documents. You\'ll get a notification when it\'s done.';

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
  String get busyAreaBody => 'Akwa & Bonanjo · Stay nearby for your next ride. Keep your phone mounted safely.';

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
  String get locationNeededBody => 'Allow location \"all the time\" so riders can find you while you are online.';

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

  @override
  String get safetySheetTitle => 'Safety';

  @override
  String get shareTrip => 'Share trip';

  @override
  String get shareTripBody => 'Send a live link of this trip to someone you trust.';

  @override
  String get shareTripSubject => 'My iyodriver trip';

  @override
  String shareTripText(String time, String link) {
    return 'Follow my iyodriver trip live (link valid until $time): $link';
  }

  @override
  String get reportIncident => 'Report an incident';

  @override
  String get reportIncidentBody => 'Tell the iyodriver safety team what happened.';

  @override
  String callPolice(String number) {
    return 'Call police · $number';
  }

  @override
  String get shareFailed => 'Could not create a share link. Try again.';

  @override
  String get flowIncident => 'Driver · 17';

  @override
  String get incidentTitle => 'Report an incident';

  @override
  String get incidentSubtitle => 'The safety team reviews every report. Urgent reports are seen first.';

  @override
  String get incidentCategory => 'What happened?';

  @override
  String get incidentAccident => 'Road accident';

  @override
  String get incidentRiderBehaviour => 'Rider behaviour';

  @override
  String get incidentVehicleDamage => 'Damage to the vehicle';

  @override
  String get incidentTheft => 'Theft or aggression';

  @override
  String get incidentLostItem => 'Lost item';

  @override
  String get incidentPayment => 'Payment problem';

  @override
  String get incidentOther => 'Something else';

  @override
  String get incidentDescription => 'Describe what happened';

  @override
  String get incidentDescriptionHint => 'Where, when, who was involved…';

  @override
  String get incidentUrgent => 'This is urgent';

  @override
  String get incidentUrgentBody => 'The safety team calls you back as soon as possible.';

  @override
  String incidentAbout(String what) {
    return 'About: $what';
  }

  @override
  String get incidentAboutTrip => 'your current trip';

  @override
  String incidentAboutRental(String ref) {
    return 'rental $ref';
  }

  @override
  String incidentLocation(String where) {
    return 'Your location is attached: $where';
  }

  @override
  String get incidentNoLocation => 'Location unavailable; describe where you are.';

  @override
  String incidentEmergency(String number) {
    return 'In danger? Call $number first.';
  }

  @override
  String get sendReport => 'Send report';

  @override
  String get pickCategory => 'Choose what happened.';

  @override
  String get flowReportSent => 'Driver · 18';

  @override
  String get reportSentTitle => 'Report sent';

  @override
  String get reportSentSubtitle => 'Thank you. The safety team has your report and trip details.';

  @override
  String reportReference(String ref, String time) {
    return 'Reference $ref · $time';
  }

  @override
  String get reportUrgentNote => 'Marked urgent: keep your phone on, the team will call you.';

  @override
  String get reportNextNote => 'You can keep driving. We may contact you for more details.';

  @override
  String get backToTrip => 'Back to the trip';

  @override
  String get backToHome => 'Back to home';

  @override
  String get segmentRentals => 'Rentals';

  @override
  String get segmentTrips => 'Trips';

  @override
  String get noRentalsTitle => 'No rental deliveries';

  @override
  String get noRentalsBody => 'Cars you are asked to deliver or collect appear here.';

  @override
  String rentalFor(String name) {
    return 'For $name';
  }

  @override
  String rentalRef(String ref) {
    return 'Rental $ref';
  }

  @override
  String deliverAt(String date) {
    return 'Deliver $date';
  }

  @override
  String collectBy(String date) {
    return 'Collect $date';
  }

  @override
  String flightArrives(String flight, String time) {
    return 'Flight $flight · lands $time';
  }

  @override
  String get airportRequirements => 'Meet the rider at arrivals with a name sign. Check the flight status before you leave.';

  @override
  String get rentalStatusToDeliver => 'To deliver';

  @override
  String get rentalStatusAwaitingRider => 'Awaiting rider';

  @override
  String get rentalStatusWithRider => 'With rider';

  @override
  String get rentalStatusReturnCheck => 'Return check';

  @override
  String get rentalStatusDone => 'Done';

  @override
  String get flowRental => 'Driver · 16';

  @override
  String deliveryTitle(String car) {
    return 'Deliver $car';
  }

  @override
  String deliverySubtitle(String name) {
    return 'Hand the car to $name and record its condition together.';
  }

  @override
  String collectTitle(String car) {
    return 'Collect $car';
  }

  @override
  String collectSubtitle(String name) {
    return 'Inspect the car with $name before you take it back.';
  }

  @override
  String get navigateTo => 'Navigate';

  @override
  String get startHandover => 'Start handover checklist';

  @override
  String get startReturn => 'Start return inspection';

  @override
  String waitingRiderConfirm(String name) {
    return 'Waiting for $name to confirm in the app.';
  }

  @override
  String rentalWithRider(String date) {
    return 'The rider has the car until $date.';
  }

  @override
  String get rentalCompleted => 'Rental closed. Thank you.';

  @override
  String depositToHold(String amount) {
    return 'Deposit: $amount';
  }

  @override
  String get handoverTitle => 'Handover checklist';

  @override
  String get returnTitle => 'Return inspection';

  @override
  String get checklistSubtitle => 'Take the five photos, then record fuel, odometer and any damage.';

  @override
  String get photoFront => 'Front';

  @override
  String get photoBack => 'Back';

  @override
  String get photoLeft => 'Left side';

  @override
  String get photoRight => 'Right side';

  @override
  String get photoInterior => 'Interior';

  @override
  String get photosRequired => 'All five photos are required.';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get fuelLabel => 'Fuel level';

  @override
  String fuelValue(String n) {
    return '$n/8';
  }

  @override
  String get odometerLabel => 'Odometer (km)';

  @override
  String get odometerInvalid => 'Enter the odometer reading.';

  @override
  String get damageLabel => 'Damage notes';

  @override
  String get damageHint => 'Scratches, dents, warning lights… Leave empty if none.';

  @override
  String get checkDocuments => 'Car papers in the glovebox';

  @override
  String get checkSpare => 'Spare tyre and jack';

  @override
  String get checkClean => 'Interior clean';

  @override
  String get depositHoldLabel => 'Keep from deposit (FCFA)';

  @override
  String depositHoldHelper(String amount) {
    return '0 releases the full deposit. Up to $amount.';
  }

  @override
  String depositHoldInvalid(String amount) {
    return 'Enter an amount between 0 and $amount.';
  }

  @override
  String get submitHandover => 'Submit for rider confirmation';

  @override
  String uploadingPhotos(String percent) {
    return 'Uploading photos… $percent%';
  }

  @override
  String get inspectionFailed => 'The inspection could not be sent. Check your connection and try again.';

  @override
  String get menuReportIncident => 'Report an incident';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get homeOfflineSubtitle => 'You’re offline. Ready when you are.';

  @override
  String get todaysEarnings => 'Today’s earnings';

  @override
  String get completedTrips => 'Completed trips';

  @override
  String get offlineBadge => 'Offline · No ride requests';

  @override
  String nextRental(String when) {
    return 'Next rental · $when';
  }

  @override
  String nextRentalDetail(String place, String car, String days) {
    return '$place · $car · $days';
  }

  @override
  String daysCount(String n) {
    return '$n days';
  }

  @override
  String get oneDay => '1 day';

  @override
  String get homeOnlineTitle => 'You’re online';

  @override
  String get homeOnlineSubtitle => 'Looking for riders nearby…';

  @override
  String get busyAreaHeading => 'You’re in a busy area';

  @override
  String busyAreaText(String area) {
    return '$area · Stay nearby for your next ride. Keep your phone mounted safely.';
  }

  @override
  String todayAmount(String amount) {
    return 'Today · $amount';
  }

  @override
  String tripsOnline(String trips, String online) {
    return '$trips · $online online';
  }

  @override
  String tripsN(String n) {
    return '$n trips';
  }

  @override
  String get oneTrip => '1 trip';

  @override
  String get requestTitle => 'A new ride nearby';

  @override
  String requestSubtitle(String category, String seconds) {
    return '$category · Accept within $seconds seconds';
  }

  @override
  String get estEarningsBadge => 'Your est. earnings';

  @override
  String requestMeta(String pickup, String trip, String distance) {
    return '$pickup min to pickup · Trip $trip min · $distance';
  }

  @override
  String pickupSuffix(String area) {
    return '$area · Pickup';
  }

  @override
  String dropoffSuffix(String area) {
    return '$area · Drop-off';
  }

  @override
  String verifiedRider(String rating) {
    return '★ $rating · Verified rider';
  }

  @override
  String get askForPin => 'Ask for the pickup PIN at the car';

  @override
  String acceptRideSeconds(String seconds) {
    return 'Accept ride · ${seconds}s';
  }

  @override
  String get declineRequest => 'Decline request';

  @override
  String headToRider(String name) {
    return 'Head to $name';
  }

  @override
  String headToSubtitle(String place, String minutes, String distance) {
    return '$place · $minutes min · $distance';
  }

  @override
  String navContinue(String distance) {
    return 'Continue for $distance';
  }

  @override
  String navTowards(String place) {
    return 'Towards $place';
  }

  @override
  String navArriving(String place) {
    return 'Arriving at $place';
  }

  @override
  String get tileMessage => 'Message';

  @override
  String get tileShareTrip => 'Share trip';

  @override
  String get tileSafety => 'Safety';

  @override
  String pickupNote(String note) {
    return 'Pickup note: “$note”';
  }

  @override
  String get stopSafely => 'Please stop safely before contacting your rider.';

  @override
  String get arrivedAtPickup => 'I’ve arrived at pickup';

  @override
  String get atPickupTitle => 'You’re at the pickup';

  @override
  String atPickupSubtitle(String name) {
    return '$name has been notified you’ve arrived.';
  }

  @override
  String askPinLabel(String name) {
    return 'Ask $name for the 4-digit pickup PIN';
  }

  @override
  String get pinVerified => '✓ PIN verified · You can start the ride.';

  @override
  String confirmRiderNote(String place) {
    return 'Confirm the rider’s name before departure. Destination: $place.';
  }

  @override
  String driveTo(String place) {
    return 'Drive to $place';
  }

  @override
  String driveSubtitle(String time, String minutes, String distance) {
    return 'Arrive $time · $minutes min · $distance left';
  }

  @override
  String tripInProgress(String ref) {
    return 'Trip in progress · $ref';
  }

  @override
  String get endRide => 'End ride at destination';

  @override
  String get cancelThisRide => 'Cancel this ride';

  @override
  String navTurnRight(String distance) {
    return 'Turn right in $distance';
  }

  @override
  String navInto(String street) {
    return 'Into $street';
  }

  @override
  String navOn(String street) {
    return 'On $street';
  }

  @override
  String mainEntrance(String area) {
    return '$area · Main entrance';
  }

  @override
  String get earnTitle => 'Your earnings';

  @override
  String earnSubtitle(String range) {
    return '$range · Net after service fees';
  }

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get weekSoFar => 'This week so far';

  @override
  String get monthSoFar => 'This month so far';

  @override
  String get yearSoFar => 'This year so far';

  @override
  String tripsDriving(String trips, String time) {
    return '$trips · $time driving';
  }

  @override
  String get nextPayout => 'Next scheduled payout';

  @override
  String nextPayoutDetail(String date, String account) {
    return '$date · $account';
  }

  @override
  String get payoutHistory => 'Payout history';

  @override
  String paidTo(String account) {
    return 'Paid to $account';
  }

  @override
  String payoutPending(String account) {
    return 'Being sent to $account';
  }

  @override
  String payoutFailed(String reason) {
    return 'Failed · $reason';
  }

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFailed => 'Failed';

  @override
  String get viewPayoutDetails => 'View payout details';

  @override
  String get noPayoutsYet => 'No payouts yet. Earnings are paid weekly, every Monday.';

  @override
  String get weekdayLetters => 'M,T,W,T,F,S,S';

  @override
  String get monthLetters => 'J,F,M,A,M,J,J,A,S,O,N,D';

  @override
  String weekN(String n) {
    return 'W$n';
  }

  @override
  String get payoutTitle => 'Payout details';

  @override
  String payoutSubtitle(String ref, String range) {
    return '$ref · $range';
  }

  @override
  String sentOn(String date) {
    return 'Sent on $date';
  }

  @override
  String requestedOn(String date) {
    return 'Requested on $date';
  }

  @override
  String get payoutBreakdown => 'Payout breakdown';

  @override
  String rideFaresLine(String trips) {
    return 'Ride fares · $trips';
  }

  @override
  String get rentalHandoverEarnings => 'Rental handover earnings';

  @override
  String get tipsLine => 'Tips';

  @override
  String get serviceFeesLine => 'Service fees';

  @override
  String get netPayout => 'Net payout';

  @override
  String mobileMoneyTransfer(String name) {
    return '$name · Mobile money transfer';
  }

  @override
  String get transferTimeline => 'Transfer timeline';

  @override
  String get tlCreated => 'Payout created';

  @override
  String tlCreatedBody(String time) {
    return '$time · Weekly earnings calculated';
  }

  @override
  String get tlSent => 'Transfer sent';

  @override
  String tlSentBody(String time, String ref) {
    return '$time · Reference $ref';
  }

  @override
  String get tlDelivered => 'Transfer delivered';

  @override
  String tlDeliveredBody(String time) {
    return '$time · Funds delivered';
  }

  @override
  String get tlWaiting => 'Waiting for the operator';

  @override
  String payoutHelp(String ref) {
    return 'Need help? Quote $ref when contacting support.';
  }

  @override
  String get downloadStatement => 'Download statement';

  @override
  String statementTitle(String ref) {
    return 'iyodriver payout $ref';
  }

  @override
  String get bookingsHeading => 'Your bookings';

  @override
  String get bookingsSub => 'Upcoming handovers and completed trips.';

  @override
  String get segUpcoming => 'Upcoming';

  @override
  String get segHistory => 'History';

  @override
  String airportPickupConfirmed(String status) {
    return 'Airport pickup · $status';
  }

  @override
  String addressPickupStatus(String status) {
    return 'Delivery · $status';
  }

  @override
  String get statusConfirmedShort => 'Confirmed';

  @override
  String rentalWhenWhere(String when, String place) {
    return '$when · $place';
  }

  @override
  String returnWhenWhere(String when, String place) {
    return 'Return: $when · $place';
  }

  @override
  String get viewHandoverRequirements => 'View handover requirements';

  @override
  String get viewReturnSteps => 'View return inspection';

  @override
  String get todaysCompletedRides => 'Today’s completed rides';

  @override
  String get statusCompletedShort => 'Completed';

  @override
  String get bookingsFootnote => 'Ride amounts show net earnings after service fees. View all past bookings in History.';

  @override
  String get noUpcomingTitle => 'Nothing booked yet';

  @override
  String get noUpcomingBody => 'Rental handovers assigned to you appear here.';

  @override
  String get pastRentals => 'Rentals';

  @override
  String get pastRides => 'Rides';

  @override
  String perDayBadge(String price) {
    return '$price / day';
  }

  @override
  String carSpecs(String fuel, String gearbox, String seats) {
    return '$fuel · $gearbox · $seats seats';
  }

  @override
  String get fuelPetrol => 'Petrol';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybrid';

  @override
  String get fuelElectric => 'Electric';

  @override
  String get gearAutomatic => 'Automatic';

  @override
  String get gearManual => 'Manual';

  @override
  String get accountHeading => 'Driver account';

  @override
  String get accountSub => 'Your profile and road-ready documents.';

  @override
  String driverMeta(String rating, String trips, String ref) {
    return '★ $rating · $trips · Driver $ref';
  }

  @override
  String get verifiedDriver => 'Verified driver';

  @override
  String get yourVehicle => 'Your vehicle';

  @override
  String vehicleSpecs(String colour, String year, String seats) {
    return '$colour · $year · $seats seats';
  }

  @override
  String plateServices(String plate) {
    return '$plate · Ride & rental';
  }

  @override
  String categoryApproved(String category) {
    return '$category · Approved';
  }

  @override
  String categoryInReview(String category) {
    return '$category · In review';
  }

  @override
  String get documentsHeading => 'Documents';

  @override
  String docVerifiedExpires(String date) {
    return 'Verified · Expires $date';
  }

  @override
  String get docVerified => 'Verified';

  @override
  String docRenewBy(String date) {
    return 'Renew by $date';
  }

  @override
  String get docInReview => 'In review';

  @override
  String docNeedsAction(String reason) {
    return 'Action needed · $reason';
  }

  @override
  String get docNotUploaded => 'Not uploaded yet';

  @override
  String get payoutDetailsRow => 'Payout details';

  @override
  String get notSet => 'Not set';

  @override
  String get vehicleChangeNote => 'Changes to vehicle details may require a new review before you can go online.';

  @override
  String get editAccount => 'Edit account details';

  @override
  String get moreSection => 'More';

  @override
  String flowSetup(String step) {
    return 'Driver setup · $step';
  }

  @override
  String get setupTitle => 'Let’s get you road-ready';

  @override
  String get setupStep1 => 'Step 1 of 2 · Identity & vehicle';

  @override
  String get driverAccountBadge => 'Driver account';

  @override
  String get legalName => 'Legal name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get dateOfBirthHint => 'DD/MM/YYYY';

  @override
  String get dobInvalid => 'Enter your date of birth (you must be 21 or older).';

  @override
  String get vehicleMakeModel => 'Vehicle make & model';

  @override
  String get vehicleMakeModelHint => 'Toyota Corolla · 2018 · Blanc';

  @override
  String get vehicleRegistration => 'Vehicle registration';

  @override
  String get vehicleCheckedHelper => 'Your vehicle details will be checked with your documents.';

  @override
  String get legalDetailsNote => 'Your legal details are used for verification. Riders will only see your first name and vehicle details.';

  @override
  String get saveAndContinue => 'Save & continue to documents';

  @override
  String get vehicleSheetTitle => 'Your vehicle';

  @override
  String get moreDetails => 'Also needed for verification';

  @override
  String get docsTitle => 'A quick safety check';

  @override
  String get setupStep2 => 'Step 2 of 2 · Upload your documents';

  @override
  String docsReady(String n, String total) {
    return '$n of $total documents ready';
  }

  @override
  String get groupIdentity => 'Photo ID & selfie';

  @override
  String get groupIdentityDone => 'Identity photos received';

  @override
  String get groupLicence => 'Driving licence';

  @override
  String get groupLicenceDone => 'Licence uploaded';

  @override
  String get groupVehicle => 'Vehicle papers';

  @override
  String get groupVehicleDone => 'Carte grise and visite technique uploaded';

  @override
  String get groupInsurance => 'Insurance certificate';

  @override
  String get groupInsuranceDone => 'Insurance uploaded';

  @override
  String get groupApproved => 'Approved';

  @override
  String get groupInReview => 'Uploaded · in review';

  @override
  String groupMissing(String n) {
    return '$n to upload';
  }

  @override
  String nextDocument(String doc) {
    return 'Next: $doc';
  }

  @override
  String get noFileYet => 'No photo yet';

  @override
  String get uploadTips => 'Tips for a successful upload';

  @override
  String get uploadTipsBody => 'Keep all four corners visible. Use good lighting and avoid glare. Accepted: JPG, PNG or PDF, up to 10 MB.';

  @override
  String get reviewTimeNote => 'After you submit, reviews usually take 1–2 working days. We’ll notify you when you’re approved.';

  @override
  String uploadDoc(String doc) {
    return 'Upload $doc photo';
  }

  @override
  String retakeDoc(String doc) {
    return 'Retake $doc photo';
  }

  @override
  String get identityLocked => 'Verified details are locked. Contact support to change them.';

  @override
  String flowDriverRental(String step) {
    return 'Driver rental · $step';
  }

  @override
  String get airportRentalPickup => 'Airport rental pickup';

  @override
  String get addressRentalPickup => 'Rental delivery';

  @override
  String get rentalReturnTitle => 'Rental return';

  @override
  String confirmedBooking(String ref) {
    return 'Confirmed booking · $ref';
  }

  @override
  String upcomingWhen(String when) {
    return 'Upcoming · $when';
  }

  @override
  String withRiderUntil(String when) {
    return 'With rider · until $when';
  }

  @override
  String carWithFuel(String car, String fuel) {
    return '$car · $fuel';
  }

  @override
  String rentalPeriodDays(String range, String days) {
    return '$range · $days';
  }

  @override
  String pickupOn(String day) {
    return 'Pickup · $day';
  }

  @override
  String returnOn(String day) {
    return 'Return · $day';
  }

  @override
  String timeAtPlace(String time, String place) {
    return '$time · $place';
  }

  @override
  String get airportRequirementsTitle => 'Airport pickup requirements';

  @override
  String flightLine(String flight, String route) {
    return '$flight · $route';
  }

  @override
  String landingLine(String when, String terminal) {
    return 'Landing: $when · $terminal';
  }

  @override
  String meetLine(String time, String name) {
    return 'Meet at arrivals, $time. Hold an iyodriver name sign for $name.';
  }

  @override
  String prepareCarNote(String minutes, String name) {
    return 'Prepare a clean car with a full tank. Allow $minutes min after landing and contact $name if the flight is delayed.';
  }

  @override
  String prepareCarNoteAddress(String name) {
    return 'Prepare a clean car with a full tank. Call $name if you are running late.';
  }

  @override
  String navigateToPlace(String place) {
    return 'Navigate to $place';
  }

  @override
  String get openHandover => 'Start the handover';

  @override
  String get askHandoverPin => 'Ask for the handover PIN at the car';

  @override
  String get smoothHandover => 'A smooth handover';

  @override
  String handoverSubtitle(String name, String place, String date) {
    return '$name · $place · $date';
  }

  @override
  String carPlateBadge(String car, String plate) {
    return '$car · $plate';
  }

  @override
  String get checkIdentity => 'Identity & licence checked';

  @override
  String get checkIdentityBody => 'Name matches the booking';

  @override
  String get checkIdentityTap => 'Tap once you have seen the ID and licence';

  @override
  String get checkDeposit => 'Deposit authorised';

  @override
  String checkDepositBody(String amount, String method) {
    return '$amount hold · $method';
  }

  @override
  String get checkPhotos => 'Vehicle condition photos';

  @override
  String checkPhotosDone(String n, String damage) {
    return '$n photos saved · $damage';
  }

  @override
  String get checkPhotosTodo => 'Take the 5 photos';

  @override
  String get noNewDamage => 'No new damage';

  @override
  String get damageNoted => 'Damage noted';

  @override
  String get checkFuel => 'Fuel & mileage recorded';

  @override
  String checkFuelDone(String fuel, String km) {
    return '$fuel · $km km';
  }

  @override
  String get checkFuelTodo => 'Recorded with the photos';

  @override
  String get fullTank => 'Full tank';

  @override
  String tankEighths(String n) {
    return '$n/8 tank';
  }

  @override
  String get customerHandoverPin => 'Customer handover PIN';

  @override
  String get handoverPinVerified => '✓ PIN verified · Rental agreement accepted';

  @override
  String handoverReturnNote(String when, String place, String name) {
    return 'Return: $when · $place. Give $name the keys after confirming all checks.';
  }

  @override
  String get confirmHandoverStart => 'Confirm handover & start rental';

  @override
  String handoverPinWrong(String n) {
    return 'Wrong PIN · $n attempts left';
  }

  @override
  String get handoverPinLocked => 'Too many wrong PINs. The safety team has been told; call support.';

  @override
  String get handoverDone => 'Handover complete. The rental has started.';
}
