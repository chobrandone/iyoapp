// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get placeholderBadge => 'Chauffeur';

  @override
  String get placeholderFlowLabel => 'Chauffeur · 00';

  @override
  String get placeholderTitle => 'Conduisez avec iyodriver. Gagnez à votre rythme.';

  @override
  String get placeholderSubtitle => 'Acceptez des courses et des remises de véhicules à Douala et Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Gains du jour : $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Heure locale (Douala) : $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Numéro de paiement : $phone';
  }

  @override
  String get placeholderPrimary => 'Commencer';

  @override
  String get placeholderSecondary => 'Switch to English';

  @override
  String get badge => 'Chauffeur';

  @override
  String flow(String step) {
    return 'Chauffeur · $step';
  }

  @override
  String get flowPlain => 'Chauffeur';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabEarnings => 'Gains';

  @override
  String get tabBookings => 'Courses';

  @override
  String get tabAccount => 'Compte';

  @override
  String get safety => 'Sécurité';

  @override
  String get welcomeHeroTitle => 'Conduisez.\nGagnez.';

  @override
  String get welcomeBadge => 'Courses + remises de location';

  @override
  String get welcomeHeadline => 'Conduisez avec iyodriver.\nGagnez à votre rythme.';

  @override
  String get welcomeBody => 'Acceptez des courses et des remises de véhicules à Douala et Yaoundé, payées sur votre mobile money.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get alreadyDriver => 'Déjà chauffeur ?';

  @override
  String get logIn => 'Se connecter';

  @override
  String get signUpTitle => 'Créez votre compte chauffeur';

  @override
  String get signUpSubtitle => 'Nous vérifions vos documents avant votre première course.';

  @override
  String get fieldFullName => 'Nom complet (comme sur la pièce d\'identité)';

  @override
  String get fieldMobile => 'Numéro de mobile';

  @override
  String get agreeTerms => 'J\'accepte les Conditions chauffeur et la Politique de confidentialité.';

  @override
  String get createAndVerify => 'Créer le compte et vérifier';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous avec votre numéro. Nous vous enverrons un code par SMS.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get newDriver => 'Nouveau chauffeur ?';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get verifyTitle => 'Consultez vos messages';

  @override
  String verifySubtitle(String phone) {
    return 'Saisissez le code envoyé au $phone.';
  }

  @override
  String demoCodeHint(String code) {
    return 'Mode démo · utilisez le code $code';
  }

  @override
  String resendIn(String time) {
    return 'Pas reçu de code ? Renvoyer dans $time';
  }

  @override
  String get resendNow => 'Pas reçu de code ? Renvoyer';

  @override
  String get wrongNumber => 'Mauvais numéro ? Le modifier';

  @override
  String get verifyContinue => 'Vérifier et continuer';

  @override
  String get otpInvalid => 'Ce code n\'est pas correct. Vérifiez le SMS et réessayez.';

  @override
  String get wrongApp => 'Ce numéro est inscrit comme passager. Utilisez l\'application iyodriver pour réserver.';

  @override
  String get identityTitle => 'Identité et véhicule';

  @override
  String get identitySubtitle => 'Dites-nous qui vous êtes et ce que vous conduisez.';

  @override
  String stepOf(String current, String total) {
    return 'Étape $current sur $total';
  }

  @override
  String get fieldCity => 'Ville';

  @override
  String get fieldLicence => 'Numéro du permis de conduire';

  @override
  String get fieldNationalId => 'Numéro de CNI';

  @override
  String get vehicleSection => 'Votre véhicule';

  @override
  String get fieldMake => 'Marque';

  @override
  String get fieldModel => 'Modèle';

  @override
  String get fieldYear => 'Année';

  @override
  String get fieldColor => 'Couleur';

  @override
  String get fieldPlate => 'Plaque d\'immatriculation';

  @override
  String get plateHelper => 'Format : LT 123 AB';

  @override
  String get plateInvalid => 'Saisissez une plaque comme LT 123 AB.';

  @override
  String get yearInvalid => 'Saisissez une année entre 1990 et l\'an prochain.';

  @override
  String get fieldCategory => 'Catégorie';

  @override
  String get categoryStandard => 'Standard · 4 places';

  @override
  String get categoryComfort => 'Confort · 4 places';

  @override
  String get categoryXl => 'XL · 6 places';

  @override
  String get continueToDocuments => 'Continuer vers les documents';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get documentsSubtitle => 'Prenez une photo nette de chaque document. Nous les vérifions sous 24 heures.';

  @override
  String get docNationalIdFront => 'CNI · recto';

  @override
  String get docNationalIdBack => 'CNI · verso';

  @override
  String get docDrivingLicence => 'Permis de conduire';

  @override
  String get docVehicleRegistration => 'Carte grise';

  @override
  String get docInsurance => 'Attestation d\'assurance';

  @override
  String get docRoadworthiness => 'Visite technique';

  @override
  String get docProfilePhoto => 'Photo de profil';

  @override
  String get docMissing => 'Non envoyé';

  @override
  String docUploading(String percent) {
    return 'Envoi… $percent %';
  }

  @override
  String get docPending => 'Envoyé · en attente de vérification';

  @override
  String get docApproved => 'Validé';

  @override
  String docRejected(String reason) {
    return 'Refusé · $reason';
  }

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get submitForReview => 'Envoyer pour vérification';

  @override
  String get documentsMissingError => 'Envoyez tous les documents avant de soumettre.';

  @override
  String get reviewTitle => 'En cours de vérification';

  @override
  String get reviewSubtitle => 'Nous vérifions vos documents. Vous serez notifié dès que c’est terminé.';

  @override
  String get reviewDemo => 'Mode démo : la validation est simulée en quelques secondes.';

  @override
  String get actionNeededTitle => 'Action requise';

  @override
  String get actionNeededSubtitle => 'Un ou plusieurs documents doivent être renvoyés.';

  @override
  String get fixDocuments => 'Mettre à jour les documents';

  @override
  String get approvedTitle => 'Vous êtes validé';

  @override
  String get approvedSubtitle => 'Bienvenue chez iyodriver. Vous pouvez passer en ligne et accepter des courses.';

  @override
  String get startDriving => 'Commencer à conduire';

  @override
  String get offlineTitle => 'Vous êtes hors ligne';

  @override
  String get offlineSubtitle => 'Passez en ligne pour recevoir des demandes de course.';

  @override
  String get onlineTitle => 'Vous êtes en ligne';

  @override
  String get onlineSubtitle => 'Recherche de courses près de vous.';

  @override
  String get goOnline => 'Passer en ligne';

  @override
  String get goOffline => 'Passer hors ligne';

  @override
  String get acceptingRequests => 'Accepte les demandes';

  @override
  String get busyAreaTitle => 'Vous êtes dans une zone animée';

  @override
  String get busyAreaBody => 'Akwa et Bonanjo · Restez à proximité pour la prochaine course. Gardez votre téléphone fixé.';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '1 course',
    );
    return '$_temp0';
  }

  @override
  String onlineFor(String time) {
    return '$time en ligne';
  }

  @override
  String get rating => 'Note';

  @override
  String get lastTrips => '100 dernières courses';

  @override
  String get locationNeeded => 'La localisation est nécessaire pour passer en ligne';

  @override
  String get locationNeededBody => 'Autorisez la localisation « tout le temps » pour que les passagers vous trouvent en ligne.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get onlineNotificationTitle => 'Vous êtes en ligne';

  @override
  String get onlineNotificationBody => 'iyodriver partage votre position avec les passagers proches.';

  @override
  String get newRequest => 'Nouvelle demande';

  @override
  String pickupIn(String minutes, String distance) {
    return 'Prise en charge · $minutes min · $distance';
  }

  @override
  String tripLength(String distance, String minutes) {
    return 'Trajet · $distance · environ $minutes min';
  }

  @override
  String youEarn(String amount) {
    return 'Vous gagnez $amount';
  }

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Refuser';

  @override
  String secondsLeft(String seconds) {
    return '$seconds s pour accepter';
  }

  @override
  String toPickupTitle(String name) {
    return 'Prendre $name';
  }

  @override
  String toPickupSubtitle(String place, String minutes) {
    return '$place · à $minutes min';
  }

  @override
  String get navigate => 'Itinéraire';

  @override
  String get imHere => 'Je suis arrivé';

  @override
  String get cancelRide => 'Annuler la course';

  @override
  String get cancelTitle => 'Annuler cette course ?';

  @override
  String get cancelBody => 'Des annulations fréquentes baissent votre taux d’acceptation.';

  @override
  String get cancelReasonNoShow => 'Le passager ne s’est pas présenté';

  @override
  String get cancelReasonUnsafe => 'Je ne me sens pas en sécurité';

  @override
  String get cancelReasonVehicle => 'Problème de véhicule';

  @override
  String get cancelReasonOther => 'Autre raison';

  @override
  String get keepRide => 'Garder la course';

  @override
  String arrivedTitle(String name) {
    return 'En attente de $name';
  }

  @override
  String waitTime(String time) {
    return 'Attente · $time';
  }

  @override
  String pinLabel(String name) {
    return 'Demandez à $name son code PIN à 4 chiffres';
  }

  @override
  String pinWrong(String count) {
    return 'Code incorrect · $count essais restants';
  }

  @override
  String get pinLocked => 'Code bloqué après trop d’essais. L’assistance a été prévenue.';

  @override
  String pinDemoHint(String pin) {
    return 'Mode démo · le code du passager est $pin';
  }

  @override
  String get startRide => 'Démarrer la course';

  @override
  String liveTitle(String place) {
    return 'Direction $place';
  }

  @override
  String liveSubtitle(String minutes, String distance) {
    return 'Encore $minutes min · $distance';
  }

  @override
  String get completeRide => 'Terminer la course';

  @override
  String get completeTitle => 'Course terminée';

  @override
  String completeSubtitle(String place, String payment) {
    return '$place · $payment';
  }

  @override
  String get earnings => 'Vos gains';

  @override
  String get fare => 'Prix de la course';

  @override
  String get commission => 'Commission iyodriver';

  @override
  String collectCash(String amount, String name) {
    return 'Encaissez $amount en espèces auprès de $name';
  }

  @override
  String rateRider(String name) {
    return 'Comment était $name ?';
  }

  @override
  String get done => 'Terminé';

  @override
  String get riderCancelled => 'Le passager a annulé';

  @override
  String get riderCancelledBody => 'Cette course ne vous sera pas comptée.';

  @override
  String get backHome => 'Retour à l\'accueil';

  @override
  String chatWith(String name) {
    return 'Discussion avec $name';
  }

  @override
  String get chatPrivacy => 'Votre numéro reste privé.';

  @override
  String get writeMessage => 'Écrire un message…';

  @override
  String get send => 'Envoyer';

  @override
  String callRider(String name) {
    return 'Appeler $name';
  }

  @override
  String messageRider(String name) {
    return 'Écrire à $name';
  }

  @override
  String get paymentCash => 'Espèces';

  @override
  String get paymentMtn => 'MTN MoMo';

  @override
  String get paymentOrange => 'Orange Money';

  @override
  String get paymentCard => 'Carte';

  @override
  String riderRating(String rating) {
    return '★ $rating · Passager vérifié';
  }

  @override
  String get earningsTitle => 'Gains';

  @override
  String get earningsSubtitle => 'Versés chaque semaine sur votre mobile money.';

  @override
  String get recentTrips => 'Courses récentes';

  @override
  String get noTripsTitle => 'Aucune course pour le moment';

  @override
  String get noTripsBody => 'Passez en ligne pour recevoir votre première demande.';

  @override
  String get bookingsTitle => 'Courses';

  @override
  String get bookingsSubtitle => 'Vos courses et remises de véhicules.';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountSubtitle => 'Profil, véhicule et paiements.';

  @override
  String get vehicle => 'Véhicule';

  @override
  String get language => 'Langue';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get componentGallery => 'Galerie de composants (dev)';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get safetySheetTitle => 'Sécurité';

  @override
  String get shareTrip => 'Partager la course';

  @override
  String get shareTripBody => 'Envoyez un lien en direct de cette course à un proche.';

  @override
  String get shareTripSubject => 'Ma course iyodriver';

  @override
  String shareTripText(String time, String link) {
    return 'Suivez ma course iyodriver en direct (lien valable jusqu’à $time) : $link';
  }

  @override
  String get reportIncident => 'Signaler un incident';

  @override
  String get reportIncidentBody => 'Expliquez à l’équipe sécurité iyodriver ce qui s’est passé.';

  @override
  String callPolice(String number) {
    return 'Appeler la police · $number';
  }

  @override
  String get shareFailed => 'Impossible de créer le lien de partage. Réessayez.';

  @override
  String get flowIncident => 'Chauffeur · 17';

  @override
  String get incidentTitle => 'Signaler un incident';

  @override
  String get incidentSubtitle => 'L’équipe sécurité examine chaque signalement. Les urgences sont traitées en priorité.';

  @override
  String get incidentCategory => 'Que s’est-il passé ?';

  @override
  String get incidentAccident => 'Accident de la route';

  @override
  String get incidentRiderBehaviour => 'Comportement du passager';

  @override
  String get incidentVehicleDamage => 'Dommage au véhicule';

  @override
  String get incidentTheft => 'Vol ou agression';

  @override
  String get incidentLostItem => 'Objet perdu';

  @override
  String get incidentPayment => 'Problème de paiement';

  @override
  String get incidentOther => 'Autre chose';

  @override
  String get incidentDescription => 'Décrivez ce qui s’est passé';

  @override
  String get incidentDescriptionHint => 'Où, quand, qui était impliqué…';

  @override
  String get incidentUrgent => 'C’est urgent';

  @override
  String get incidentUrgentBody => 'L’équipe sécurité vous rappelle dès que possible.';

  @override
  String incidentAbout(String what) {
    return 'Concerne : $what';
  }

  @override
  String get incidentAboutTrip => 'votre course en cours';

  @override
  String incidentAboutRental(String ref) {
    return 'la location $ref';
  }

  @override
  String incidentLocation(String where) {
    return 'Votre position est jointe : $where';
  }

  @override
  String get incidentNoLocation => 'Position indisponible ; précisez où vous êtes.';

  @override
  String incidentEmergency(String number) {
    return 'En danger ? Appelez d’abord le $number.';
  }

  @override
  String get sendReport => 'Envoyer le signalement';

  @override
  String get pickCategory => 'Choisissez ce qui s’est passé.';

  @override
  String get flowReportSent => 'Chauffeur · 18';

  @override
  String get reportSentTitle => 'Signalement envoyé';

  @override
  String get reportSentSubtitle => 'Merci. L’équipe sécurité a reçu votre signalement et les détails de la course.';

  @override
  String reportReference(String ref, String time) {
    return 'Référence $ref · $time';
  }

  @override
  String get reportUrgentNote => 'Marqué urgent : gardez votre téléphone allumé, l’équipe va vous appeler.';

  @override
  String get reportNextNote => 'Vous pouvez continuer à conduire. Nous pourrons vous recontacter.';

  @override
  String get backToTrip => 'Retour à la course';

  @override
  String get backToHome => 'Retour à l’accueil';

  @override
  String get segmentRentals => 'Locations';

  @override
  String get segmentTrips => 'Courses';

  @override
  String get noRentalsTitle => 'Aucune livraison de location';

  @override
  String get noRentalsBody => 'Les voitures à livrer ou récupérer apparaissent ici.';

  @override
  String rentalFor(String name) {
    return 'Pour $name';
  }

  @override
  String rentalRef(String ref) {
    return 'Location $ref';
  }

  @override
  String deliverAt(String date) {
    return 'Livrer le $date';
  }

  @override
  String collectBy(String date) {
    return 'Récupérer le $date';
  }

  @override
  String flightArrives(String flight, String time) {
    return 'Vol $flight · arrivée $time';
  }

  @override
  String get airportRequirements => 'Accueillez le passager aux arrivées avec une pancarte. Vérifiez le statut du vol avant de partir.';

  @override
  String get rentalStatusToDeliver => 'À livrer';

  @override
  String get rentalStatusAwaitingRider => 'Attente passager';

  @override
  String get rentalStatusWithRider => 'Chez le passager';

  @override
  String get rentalStatusReturnCheck => 'Contrôle retour';

  @override
  String get rentalStatusDone => 'Terminée';

  @override
  String get flowRental => 'Chauffeur · 16';

  @override
  String deliveryTitle(String car) {
    return 'Livrer $car';
  }

  @override
  String deliverySubtitle(String name) {
    return 'Remettez la voiture à $name et relevez son état ensemble.';
  }

  @override
  String collectTitle(String car) {
    return 'Récupérer $car';
  }

  @override
  String collectSubtitle(String name) {
    return 'Inspectez la voiture avec $name avant de la reprendre.';
  }

  @override
  String get navigateTo => 'Itinéraire';

  @override
  String get startHandover => 'Commencer la remise';

  @override
  String get startReturn => 'Commencer l’inspection retour';

  @override
  String waitingRiderConfirm(String name) {
    return 'En attente de la confirmation de $name dans l’app.';
  }

  @override
  String rentalWithRider(String date) {
    return 'Le passager a la voiture jusqu’au $date.';
  }

  @override
  String get rentalCompleted => 'Location clôturée. Merci.';

  @override
  String depositToHold(String amount) {
    return 'Caution : $amount';
  }

  @override
  String get handoverTitle => 'Liste de remise';

  @override
  String get returnTitle => 'Inspection retour';

  @override
  String get checklistSubtitle => 'Prenez les cinq photos, puis relevez carburant, compteur et dommages.';

  @override
  String get photoFront => 'Avant';

  @override
  String get photoBack => 'Arrière';

  @override
  String get photoLeft => 'Côté gauche';

  @override
  String get photoRight => 'Côté droit';

  @override
  String get photoInterior => 'Intérieur';

  @override
  String get photosRequired => 'Les cinq photos sont obligatoires.';

  @override
  String get retakePhoto => 'Reprendre';

  @override
  String get fuelLabel => 'Niveau de carburant';

  @override
  String fuelValue(String n) {
    return '$n/8';
  }

  @override
  String get odometerLabel => 'Compteur (km)';

  @override
  String get odometerInvalid => 'Saisissez le kilométrage.';

  @override
  String get damageLabel => 'Dommages constatés';

  @override
  String get damageHint => 'Rayures, bosses, voyants… Laissez vide s’il n’y en a pas.';

  @override
  String get checkDocuments => 'Papiers du véhicule dans la boîte à gants';

  @override
  String get checkSpare => 'Roue de secours et cric';

  @override
  String get checkClean => 'Intérieur propre';

  @override
  String get depositHoldLabel => 'Retenir sur la caution (FCFA)';

  @override
  String depositHoldHelper(String amount) {
    return '0 libère toute la caution. Jusqu’à $amount.';
  }

  @override
  String depositHoldInvalid(String amount) {
    return 'Saisissez un montant entre 0 et $amount.';
  }

  @override
  String get submitHandover => 'Envoyer pour confirmation';

  @override
  String uploadingPhotos(String percent) {
    return 'Envoi des photos… $percent %';
  }

  @override
  String get inspectionFailed => 'L’inspection n’a pas pu être envoyée. Vérifiez votre connexion et réessayez.';

  @override
  String get menuReportIncident => 'Signaler un incident';

  @override
  String greetingMorning(String name) {
    return 'Bonjour, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Bon après-midi, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Bonsoir, $name';
  }

  @override
  String get homeOfflineSubtitle => 'Vous êtes hors ligne. Prêt quand vous l’êtes.';

  @override
  String get todaysEarnings => 'Gains du jour';

  @override
  String get completedTrips => 'Courses terminées';

  @override
  String get offlineBadge => 'Hors ligne · Aucune demande';

  @override
  String nextRental(String when) {
    return 'Prochaine location · $when';
  }

  @override
  String nextRentalDetail(String place, String car, String days) {
    return '$place · $car · $days';
  }

  @override
  String daysCount(String n) {
    return '$n jours';
  }

  @override
  String get oneDay => '1 jour';

  @override
  String get homeOnlineTitle => 'Vous êtes en ligne';

  @override
  String get homeOnlineSubtitle => 'Recherche de passagers à proximité…';

  @override
  String get busyAreaHeading => 'Vous êtes dans une zone animée';

  @override
  String busyAreaText(String area) {
    return '$area · Restez à proximité pour la prochaine course. Gardez votre téléphone bien fixé.';
  }

  @override
  String todayAmount(String amount) {
    return 'Aujourd’hui · $amount';
  }

  @override
  String tripsOnline(String trips, String online) {
    return '$trips · $online en ligne';
  }

  @override
  String tripsN(String n) {
    return '$n courses';
  }

  @override
  String get oneTrip => '1 course';

  @override
  String get requestTitle => 'Une nouvelle course à proximité';

  @override
  String requestSubtitle(String category, String seconds) {
    return '$category · Acceptez dans les $seconds secondes';
  }

  @override
  String get estEarningsBadge => 'Vos gains estimés';

  @override
  String requestMeta(String pickup, String trip, String distance) {
    return '$pickup min jusqu’au passager · Course $trip min · $distance';
  }

  @override
  String pickupSuffix(String area) {
    return '$area · Départ';
  }

  @override
  String dropoffSuffix(String area) {
    return '$area · Arrivée';
  }

  @override
  String verifiedRider(String rating) {
    return '★ $rating · Passager vérifié';
  }

  @override
  String get askForPin => 'Demandez le code PIN à la voiture';

  @override
  String acceptRideSeconds(String seconds) {
    return 'Accepter · $seconds s';
  }

  @override
  String get declineRequest => 'Refuser la demande';

  @override
  String headToRider(String name) {
    return 'Rejoignez $name';
  }

  @override
  String headToSubtitle(String place, String minutes, String distance) {
    return '$place · $minutes min · $distance';
  }

  @override
  String navContinue(String distance) {
    return 'Continuez sur $distance';
  }

  @override
  String navTowards(String place) {
    return 'En direction de $place';
  }

  @override
  String navArriving(String place) {
    return 'Arrivée à $place';
  }

  @override
  String get tileMessage => 'Message';

  @override
  String get tileShareTrip => 'Partager';

  @override
  String get tileSafety => 'Sécurité';

  @override
  String pickupNote(String note) {
    return 'Note de prise en charge : « $note »';
  }

  @override
  String get stopSafely => 'Arrêtez-vous en sécurité avant de contacter votre passager.';

  @override
  String get arrivedAtPickup => 'Je suis arrivé';

  @override
  String get atPickupTitle => 'Vous êtes au point de départ';

  @override
  String atPickupSubtitle(String name) {
    return '$name a été prévenu(e) de votre arrivée.';
  }

  @override
  String askPinLabel(String name) {
    return 'Demandez à $name son code PIN à 4 chiffres';
  }

  @override
  String get pinVerified => '✓ PIN vérifié · Vous pouvez démarrer la course.';

  @override
  String confirmRiderNote(String place) {
    return 'Vérifiez le nom du passager avant de partir. Destination : $place.';
  }

  @override
  String driveTo(String place) {
    return 'Direction $place';
  }

  @override
  String driveSubtitle(String time, String minutes, String distance) {
    return 'Arrivée $time · $minutes min · $distance restants';
  }

  @override
  String tripInProgress(String ref) {
    return 'Course en cours · $ref';
  }

  @override
  String get endRide => 'Terminer la course';

  @override
  String get cancelThisRide => 'Annuler cette course';

  @override
  String navTurnRight(String distance) {
    return 'Tournez à droite dans $distance';
  }

  @override
  String navInto(String street) {
    return 'Sur $street';
  }

  @override
  String navOn(String street) {
    return 'Sur $street';
  }

  @override
  String mainEntrance(String area) {
    return '$area · Entrée principale';
  }

  @override
  String get earnTitle => 'Vos gains';

  @override
  String earnSubtitle(String range) {
    return '$range · Net après frais de service';
  }

  @override
  String get periodWeek => 'Semaine';

  @override
  String get periodMonth => 'Mois';

  @override
  String get periodYear => 'Année';

  @override
  String get weekSoFar => 'Cette semaine';

  @override
  String get monthSoFar => 'Ce mois-ci';

  @override
  String get yearSoFar => 'Cette année';

  @override
  String tripsDriving(String trips, String time) {
    return '$trips · $time de conduite';
  }

  @override
  String get nextPayout => 'Prochain versement prévu';

  @override
  String nextPayoutDetail(String date, String account) {
    return '$date · $account';
  }

  @override
  String get payoutHistory => 'Historique des versements';

  @override
  String paidTo(String account) {
    return 'Versé sur $account';
  }

  @override
  String payoutPending(String account) {
    return 'En cours d’envoi sur $account';
  }

  @override
  String payoutFailed(String reason) {
    return 'Échec · $reason';
  }

  @override
  String get statusPaid => 'Versé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusFailed => 'Échec';

  @override
  String get viewPayoutDetails => 'Voir le détail du versement';

  @override
  String get noPayoutsYet => 'Aucun versement pour l’instant. Les gains sont versés chaque lundi.';

  @override
  String get weekdayLetters => 'L,M,M,J,V,S,D';

  @override
  String get monthLetters => 'J,F,M,A,M,J,J,A,S,O,N,D';

  @override
  String weekN(String n) {
    return 'S$n';
  }

  @override
  String get payoutTitle => 'Détail du versement';

  @override
  String payoutSubtitle(String ref, String range) {
    return '$ref · $range';
  }

  @override
  String sentOn(String date) {
    return 'Envoyé le $date';
  }

  @override
  String requestedOn(String date) {
    return 'Demandé le $date';
  }

  @override
  String get payoutBreakdown => 'Détail du versement';

  @override
  String rideFaresLine(String trips) {
    return 'Courses · $trips';
  }

  @override
  String get rentalHandoverEarnings => 'Gains de remise de location';

  @override
  String get tipsLine => 'Pourboires';

  @override
  String get serviceFeesLine => 'Frais de service';

  @override
  String get netPayout => 'Versement net';

  @override
  String mobileMoneyTransfer(String name) {
    return '$name · Transfert mobile money';
  }

  @override
  String get transferTimeline => 'Suivi du transfert';

  @override
  String get tlCreated => 'Versement créé';

  @override
  String tlCreatedBody(String time) {
    return '$time · Gains de la semaine calculés';
  }

  @override
  String get tlSent => 'Transfert envoyé';

  @override
  String tlSentBody(String time, String ref) {
    return '$time · Référence $ref';
  }

  @override
  String get tlDelivered => 'Transfert reçu';

  @override
  String tlDeliveredBody(String time) {
    return '$time · Fonds reçus';
  }

  @override
  String get tlWaiting => 'En attente de l’opérateur';

  @override
  String payoutHelp(String ref) {
    return 'Besoin d’aide ? Indiquez $ref au support.';
  }

  @override
  String get downloadStatement => 'Télécharger le relevé';

  @override
  String statementTitle(String ref) {
    return 'Versement iyodriver $ref';
  }

  @override
  String get bookingsHeading => 'Vos réservations';

  @override
  String get bookingsSub => 'Remises à venir et courses terminées.';

  @override
  String get segUpcoming => 'À venir';

  @override
  String get segHistory => 'Historique';

  @override
  String airportPickupConfirmed(String status) {
    return 'Retrait aéroport · $status';
  }

  @override
  String addressPickupStatus(String status) {
    return 'Livraison · $status';
  }

  @override
  String get statusConfirmedShort => 'Confirmée';

  @override
  String rentalWhenWhere(String when, String place) {
    return '$when · $place';
  }

  @override
  String returnWhenWhere(String when, String place) {
    return 'Retour : $when · $place';
  }

  @override
  String get viewHandoverRequirements => 'Voir les consignes de remise';

  @override
  String get viewReturnSteps => 'Voir l’inspection de retour';

  @override
  String get todaysCompletedRides => 'Courses terminées aujourd’hui';

  @override
  String get statusCompletedShort => 'Terminée';

  @override
  String get bookingsFootnote => 'Les montants sont nets des frais de service. Retrouvez tout l’historique dans Historique.';

  @override
  String get noUpcomingTitle => 'Rien de prévu pour l’instant';

  @override
  String get noUpcomingBody => 'Les remises de location qui vous sont confiées apparaissent ici.';

  @override
  String get pastRentals => 'Locations';

  @override
  String get pastRides => 'Courses';

  @override
  String perDayBadge(String price) {
    return '$price / jour';
  }

  @override
  String carSpecs(String fuel, String gearbox, String seats) {
    return '$fuel · $gearbox · $seats places';
  }

  @override
  String get fuelPetrol => 'Essence';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybride';

  @override
  String get fuelElectric => 'Électrique';

  @override
  String get gearAutomatic => 'Automatique';

  @override
  String get gearManual => 'Manuelle';

  @override
  String get accountHeading => 'Compte chauffeur';

  @override
  String get accountSub => 'Votre profil et vos documents.';

  @override
  String driverMeta(String rating, String trips, String ref) {
    return '★ $rating · $trips · Chauffeur $ref';
  }

  @override
  String get verifiedDriver => 'Chauffeur vérifié';

  @override
  String get yourVehicle => 'Votre véhicule';

  @override
  String vehicleSpecs(String colour, String year, String seats) {
    return '$colour · $year · $seats places';
  }

  @override
  String plateServices(String plate) {
    return '$plate · Course et location';
  }

  @override
  String categoryApproved(String category) {
    return '$category · Approuvé';
  }

  @override
  String categoryInReview(String category) {
    return '$category · En cours d’examen';
  }

  @override
  String get documentsHeading => 'Documents';

  @override
  String docVerifiedExpires(String date) {
    return 'Vérifié · Expire le $date';
  }

  @override
  String get docVerified => 'Vérifié';

  @override
  String docRenewBy(String date) {
    return 'À renouveler avant le $date';
  }

  @override
  String get docInReview => 'En cours d’examen';

  @override
  String docNeedsAction(String reason) {
    return 'Action requise · $reason';
  }

  @override
  String get docNotUploaded => 'Pas encore envoyé';

  @override
  String get payoutDetailsRow => 'Coordonnées de versement';

  @override
  String get notSet => 'Non renseigné';

  @override
  String get vehicleChangeNote => 'Modifier le véhicule peut nécessiter un nouvel examen avant de passer en ligne.';

  @override
  String get editAccount => 'Modifier mon compte';

  @override
  String get moreSection => 'Plus';

  @override
  String flowSetup(String step) {
    return 'Inscription chauffeur · $step';
  }

  @override
  String get setupTitle => 'Préparons votre départ';

  @override
  String get setupStep1 => 'Étape 1 sur 2 · Identité et véhicule';

  @override
  String get driverAccountBadge => 'Compte chauffeur';

  @override
  String get legalName => 'Nom légal';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get dateOfBirthHint => 'JJ/MM/AAAA';

  @override
  String get dobInvalid => 'Saisissez votre date de naissance (21 ans minimum).';

  @override
  String get vehicleMakeModel => 'Marque et modèle du véhicule';

  @override
  String get vehicleMakeModelHint => 'Toyota Corolla · 2018 · Blanc';

  @override
  String get vehicleRegistration => 'Immatriculation';

  @override
  String get vehicleCheckedHelper => 'Les informations du véhicule seront vérifiées avec vos documents.';

  @override
  String get legalDetailsNote => 'Vos informations légales servent à la vérification. Les passagers ne voient que votre prénom et votre véhicule.';

  @override
  String get saveAndContinue => 'Enregistrer et passer aux documents';

  @override
  String get vehicleSheetTitle => 'Votre véhicule';

  @override
  String get moreDetails => 'Également requis pour la vérification';

  @override
  String get docsTitle => 'Une rapide vérification';

  @override
  String get setupStep2 => 'Étape 2 sur 2 · Envoyez vos documents';

  @override
  String docsReady(String n, String total) {
    return '$n documents sur $total prêts';
  }

  @override
  String get groupIdentity => 'Pièce d’identité et selfie';

  @override
  String get groupIdentityDone => 'Photos d’identité reçues';

  @override
  String get groupLicence => 'Permis de conduire';

  @override
  String get groupLicenceDone => 'Permis envoyé';

  @override
  String get groupVehicle => 'Papiers du véhicule';

  @override
  String get groupVehicleDone => 'Carte grise et visite technique envoyées';

  @override
  String get groupInsurance => 'Attestation d’assurance';

  @override
  String get groupInsuranceDone => 'Assurance envoyée';

  @override
  String get groupApproved => 'Approuvé';

  @override
  String get groupInReview => 'Envoyé · en cours d’examen';

  @override
  String groupMissing(String n) {
    return '$n à envoyer';
  }

  @override
  String nextDocument(String doc) {
    return 'Ensuite : $doc';
  }

  @override
  String get noFileYet => 'Pas encore de photo';

  @override
  String get uploadTips => 'Conseils pour un envoi réussi';

  @override
  String get uploadTipsBody => 'Gardez les quatre coins visibles. Utilisez un bon éclairage et évitez les reflets. Formats : JPG, PNG ou PDF, 10 Mo max.';

  @override
  String get reviewTimeNote => 'Après envoi, l’examen prend en général 1 à 2 jours ouvrés. Nous vous préviendrons dès votre validation.';

  @override
  String uploadDoc(String doc) {
    return 'Envoyer la photo : $doc';
  }

  @override
  String retakeDoc(String doc) {
    return 'Reprendre la photo : $doc';
  }

  @override
  String get identityLocked => 'Les informations vérifiées sont verrouillées. Contactez le support pour les modifier.';

  @override
  String flowDriverRental(String step) {
    return 'Location chauffeur · $step';
  }

  @override
  String get airportRentalPickup => 'Remise à l’aéroport';

  @override
  String get addressRentalPickup => 'Livraison de location';

  @override
  String get rentalReturnTitle => 'Retour de location';

  @override
  String confirmedBooking(String ref) {
    return 'Réservation confirmée · $ref';
  }

  @override
  String upcomingWhen(String when) {
    return 'À venir · $when';
  }

  @override
  String withRiderUntil(String when) {
    return 'Chez le passager · jusqu’au $when';
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
    return 'Retrait · $day';
  }

  @override
  String returnOn(String day) {
    return 'Retour · $day';
  }

  @override
  String timeAtPlace(String time, String place) {
    return '$time · $place';
  }

  @override
  String get airportRequirementsTitle => 'Consignes de retrait à l’aéroport';

  @override
  String flightLine(String flight, String route) {
    return '$flight · $route';
  }

  @override
  String landingLine(String when, String terminal) {
    return 'Atterrissage : $when · $terminal';
  }

  @override
  String meetLine(String time, String name) {
    return 'Rendez-vous aux arrivées, $time. Tenez une pancarte iyodriver au nom de $name.';
  }

  @override
  String prepareCarNote(String minutes, String name) {
    return 'Préparez une voiture propre avec le plein. Prévoyez $minutes min après l’atterrissage et contactez $name en cas de retard.';
  }

  @override
  String prepareCarNoteAddress(String name) {
    return 'Préparez une voiture propre avec le plein. Appelez $name en cas de retard.';
  }

  @override
  String navigateToPlace(String place) {
    return 'Itinéraire vers $place';
  }

  @override
  String get openHandover => 'Commencer la remise';

  @override
  String get askHandoverPin => 'Demandez le code de remise à la voiture';

  @override
  String get smoothHandover => 'Une remise sans souci';

  @override
  String handoverSubtitle(String name, String place, String date) {
    return '$name · $place · $date';
  }

  @override
  String carPlateBadge(String car, String plate) {
    return '$car · $plate';
  }

  @override
  String get checkIdentity => 'Identité et permis vérifiés';

  @override
  String get checkIdentityBody => 'Le nom correspond à la réservation';

  @override
  String get checkIdentityTap => 'Touchez après avoir vu la pièce d’identité et le permis';

  @override
  String get checkDeposit => 'Caution autorisée';

  @override
  String checkDepositBody(String amount, String method) {
    return 'Caution de $amount · $method';
  }

  @override
  String get checkPhotos => 'Photos de l’état du véhicule';

  @override
  String checkPhotosDone(String n, String damage) {
    return '$n photos enregistrées · $damage';
  }

  @override
  String get checkPhotosTodo => 'Prenez les 5 photos';

  @override
  String get noNewDamage => 'Aucun nouveau dommage';

  @override
  String get damageNoted => 'Dommage relevé';

  @override
  String get checkFuel => 'Carburant et kilométrage relevés';

  @override
  String checkFuelDone(String fuel, String km) {
    return '$fuel · $km km';
  }

  @override
  String get checkFuelTodo => 'Relevés avec les photos';

  @override
  String get fullTank => 'Plein';

  @override
  String tankEighths(String n) {
    return '$n/8 du réservoir';
  }

  @override
  String get customerHandoverPin => 'Code de remise du client';

  @override
  String get handoverPinVerified => '✓ Code vérifié · Contrat de location accepté';

  @override
  String handoverReturnNote(String when, String place, String name) {
    return 'Retour : $when · $place. Remettez les clés à $name après toutes les vérifications.';
  }

  @override
  String get confirmHandoverStart => 'Confirmer la remise et démarrer';

  @override
  String handoverPinWrong(String n) {
    return 'Code incorrect · $n essais restants';
  }

  @override
  String get handoverPinLocked => 'Trop d’essais. L’équipe sécurité est prévenue ; appelez le support.';

  @override
  String get handoverDone => 'Remise terminée. La location a commencé.';
}
