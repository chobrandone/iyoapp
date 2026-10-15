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
}
