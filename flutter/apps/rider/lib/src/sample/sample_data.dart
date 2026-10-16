// Sample content for the design screens until the Supabase data hooks land (Phase 4+).
// The Figma frames use London placeholders; per the spec these are Cameroon equivalents.
// Content that the server would send already localised (chat, notifications) is given in
// both languages here; UI labels live in the ARB files.
import 'package:flutter/widgets.dart';
import 'package:iyo_core/iyo_core.dart';

/// Picks the sample text for the current language.
String tr(BuildContext context, String en, String fr) =>
    Localizations.localeOf(context).languageCode == 'fr' ? fr : en;

abstract final class Sample {
  // Rider
  static const riderFirstName = 'Aïcha';
  static const riderFullName = 'Aïcha Ngo Mbappe';
  static const riderEmail = 'aicha.ngo@email.cm';
  static const riderPhone = '671234567';
  static String riderPhoneDisplay = formatPhone(riderPhone);

  // Driver
  static const driverFirstName = 'Jean-Paul';
  static const driverFullName = 'Jean-Paul Mbarga';
  static const driverRating = '4.9';
  static const driverTrips = '1 248';
  static String vehicle(BuildContext c) =>
      tr(c, 'Toyota Corolla · White · LT 123 AB', 'Toyota Corolla · Blanc · LT 123 AB');
  static const vehicleShort = 'Toyota Corolla · LT 123 AB';

  // Places
  static const currentPlace = '12 Rue Joss, Akwa, Douala';
  static const pickupShort = '12 Rue Joss';
  static const pickupArea = 'Akwa';
  static const destination = 'Gare de Bessengué';
  static String destinationDetail(BuildContext c) =>
      tr(c, 'Bessengué, Douala · Main entrance', 'Bessengué, Douala · Entrée principale');
  static const destinationAddress = 'Bessengué, Douala';
  static const homeAddress = 'Avenue des Martyrs, Lakouanga';
  static const homeAddressFull = 'Avenue des Martyrs, Lakouanga, Bangui';
  static const workAddressFull = '12 Rue Joss, Akwa, Douala';
  static const recentPlace = 'Marché Central';
  static const recentArea = 'Centre-ville, Bangui';

  // Trip
  static const rideId = 'RD-1043';
  static const tripId = 'IYO-4826';
  static const pin = '4826';
  static const etaMinutes = '3';
  static const etaDistance = '0,8 km';
  static const tripDistance = '3,2 km';
  static const tripMinutes = '12';
  static const minutesLeft = '8';
  static const distanceLeft = '2,1 km';
  static const arriveTime = '09:56';
  static String fare = formatFcfa(2500);
  static String rideFare = formatFcfa(2300);
  static String bookingFee = formatFcfa(200);
  static String nearbyFrom = formatFcfa(600);
  static const paymentMethod = 'MTN MoMo •••• 45 67';
  static const tripDate = '13/10/2026 · 09:44–09:56 · 3,2 km';
  static List<String> tipAmounts = [formatFcfa(200), formatFcfa(500), formatFcfa(1000)];

  // Safety (emergency numbers come from app_config in production; 117 = police).
  static const emergencyNumber = '117';
  static const trustedContactName = 'Grâce Ngo Mbappe';
  static String trustedContactPhone = formatPhone('670001122');
  static const alertTime = '09:49';
}

class SampleChatLine {
  const SampleChatLine(
    this.en,
    this.fr, {
    required this.mine,
    required this.time,
    this.read = false,
  });

  final String en;
  final String fr;
  final bool mine;
  final String time;
  final bool read;
}

const driverChat = [
  SampleChatLine(
    "Hi Aïcha, I'm on my way. I'll stop at the main entrance on Rue Joss.",
    "Bonjour Aïcha, j'arrive. Je m'arrête devant l'entrée principale, rue Joss.",
    mine: false,
    time: '09:38',
  ),
  SampleChatLine(
    "Thanks! I'm outside the pharmacy, wearing a blue dress.",
    'Merci ! Je suis devant la pharmacie, en robe bleue.',
    mine: true,
    time: '09:39',
    read: true,
  ),
  SampleChatLine(
    'Perfect, see you shortly. My car is a white Corolla.',
    'Parfait, à tout de suite. Ma voiture est une Corolla blanche.',
    mine: false,
    time: '09:40',
  ),
];

const supportChat = [
  SampleChatLine(
    'Hi, where should I meet Jean-Paul at Douala airport for my rental?',
    "Bonjour, où dois-je retrouver Jean-Paul à l'aéroport de Douala pour ma location ?",
    mine: true,
    time: '09:30',
    read: true,
  ),
  SampleChatLine(
    'Hi Aïcha! Your RAV4 pickup is at the arrivals hall meeting point, on 17/10 at 10:00.',
    'Bonjour Aïcha ! Votre RAV4 vous attend au point de rencontre du hall des arrivées, le 17/10 à 10:00.',
    mine: false,
    time: '09:32',
  ),
  SampleChatLine(
    'Jean-Paul will message you before handover. Your flight AF 900 is linked to booking RN-2048.',
    'Jean-Paul vous écrira avant la remise. Votre vol AF 900 est lié à la réservation RN-2048.',
    mine: false,
    time: '09:32',
  ),
  SampleChatLine(
    "Great, thank you. I'll keep an eye on the booking.",
    'Parfait, merci. Je surveille la réservation.',
    mine: true,
    time: '09:33',
    read: true,
  ),
];
