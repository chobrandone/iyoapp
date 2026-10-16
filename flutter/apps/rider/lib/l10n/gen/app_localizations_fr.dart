// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get placeholderFlowLabel => 'Passager · 00';

  @override
  String get placeholderTitle => 'Votre ville. À votre façon.';

  @override
  String get placeholderSubtitle => 'Courses et location de voitures à Douala et Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Exemple de tarif : $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Heure locale (Douala) : $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Ligne d\'assistance : $phone';
  }

  @override
  String get placeholderPrimary => 'Commencer';

  @override
  String get placeholderSecondary => 'Switch to English';

  @override
  String flowStart(String step) {
    return 'Début · $step';
  }

  @override
  String flowAccount(String step) {
    return 'Compte · $step';
  }

  @override
  String flowRider(String step) {
    return 'Passager · $step';
  }

  @override
  String get flowRiderPlain => 'Passager';

  @override
  String get flowSafety => 'Passager · Sécurité';

  @override
  String get flowSafetySent => 'Passager · Alerte envoyée';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabActivity => 'Activité';

  @override
  String get tabSafety => 'Sécurité';

  @override
  String get tabAccount => 'Compte';

  @override
  String get recenterMap => 'Recentrer la carte';

  @override
  String ratingTrips(String rating, String trips) {
    return '★ $rating · $trips courses';
  }

  @override
  String callPerson(String name) {
    return 'Appeler $name';
  }

  @override
  String messagePerson(String name) {
    return 'Écrire à $name';
  }

  @override
  String get tileMessage => 'Message';

  @override
  String get tileShareTrip => 'Partager';

  @override
  String get tileSafety => 'Sécurité';

  @override
  String get read => 'Lu';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get writeMessage => 'Écrire un message…';

  @override
  String get send => 'Envoyer';

  @override
  String get attach => 'Joindre';

  @override
  String get welcomeHeroTitle => 'Votre ville.\nÀ votre façon.';

  @override
  String get welcomeBadge => 'Courses + locations';

  @override
  String get welcomeHeadline => 'Moins d\'attente.\nPlus de mouvement.';

  @override
  String get welcomeBody =>
      'Réservez une course ou une voiture pour quelques jours. Où que la vie vous mène, allez-y avec iyodriver.';

  @override
  String get welcomeGetStarted => 'Commencer';

  @override
  String get welcomeHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get logIn => 'Se connecter';

  @override
  String get signUpTitle => 'Faisons connaissance';

  @override
  String get signUpSubtitle => 'Quelques informations, et vous êtes prêt.';

  @override
  String get signUpBadge => 'Compte passager';

  @override
  String get fieldFullName => 'Nom complet';

  @override
  String get fieldEmail => 'Adresse e-mail';

  @override
  String get fieldEmailHelper => 'Vos reçus et confirmations de location arrivent ici.';

  @override
  String get fieldMobile => 'Numéro de mobile';

  @override
  String get fieldPassword => 'Mot de passe';

  @override
  String get passwordRule => '✓ 8 caractères minimum, un chiffre et un symbole';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get agreeTerms =>
      'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité.';

  @override
  String get alreadyRegistered => 'Déjà inscrit ?';

  @override
  String get createAndVerify => 'Créer le compte et vérifier';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle =>
      'Connectez-vous avec votre numéro. Nous vous enverrons un code par SMS.';

  @override
  String get loginSendCode => 'Envoyer le code';

  @override
  String get noAccount => 'Nouveau sur iyodriver ?';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get verifyTitle => 'Consultez vos messages';

  @override
  String verifySubtitle(String phone) {
    return 'Saisissez le code envoyé au $phone.';
  }

  @override
  String get otpLabel => 'Code de vérification';

  @override
  String resendIn(String time) {
    return 'Pas reçu de code ? Renvoyer dans $time';
  }

  @override
  String get resendNow => 'Pas reçu de code ? Renvoyer';

  @override
  String get wrongNumber => 'Mauvais numéro ?';

  @override
  String get changeIt => 'Le modifier';

  @override
  String get saferStartTitle => 'Un départ plus sûr';

  @override
  String get saferStartBody =>
      'La vérification relie chaque trajet iyodriver à une vraie personne.';

  @override
  String get verifyContinue => 'Vérifier et continuer';

  @override
  String homeGreeting(String name) {
    return 'On va où, $name ?';
  }

  @override
  String homeYouAreAt(String place) {
    return 'Vous êtes à $place';
  }

  @override
  String get serviceRide => 'Course';

  @override
  String get serviceRent => 'Louer une voiture';

  @override
  String get whereTo => 'Où allez-vous ?';

  @override
  String get savedHome => 'Maison';

  @override
  String get savedWork => 'Travail';

  @override
  String recentDestination(String area) {
    return 'Destination récente · $area';
  }

  @override
  String nearbyRides(String fare, String minutes) {
    return 'Courses proches dès $fare · Prise en charge dans $minutes min environ';
  }

  @override
  String get planTitle => 'Planifiez votre course';

  @override
  String get planSubtitle => 'Confirmez où nous vous retrouvons.';

  @override
  String get fieldPickup => 'Départ';

  @override
  String get fieldDestination => 'Destination';

  @override
  String get currentLocation => '✓ Position actuelle';

  @override
  String get editPickup => 'Modifier le départ';

  @override
  String get whenWho => 'Maintenant · 1 passager';

  @override
  String routeSummary(String distance, String minutes) {
    return '$distance · Environ $minutes minutes avec le trafic actuel';
  }

  @override
  String get confirmRoute => 'Confirmer l\'itinéraire';

  @override
  String arrivingTitle(String name) {
    return '$name arrive';
  }

  @override
  String arrivingSubtitle(String minutes, String distance) {
    return 'Arrivée dans $minutes min · à $distance';
  }

  @override
  String pickupPin(String pin) {
    return 'Votre code PIN · $pin';
  }

  @override
  String pinCardBody(String place, String name) {
    return 'Rendez-vous à $place. Donnez ce code à $name avant de démarrer.';
  }

  @override
  String get checkPlate => 'Vérifiez la plaque et le chauffeur avant de monter.';

  @override
  String standardFare(String fare) {
    return 'Tarif Standard · $fare';
  }

  @override
  String get viewPickupDetails => 'Voir les détails du départ';

  @override
  String get onWayTitle => 'Vous êtes en route';

  @override
  String arriveAt(String place, String time) {
    return '$place · Arrivée $time';
  }

  @override
  String timeLeft(String minutes, String distance) {
    return 'Encore $minutes min · $distance';
  }

  @override
  String tripFooter(String fare, String method, String trip) {
    return '$fare · $method · Course $trip';
  }

  @override
  String get arrivedTitle => 'Vous êtes arrivé';

  @override
  String get arrivedSubtitle => 'Merci d\'avoir voyagé avec iyodriver.';

  @override
  String get paymentComplete => '✓ Paiement effectué';

  @override
  String get rideFare => 'Prix de la course';

  @override
  String get bookingFee => 'Frais de réservation';

  @override
  String receiptSent(String method) {
    return '$method · Reçu envoyé par e-mail';
  }

  @override
  String get howWasRide => 'Comment était votre course ?';

  @override
  String starsLabel(String count) {
    return '$count étoiles sur 5';
  }

  @override
  String get noTip => 'Sans pourboire';

  @override
  String get submitRating => 'Noter et terminer';

  @override
  String chatWith(String name) {
    return 'Discussion avec $name';
  }

  @override
  String chatSubtitle(String ride, String place) {
    return '$ride · Départ à $place';
  }

  @override
  String arrivingIn(String minutes) {
    return 'Arrivée dans $minutes min';
  }

  @override
  String get privacyNote => 'Aujourd\'hui · Votre numéro reste privé.';

  @override
  String get imHere => 'Je suis là';

  @override
  String get callDriver => 'Appeler';

  @override
  String chatFooter(String number) {
    return 'Écrivez uniquement au sujet de la prise en charge. En cas de danger, appelez le $number.';
  }

  @override
  String get noDriversTitle => 'Aucun chauffeur à proximité';

  @override
  String noDriversSubtitle(String area) {
    return 'Forte demande autour de $area en ce moment.';
  }

  @override
  String get tryAgainShortly => 'Réessayons dans un instant';

  @override
  String get noMatchBody =>
      'Aucun chauffeur disponible n\'a pu accepter votre demande. Vous n\'avez pas été débité.';

  @override
  String toPlace(String place) {
    return 'Vers $place';
  }

  @override
  String get requestNotBooked => 'Demande non réservée';

  @override
  String get noDriversHint =>
      'Essayez un point de départ proche ou réessayez dans quelques minutes. La disponibilité change vite.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get changePickup => 'Changer le départ';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Les nouvelles de vos courses et locations.';

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterUnread => 'Non lues';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get badgeNew => 'Nouveau';

  @override
  String get badgeRentalUpdate => 'Location';

  @override
  String get notificationsFooter => 'Gérez les notifications et e-mails dans votre compte.';

  @override
  String get activityTitle => 'Votre activité';

  @override
  String get activitySubtitle => 'Tous vos trajets, au même endroit.';

  @override
  String get filterRides => 'Courses';

  @override
  String get filterRentals => 'Locations';

  @override
  String get upcomingRental => 'Location à venir';

  @override
  String get recentJourneys => 'Trajets récents';

  @override
  String perDay(String rate) {
    return '$rate / jour';
  }

  @override
  String get statusConfirmed => 'Confirmée';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get activityFooter => 'Touchez un trajet pour voir son reçu ou obtenir de l\'aide.';

  @override
  String get safetyTitle => 'Votre sécurité d\'abord';

  @override
  String get safetySubtitle => 'L\'aide est toujours à portée de main.';

  @override
  String activeTrip(String trip) {
    return 'Course en cours · $trip';
  }

  @override
  String emergencyHelp(String number) {
    return 'Urgence · Appelez le $number';
  }

  @override
  String get emergencyHelpBody => 'En cas de danger immédiat ou d’urgence médicale.';

  @override
  String get alertNotEmergency => 'Une alerte n\'appelle pas automatiquement les secours.';

  @override
  String get shareLiveTrip => 'Partager le trajet en direct';

  @override
  String get shareLiveTripBody => 'Permettez à un proche de suivre votre trajet.';

  @override
  String get trustedContactSelected => 'Contact de confiance · Sélectionné';

  @override
  String get trustedContactHelper =>
      'Position en direct, chauffeur, véhicule et lien du trajet seront envoyés.';

  @override
  String get messagePreview => 'Aperçu du message';

  @override
  String get defaultAlertMessage =>
      'J\'ai besoin d\'aide. Prends de mes nouvelles et suis mon trajet iyodriver en direct.';

  @override
  String currentLocationAt(String place) {
    return 'Position actuelle : $place';
  }

  @override
  String get sendAlert => 'Envoyer l\'alerte';

  @override
  String get sendAlertFooter =>
      'Envoie votre position et les détails du trajet à votre contact de confiance et à l\'équipe sécurité iyodriver.';

  @override
  String get alertSentTitle => 'Votre alerte a été envoyée';

  @override
  String get alertSentSubtitle => 'Vous n\'êtes pas seul. Restez en lieu sûr.';

  @override
  String get alertActive => 'Alerte de sécurité active';

  @override
  String sentTodayAt(String time) {
    return 'Envoyée aujourd\'hui à $time';
  }

  @override
  String contactNotified(String name) {
    return '$name prévenu(e)';
  }

  @override
  String get contactNotifiedBody => 'Message et lien du trajet envoyés.';

  @override
  String get safetyTeamNotified => 'Équipe sécurité iyodriver prévenue';

  @override
  String get safetyTeamBody => 'Les détails du trajet et votre position ont été partagés.';

  @override
  String get liveSharingOn => 'Partage de position activé';

  @override
  String alertSentHint(String number) {
    return 'En cas de danger immédiat, appelez le $number. Votre alerte n\'a pas contacté les secours.';
  }

  @override
  String callEmergency(String number) {
    return 'Appeler les secours · $number';
  }

  @override
  String get returnToTrip => 'Retour au trajet';

  @override
  String get savedTitle => 'Adresses enregistrées';

  @override
  String get savedSubtitle => 'Moins de saisie, plus de trajets.';

  @override
  String get otherFavourites => 'Autres favoris';

  @override
  String get savedFooter =>
      'Touchez une adresse pour la modifier. Vos adresses ne sont visibles que par vous.';

  @override
  String get addPlace => 'Ajouter une adresse';

  @override
  String get tcTitle => 'Contacts de confiance';

  @override
  String get tcSubtitle => 'Tenez vos proches informés.';

  @override
  String get shareJourney => 'Partagez votre trajet';

  @override
  String get shareJourneyBody1 =>
      'Envoyez un lien de suivi à vos contacts pendant n\'importe quelle course.';

  @override
  String get shareJourneyBody2 =>
      'Vos contacts voient l\'itinéraire, le chauffeur et l\'heure d\'arrivée quand vous partagez.';

  @override
  String yourContacts(String count, String max) {
    return 'Vos contacts · $count sur $max';
  }

  @override
  String get statusVerified => 'Vérifié';

  @override
  String get invitationPending => 'Invitation en attente';

  @override
  String shareTripsWith(String name) {
    return 'Partage avec $name · Activé';
  }

  @override
  String get resendInvitation => 'Renvoyer l\'invitation';

  @override
  String get inControl => 'C\'est vous qui décidez';

  @override
  String get inControlBody =>
      'Le partage ne commence que lorsque vous envoyez un lien. Vous pouvez l\'arrêter ou retirer un contact à tout moment.';

  @override
  String tcFooter(String number) {
    return 'Vos contacts ne sont pas des secouristes. En cas de danger immédiat, appelez le $number.';
  }

  @override
  String get addTrustedContact => 'Ajouter un contact';

  @override
  String get walletTitle => 'Portefeuille';

  @override
  String get walletSubtitle => 'Des paiements simples et sûrs pour chaque trajet.';

  @override
  String get rideCredit => 'Crédit de course';

  @override
  String get creditApplied => 'Appliqué automatiquement à votre prochaine course.';

  @override
  String get paymentMethods => 'Moyens de paiement';

  @override
  String get badgeDefault => 'Par défaut';

  @override
  String get cashMethod => 'Espèces';

  @override
  String get cashBody => 'Payez le chauffeur à la fin de la course';

  @override
  String walletNumber(String number) {
    return 'Compte $number';
  }

  @override
  String get recentPayments => 'Paiements récents';

  @override
  String get walletFooter => 'Les cautions de location sont bloquées temporairement, pas débitées.';

  @override
  String get addPaymentMethod => 'Ajouter un moyen de paiement';

  @override
  String get supportTitle => 'Assistance iyodriver';

  @override
  String supportSubtitle(String caseId, String topic) {
    return 'Dossier $caseId · $topic';
  }

  @override
  String supportAgent(String name) {
    return '$name · Conseillère support';
  }

  @override
  String get repliesWithin => 'Répond généralement en quelques minutes';

  @override
  String get conversationOpen => 'Conversation ouverte';

  @override
  String supportFooter(String number) {
    return 'Cette discussion n\'est pas un service d\'urgence. En cas de danger immédiat, appelez le $number.';
  }

  @override
  String demoCodeHint(String code) {
    return 'Mode démo · utilisez le code $code';
  }

  @override
  String get otpInvalid => 'Ce code n\'est pas correct. Vérifiez le SMS et réessayez.';

  @override
  String get wrongApp =>
      'Ce numéro est inscrit comme chauffeur. Utilisez l\'application iyodriver Driver.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get currentLocationLabel => 'Position actuelle';

  @override
  String get locatingYou => 'Recherche de votre position…';

  @override
  String get locationDeniedTitle => 'Localisation désactivée';

  @override
  String get locationDeniedBody =>
      'Autorisez la localisation pour que les chauffeurs vous trouvent, ou saisissez votre adresse.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get searchPlaces => 'Rechercher un lieu à Douala ou Yaoundé';

  @override
  String get noPlacesFound => 'Aucun lieu trouvé';

  @override
  String get chooseTitle => 'Choisissez une course';

  @override
  String chooseSubtitle(String distance, String minutes, String place) {
    return '$distance · environ $minutes min jusqu’à $place';
  }

  @override
  String seats(String count) {
    return '$count places';
  }

  @override
  String etaAway(String minutes) {
    return 'à $minutes min';
  }

  @override
  String get noEta => 'Disponibilité limitée';

  @override
  String get upfrontPrice => 'Prix fixé à l’avance · tarifs provisoires';

  @override
  String get paymentMethod => 'Moyen de paiement';

  @override
  String bookCategory(String category, String fare) {
    return 'Réserver $category · $fare';
  }

  @override
  String get quoteExpired => 'Les prix ont changé. Voici les nouveaux.';

  @override
  String get matchingTitle => 'Recherche de votre chauffeur';

  @override
  String matchingSubtitle(String place) {
    return 'Nous contactons les chauffeurs près de $place';
  }

  @override
  String matchingBody(String fare) {
    return 'Cela prend en général moins d’une minute. Votre prix est fixé à $fare.';
  }

  @override
  String get cancelRequest => 'Annuler la demande';

  @override
  String driverArrivedTitle(String name) {
    return '$name est arrivé';
  }

  @override
  String driverArrivedSubtitle(String place) {
    return 'Rendez-vous à $place et donnez votre code';
  }

  @override
  String get cancelRide => 'Annuler la course';

  @override
  String get cancelTitle => 'Annuler cette course ?';

  @override
  String get cancelBody => 'Dites-nous pourquoi. Aucuns frais tant que le chauffeur est en route.';

  @override
  String get cancelReasonWait => 'Attente trop longue';

  @override
  String get cancelReasonPlans => 'Changement de programme';

  @override
  String get cancelReasonPickup => 'Mauvais point de départ';

  @override
  String get cancelReasonOther => 'Autre raison';

  @override
  String get keepRide => 'Garder ma course';

  @override
  String get confirmCancel => 'Annuler la course';

  @override
  String get rideCancelledTitle => 'Course annulée';

  @override
  String get rideCancelledByDriver => 'Votre chauffeur a annulé. Vous n\'avez pas été débité.';

  @override
  String get rideCancelledByYou => 'Vous avez annulé cette course.';

  @override
  String get backHome => 'Retour à l\'accueil';

  @override
  String get errorTitle => 'Une erreur est survenue';

  @override
  String get paymentCash => 'Espèces';

  @override
  String get paymentMtn => 'MTN MoMo';

  @override
  String get paymentOrange => 'Orange Money';

  @override
  String get paymentCard => 'Carte';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountSubtitle => 'Votre profil, vos paiements et votre sécurité.';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuWallet => 'Portefeuille';

  @override
  String get menuSavedPlaces => 'Adresses enregistrées';

  @override
  String get menuTrustedContacts => 'Contacts de confiance';

  @override
  String get menuSupport => 'Aide et assistance';

  @override
  String get menuLanguage => 'Langue';

  @override
  String get menuScreens => 'Tous les écrans (dev)';

  @override
  String get noActiveTrip => 'Aucune course en cours';

  @override
  String get emergencyCallTitle => 'Appeler les secours';

  @override
  String get emergencyPolice => 'Police';

  @override
  String get emergencyFire => 'Sapeurs-pompiers';

  @override
  String get emergencyAmbulance => 'Ambulance';

  @override
  String get shareNeedsTrip => 'Disponible pendant une course.';

  @override
  String get shareTripSubject => 'Ma course iyodriver';

  @override
  String shareTripText(String time, String link) {
    return 'Suivez ma course iyodriver en direct (lien valable jusqu’à $time) : $link';
  }

  @override
  String get shareFailed => 'Impossible de créer le lien de partage. Réessayez.';

  @override
  String get contactsToNotify => 'Contacts de confiance à prévenir';

  @override
  String get noContactsYet => 'Aucun contact de confiance pour l’instant.';

  @override
  String get addContactLink => 'Ajouter un contact de confiance';

  @override
  String get locationUnknown => 'Position actuelle indisponible';

  @override
  String alertFailed(String number) {
    return 'L’alerte n’a pas pu être envoyée. Vérifiez votre connexion ou appelez le $number.';
  }

  @override
  String contactsNotifiedCount(String count) {
    return '$count contacts de confiance prévenus';
  }

  @override
  String get noContactNotified => 'Aucun contact de confiance prévenu';

  @override
  String get noContactNotifiedBody =>
      'Ajoutez des contacts de confiance pour qu’on les prévienne la prochaine fois.';

  @override
  String get alertsOn => 'Alertes activées';

  @override
  String get alertsOff => 'Alertes désactivées';

  @override
  String textOnAlert(String name) {
    return 'Prévenir $name si je lance une alerte';
  }

  @override
  String get removeContact => 'Retirer';

  @override
  String removeContactTitle(String name) {
    return 'Retirer $name ?';
  }

  @override
  String get removeContactBody =>
      'Cette personne ne sera plus prévenue lorsque vous lancez une alerte.';

  @override
  String get contactName => 'Nom complet';

  @override
  String get contactPhone => 'Numéro de mobile';

  @override
  String get contactRelationship => 'Lien (facultatif)';

  @override
  String get contactRelationshipHint => 'Sœur, ami, collègue…';

  @override
  String get saveContact => 'Enregistrer le contact';

  @override
  String contactLimit(String max) {
    return 'Vous pouvez ajouter jusqu’à $max contacts de confiance.';
  }

  @override
  String get contactDuplicate => 'Ce numéro fait déjà partie de vos contacts de confiance.';

  @override
  String get contactsEmptyTitle => 'Ajoutez une personne de confiance';

  @override
  String get contactsEmptyBody =>
      'Elle reçoit un SMS avec votre course en direct si vous lancez une alerte.';

  @override
  String get flowRent => 'Passager · Location';

  @override
  String get rentHomeTitle => 'Louer une voiture';

  @override
  String get rentHomeBody => 'Location à la journée, livrée à votre adresse ou à l’aéroport.';

  @override
  String get browseCars => 'Voir les voitures';

  @override
  String get myRentals => 'Mes locations';

  @override
  String get rentTitle => 'Louer une voiture';

  @override
  String get rentSubtitle => 'Choisissez une voiture, puis vos dates et le lieu de remise.';

  @override
  String get cityDouala => 'Douala';

  @override
  String get cityYaounde => 'Yaoundé';

  @override
  String get noCarsTitle => 'Aucune voiture disponible';

  @override
  String get noCarsBody => 'Essayez l’autre ville ou revenez plus tard.';

  @override
  String get airportPickupBadge => 'Retrait aéroport';

  @override
  String get placeholderPricing =>
      'Les prix affichés sont provisoires en attendant les tarifs de la flotte.';

  @override
  String get transmissionAutomatic => 'Automatique';

  @override
  String get transmissionManual => 'Manuelle';

  @override
  String get fuelPetrol => 'Essence';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybride';

  @override
  String get fuelElectric => 'Électrique';

  @override
  String seatsCount(String count) {
    return '$count places';
  }

  @override
  String get carSpecs => 'Caractéristiques';

  @override
  String get specDailyRate => 'Tarif journalier';

  @override
  String get specDeposit => 'Caution (bloquée à la remise)';

  @override
  String get specKmPerDay => 'Kilométrage inclus';

  @override
  String kmPerDayValue(String km) {
    return '$km km / jour';
  }

  @override
  String get specExtraKm => 'Kilomètre supplémentaire';

  @override
  String perKm(String price) {
    return '$price / km';
  }

  @override
  String get specPlate => 'Immatriculation';

  @override
  String get chooseDates => 'Choisir les dates';

  @override
  String get datesTitle => 'Dates et retrait';

  @override
  String get datesSubtitle => 'La location est facturée par jour entamé (24 h).';

  @override
  String get startLabel => 'Début';

  @override
  String get endLabel => 'Retour';

  @override
  String get pickDate => 'Choisir une date';

  @override
  String daysCount(String days) {
    return '$days jours';
  }

  @override
  String get oneDay => '1 jour';

  @override
  String get pickupAddress => 'Adresse';

  @override
  String get pickupAirport => 'Aéroport';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get deliveryAddressHint => 'Rue, quartier, repère';

  @override
  String get airportLabel => 'Aéroport';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get flightNumber => 'Numéro de vol';

  @override
  String get flightNumberHint => 'ex. AF900';

  @override
  String get flightInvalid => 'Saisissez un numéro de vol comme AF900.';

  @override
  String get flightArrival => 'Heure d’arrivée';

  @override
  String airportFeeNote(String fee) {
    return 'Livraison à l’aéroport : $fee. Le chauffeur vous attend avec une pancarte aux arrivées.';
  }

  @override
  String get airportUnavailable => 'Cette voiture ne peut pas être livrée à l’aéroport.';

  @override
  String get periodInvalid => 'Le retour doit suivre le début, et le début être dans le futur.';

  @override
  String get reviewAndPay => 'Vérifier et payer';

  @override
  String get reviewTitle => 'Vérifiez votre location';

  @override
  String get reviewSubtitle =>
      'Vous payez la location maintenant. La caution est bloquée à la remise du véhicule.';

  @override
  String rentalDates(String start, String end) {
    return '$start → $end';
  }

  @override
  String rentalAmountLine(String days) {
    return 'Location · $days';
  }

  @override
  String get airportFeeLine => 'Livraison aéroport';

  @override
  String get totalNow => 'Total à payer maintenant';

  @override
  String get depositLater => 'Caution bloquée à la remise';

  @override
  String kmAllowance(String km) {
    return 'Kilométrage inclus : $km km';
  }

  @override
  String get paymentLabel => 'Paiement';

  @override
  String get cashAtHandover => 'Le paiement en espèces se fait au chauffeur à la remise.';

  @override
  String get rentalTerms => 'J’accepte les conditions de location et la caution.';

  @override
  String payAmount(String amount) {
    return 'Payer $amount';
  }

  @override
  String get bookCash => 'Réserver · espèces à la remise';

  @override
  String get carTaken =>
      'Cette voiture est déjà réservée à ces dates. Choisissez d’autres dates ou une autre voiture.';

  @override
  String get paymentMethodMissing =>
      'Ajoutez d’abord ce moyen de paiement dans votre portefeuille.';

  @override
  String bookingRef(String ref) {
    return 'Réservation $ref';
  }

  @override
  String get rentalPendingTitle => 'Validez le paiement';

  @override
  String rentalPendingBody(String amount) {
    return 'Confirmez $amount sur votre téléphone pour réserver la voiture.';
  }

  @override
  String get rentalConfirmedTitle => 'Réservation confirmée';

  @override
  String get rentalConfirmedBody => 'Nous assignons le chauffeur qui vous livrera la voiture.';

  @override
  String get rentalAssignedTitle => 'Chauffeur assigné';

  @override
  String rentalAssignedBody(String date) {
    return 'Votre chauffeur apporte la voiture le $date.';
  }

  @override
  String get handoverReadyTitle => 'Vérifiez la voiture';

  @override
  String get handoverReadyBody =>
      'Le chauffeur a relevé l’état de la voiture. Vérifiez-le avec lui, puis confirmez.';

  @override
  String get confirmHandover => 'Confirmer la remise';

  @override
  String get rentalActiveTitle => 'Bonne route';

  @override
  String rentalActiveBody(String date) {
    return 'Rendez la voiture avant le $date.';
  }

  @override
  String get returnCar => 'Rendre la voiture';

  @override
  String get returnRequested => 'Retour demandé. Le chauffeur inspectera la voiture avec vous.';

  @override
  String get returnReadyTitle => 'Vérifiez le retour';

  @override
  String get returnReadyBody =>
      'Vérifiez l’inspection de retour. Votre caution est libérée quand vous confirmez.';

  @override
  String get confirmReturn => 'Confirmer le retour';

  @override
  String get rentalCompletedTitle => 'Location terminée';

  @override
  String get depositReleased => 'Caution libérée en totalité';

  @override
  String depositPartiallyHeld(String amount) {
    return '$amount retenus sur la caution';
  }

  @override
  String get rentalCancelledTitle => 'Réservation annulée';

  @override
  String get cancelBooking => 'Annuler la réservation';

  @override
  String get cancelBookingTitle => 'Annuler cette réservation ?';

  @override
  String get cancelBookingBody => 'Vous pouvez annuler sans frais jusqu’au début de la location.';

  @override
  String get keepBooking => 'Garder la réservation';

  @override
  String get inspectionHandover => 'Inspection à la remise';

  @override
  String get inspectionReturn => 'Inspection au retour';

  @override
  String get fuelLevel => 'Carburant';

  @override
  String fuelEighths(String n) {
    return '$n/8 du réservoir';
  }

  @override
  String get odometer => 'Compteur';

  @override
  String kmValue(String km) {
    return '$km km';
  }

  @override
  String get photosTaken => 'Photos';

  @override
  String photosCount(String n) {
    return '$n côtés sur 5';
  }

  @override
  String get damageNotes => 'Dommages constatés';

  @override
  String get noDamage => 'Aucun dommage constaté';

  @override
  String get depositHoldProposed => 'Retenu sur la caution';

  @override
  String get statusPendingPayment => 'Paiement en attente';

  @override
  String get statusDriverAssigned => 'Chauffeur assigné';

  @override
  String get statusActive => 'En cours';

  @override
  String get statusReturnPending => 'Contrôle retour';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get rentalsEmptyTitle => 'Aucune location pour l’instant';

  @override
  String get rentalsEmptyBody => 'Vos réservations apparaissent ici.';

  @override
  String get rentalFailed => 'La réservation n’a pas abouti. Réessayez.';

  @override
  String pickupAt(String place) {
    return 'Retrait : $place';
  }

  @override
  String get rentalReportProblem => 'Signaler un problème';

  @override
  String flowRental(String step) {
    return 'Location · $step';
  }

  @override
  String get flowRentalPlain => 'Location';

  @override
  String get rentACar => 'Louer une voiture';

  @override
  String get carForPlans => 'Une voiture pour vos projets';

  @override
  String carForPlansSub(String city) {
    return '$city · Location flexible, retrait simple';
  }

  @override
  String datesRowTitle(String range, String days) {
    return '$range · $days';
  }

  @override
  String datesRowSub(String time) {
    return 'Retrait et retour à $time · Modifier les dates';
  }

  @override
  String airportAvailableLine(String km) {
    return '✓ Retrait aéroport possible · $km km / jour';
  }

  @override
  String kmPerDayLine(String km) {
    return '$km km / jour inclus';
  }

  @override
  String viewCarFor(String model, String price, String days) {
    return '$model · $price pour $days';
  }

  @override
  String get myRentalsLink => 'Mes locations';

  @override
  String get taglineSedan => 'Confortable et économique.';

  @override
  String get taglineSuv => 'De la place pour la famille et les bagages.';

  @override
  String get taglineEconomy => 'Petite et agile, faite pour la ville.';

  @override
  String get taglinePickup => 'Taillé pour la route et le chargement.';

  @override
  String seatsBadge(String n) {
    return '$n places';
  }

  @override
  String perDayPrice(String price) {
    return '$price / jour';
  }

  @override
  String kmIncludedTitle(String km) {
    return '$km km par jour inclus';
  }

  @override
  String kmIncludedSub(String price) {
    return 'Km supplémentaire $price / km · Carburant : rendre plein';
  }

  @override
  String get coverTitle => 'Assurance de base incluse';

  @override
  String coverSub(String price) {
    return 'Protection en option · $price / jour';
  }

  @override
  String coverAdded(String price) {
    return 'Protection ajoutée · $price / jour';
  }

  @override
  String get airportAvailableTitle => 'Retrait aéroport possible';

  @override
  String airportAvailableSub(String airport, String fee) {
    return '$airport · frais de retrait $fee';
  }

  @override
  String get addressOnlyTitle => 'Livrée à votre adresse';

  @override
  String get addressOnlySub => 'Le retrait à l’aéroport n’est pas proposé pour cette voiture.';

  @override
  String detailsFootnote(String deposit) {
    return 'Permis de conduire valide requis. Caution remboursable de $deposit. Annulation gratuite jusqu’au retrait.';
  }

  @override
  String chooseDatesPrice(String price) {
    return 'Choisir les dates · $price / jour';
  }

  @override
  String get makeTime => 'Prenez le temps qu’il faut';

  @override
  String get makeTimeSub => 'Choisissez les dates de retrait et de retour.';

  @override
  String pickupFieldLabel(String date) {
    return 'Retrait · $date';
  }

  @override
  String returnFieldLabel(String date) {
    return 'Retour · $date';
  }

  @override
  String daysBasePrice(String days, String price) {
    return '$days · $price prix de base';
  }

  @override
  String get datesFootnote =>
      'Les heures sont celles de Douala et Yaoundé. Le retour doit suivre le retrait. Un retour tardif peut entraîner un jour supplémentaire.';

  @override
  String continueDays(String days) {
    return 'Continuer · $days';
  }

  @override
  String get pickReturnDay => 'Choisissez maintenant le jour du retour.';

  @override
  String get monthNames =>
      'janvier,février,mars,avril,mai,juin,juillet,août,septembre,octobre,novembre,décembre';

  @override
  String get weekdayInitials => 'L,M,M,J,V,S,D';

  @override
  String get whereMeet => 'Où nous retrouver ?';

  @override
  String whereMeetSub(String when) {
    return 'Retrait · $when';
  }

  @override
  String get airportPickupToggle => 'Retrait à l’aéroport';

  @override
  String flightKnown(String airline, String flight) {
    return '✓ $airline · vol $flight';
  }

  @override
  String flightArrivalLabel(String date) {
    return 'Arrivée du vol · $date';
  }

  @override
  String localTime(String time) {
    return '$time · heure locale';
  }

  @override
  String meetAtArrivals(String terminal) {
    return 'Rendez-vous aux arrivées, $terminal';
  }

  @override
  String meetAllow(String minutes) {
    return 'Nous prévoyons $minutes min après l’atterrissage.';
  }

  @override
  String airportFeeBadge(String fee) {
    return 'Frais de retrait aéroport · $fee';
  }

  @override
  String get savePickupReview => 'Enregistrer et vérifier';

  @override
  String get addressPickupNote =>
      'Votre chauffeur apporte la voiture à cette adresse à l’heure du retrait.';

  @override
  String get getaway => 'Prêt pour l’escapade ?';

  @override
  String get getawaySub => 'Vérifiez votre réservation avant de payer.';

  @override
  String pickupDay(String day) {
    return 'Retrait · $day';
  }

  @override
  String returnDay(String day) {
    return 'Retour · $day';
  }

  @override
  String timePlace(String time, String place) {
    return '$time · $place';
  }

  @override
  String airportFlightBadge(String terminal, String flight, String time) {
    return 'Aéroport · $terminal · $flight · arrivée $time';
  }

  @override
  String daysTimesRate(String days, String rate) {
    return '$days × $rate';
  }

  @override
  String protectionLine(String days, String rate) {
    return 'Protection · $days × $rate';
  }

  @override
  String get airportPickupLine => 'Retrait aéroport';

  @override
  String get totalLine => 'Total à payer maintenant';

  @override
  String depositHeldAtPickup(String amount) {
    return 'Caution remboursable de $amount bloquée au retrait';
  }

  @override
  String get cashAtPickup => 'Payez le chauffeur en espèces au retrait';

  @override
  String acceptTermsLong(String when) {
    return 'J’accepte les conditions de location. Mon permis est valide. Annulation gratuite avant le $when.';
  }

  @override
  String confirmPay(String amount) {
    return 'Confirmer et payer $amount';
  }

  @override
  String get confirmCash => 'Confirmer · espèces au retrait';

  @override
  String get carBooked => 'Votre voiture est réservée';

  @override
  String carBookedSub(String ref) {
    return 'Réservation $ref · Détails dans vos notifications';
  }

  @override
  String paidBadge(String amount) {
    return 'Payé · $amount';
  }

  @override
  String paymentPendingBadge(String amount) {
    return 'Paiement en attente · $amount';
  }

  @override
  String cashBadge(String amount) {
    return 'Espèces au retrait · $amount';
  }

  @override
  String get allSetAirport => 'Tout est prêt pour le retrait à l’aéroport';

  @override
  String get allSetAddress => 'Tout est prêt pour la livraison';

  @override
  String flightSummary(String flight, String date, String time) {
    return 'Vol $flight · $date · Arrivée $time';
  }

  @override
  String driverMeetsYou(String time) {
    return 'Votre chauffeur vous attendra aux arrivées à $time.';
  }

  @override
  String driverBringsCar(String place, String time) {
    return 'Votre chauffeur apporte la voiture à $place à $time.';
  }

  @override
  String get bringDocuments =>
      'Munissez-vous de votre permis, d’une pièce d’identité et du téléphone utilisé pour la caution.';

  @override
  String handoverPinBadge(String pin) {
    return 'Votre code de remise · $pin';
  }

  @override
  String get viewMyRental => 'Voir ma location';

  @override
  String get addToCalendar => 'Ajouter au calendrier';

  @override
  String calendarTitle(String car) {
    return 'Location iyodriver · $car';
  }

  @override
  String get keysAreYours => 'Les clés sont à vous';

  @override
  String activeSince(String when) {
    return 'Location en cours · $when';
  }

  @override
  String activeBadge(String ref) {
    return 'En cours · $ref';
  }

  @override
  String carPlate(String car, String plate) {
    return '$car · $plate';
  }

  @override
  String returnBy(String day, String time) {
    return 'Retour avant $day · $time';
  }

  @override
  String remainingExtend(String left) {
    return '$left restants · Prolonger ›';
  }

  @override
  String daysHours(String d, String h) {
    return '$d jours, $h heures';
  }

  @override
  String hoursOnly(String h) {
    return '$h heures';
  }

  @override
  String driverTrips(String rating, String trips) {
    return '★ $rating · $trips courses';
  }

  @override
  String activeFootnote(String km) {
    return '$km km inclus · Rendez la voiture avec le plein. Besoin d’assistance ? Appelez le support.';
  }

  @override
  String get viewReturnInstructions => 'Voir les consignes de retour';

  @override
  String get manageRental => 'Gérer ma location';

  @override
  String manageSub(String ref, String name) {
    return 'Réservation $ref · $name';
  }

  @override
  String get confirmedHandoverPending => 'Confirmée · Remise à venir';

  @override
  String pickupReturnTimes(String pickup, String ret, String days) {
    return 'Retrait $pickup · Retour $ret · $days';
  }

  @override
  String get pickupAndReturn => 'Retrait et retour';

  @override
  String arrivalsMeetingPoint(String flight) {
    return 'Point de rencontre aux arrivées · Vol $flight';
  }

  @override
  String get deliveryAddressLine => 'Adresse de livraison';

  @override
  String get handoverContact => 'Votre contact de remise · Message ou appel';

  @override
  String get handoverContactPending => 'Chauffeur bientôt assigné';

  @override
  String get driverAssignedSoon => 'Nous assignerons votre chauffeur avant le retrait.';

  @override
  String get extendRental => 'Prolonger la location';

  @override
  String extendRentalSub(String price) {
    return 'Jours en plus à partir de $price, selon disponibilité';
  }

  @override
  String get changeBooking => 'Modifier la réservation';

  @override
  String get changeBookingSub => 'Changer le retrait, le retour ou le vol';

  @override
  String get returnVehicle => 'Rendre le véhicule';

  @override
  String get returnVehicleSub => 'Lieu de retour et étapes de l’inspection';

  @override
  String get cancelBookingSub => 'Gratuit jusqu’au retrait';

  @override
  String get bookingPaid => 'Réservation payée';

  @override
  String get bookingDue => 'Total de la réservation';

  @override
  String depositSeparate(String amount) {
    return 'Caution remboursable de $amount bloquée à part. Toute modification est chiffrée avant validation.';
  }

  @override
  String get viewPickupInstructions => 'Voir les consignes de retrait';

  @override
  String get returnInspection => 'Inspection de retour';

  @override
  String returnInspectionSub(String ref, String car, String plate) {
    return '$ref · $car · $plate';
  }

  @override
  String get inspectionComplete => 'Inspection terminée';

  @override
  String get inspectionWaiting => 'En attente du chauffeur';

  @override
  String returnedAt(String date, String time) {
    return '$date · Rendue à $time';
  }

  @override
  String checkedWith(String name) {
    return 'Vérifiée avec $name · Relisez avant de signer.';
  }

  @override
  String get vehicleCondition => 'État du véhicule';

  @override
  String get exteriorInterior => 'Extérieur et intérieur';

  @override
  String photosAttached(String damage, String n) {
    return '$damage · $n photos jointes';
  }

  @override
  String get fuelMileage => 'Carburant et kilométrage';

  @override
  String fuelMileageLine(String fuel, String used, String included) {
    return '$fuel · $used km utilisés sur $included inclus';
  }

  @override
  String get keysAccessories => 'Clés et accessoires';

  @override
  String get allItemsReturned => 'Tout a été rendu';

  @override
  String get itemsMissing => 'Éléments manquants · voir les notes';

  @override
  String get depositSummary => 'Récapitulatif de la caution';

  @override
  String get depositHeldLine => 'Caution bloquée';

  @override
  String get feesLine => 'Dommages, carburant et retard';

  @override
  String get depositReleaseLine => 'Caution à libérer';

  @override
  String get releaseNote =>
      'La libération est demandée après votre confirmation. Votre opérateur peut mettre 1 à 3 jours ouvrés.';

  @override
  String get reportBeforeConfirm => 'Un souci ? Signalez-le avant de confirmer.';

  @override
  String get confirmReturnSummary => 'Confirmer le récapitulatif';

  @override
  String get returnStepsTitle => 'Comment se passe le retour';

  @override
  String returnStepsBody(String place, String when) {
    return 'Rapportez la voiture à $place avant le $when. Votre chauffeur l’inspecte avec vous, puis vous confirmez ici.';
  }

  @override
  String get startReturnNow => 'Je rends la voiture';

  @override
  String get fullTank => 'Plein';
}
