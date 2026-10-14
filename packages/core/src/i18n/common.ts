/** Strings shared by both apps (namespace `common`). App-specific strings live in each app. */
export const commonEn = {
  actions: {
    continue: 'Continue',
    cancel: 'Cancel',
    back: 'Back',
    retry: 'Try again',
    save: 'Save',
    done: 'Done',
  },
  validation: {
    phoneInvalid: 'Enter a valid Cameroonian mobile number (9 digits starting with 6).',
    otpInvalid: 'Enter the 6-digit code.',
    pinInvalid: 'Enter the 4-digit PIN.',
    required: 'This field is required.',
  },
  errors: {
    generic: 'Something went wrong. Please try again.',
    offline: "You're offline. We'll retry when you're back online.",
  },
  language: {
    en: 'English',
    fr: 'Français',
  },
};

export type CommonStrings = typeof commonEn;

export const commonFr: CommonStrings = {
  actions: {
    continue: 'Continuer',
    cancel: 'Annuler',
    back: 'Retour',
    retry: 'Réessayer',
    save: 'Enregistrer',
    done: 'Terminé',
  },
  validation: {
    phoneInvalid: 'Saisissez un numéro mobile camerounais valide (9 chiffres commençant par 6).',
    otpInvalid: 'Saisissez le code à 6 chiffres.',
    pinInvalid: 'Saisissez le code PIN à 4 chiffres.',
    required: 'Ce champ est obligatoire.',
  },
  errors: {
    generic: "Une erreur s'est produite. Veuillez réessayer.",
    offline: 'Vous êtes hors ligne. Nous réessaierons dès le retour de la connexion.',
  },
  language: {
    en: 'English',
    fr: 'Français',
  },
};
