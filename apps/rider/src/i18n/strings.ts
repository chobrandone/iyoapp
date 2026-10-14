/** Rider-app strings (i18next namespace `app`). Shared strings live in @iyodriver/core. */
export const en = {
  placeholder: {
    flowLabel: 'Rider · 00',
    title: 'Your city. Your way.',
    subtitle: 'Rides and car rentals across Douala and Yaoundé.',
    sampleFare: 'Sample fare: {{fare}}',
    sampleTime: 'Local time (Douala): {{time}}',
    samplePhone: 'Support line: {{phone}}',
    primary: 'Get started',
    secondary: 'Switch to Français',
  },
};

export const fr: typeof en = {
  placeholder: {
    flowLabel: 'Passager · 00',
    title: 'Votre ville. À votre façon.',
    subtitle: 'Courses et location de voitures à Douala et Yaoundé.',
    sampleFare: 'Exemple de tarif : {{fare}}',
    sampleTime: 'Heure locale (Douala) : {{time}}',
    samplePhone: "Ligne d'assistance : {{phone}}",
    primary: 'Commencer',
    secondary: 'Switch to English',
  },
};
