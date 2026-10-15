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
}
