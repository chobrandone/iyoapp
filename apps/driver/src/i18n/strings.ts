/** Driver-app strings (i18next namespace `app`). Shared strings live in @iyodriver/core. */
export const en = {
  placeholder: {
    badge: 'Driver',
    flowLabel: 'Driver · 00',
    title: 'Drive with iyodriver. Earn on your schedule.',
    subtitle: 'Accept rides and rental handovers in Douala and Yaoundé.',
    sampleFare: "Today's earnings: {{fare}}",
    sampleTime: 'Local time (Douala): {{time}}',
    samplePhone: 'Payout number: {{phone}}',
    primary: 'Get started',
    secondary: 'Switch to Français',
  },
};

export const fr: typeof en = {
  placeholder: {
    badge: 'Chauffeur',
    flowLabel: 'Chauffeur · 00',
    title: 'Conduisez avec iyodriver. Gagnez à votre rythme.',
    subtitle: 'Acceptez des courses et des remises de véhicules à Douala et Yaoundé.',
    sampleFare: 'Gains du jour : {{fare}}',
    sampleTime: 'Heure locale (Douala) : {{time}}',
    samplePhone: 'Numéro de paiement : {{phone}}',
    primary: 'Commencer',
    secondary: 'Switch to English',
  },
};
