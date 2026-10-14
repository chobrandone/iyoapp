import { formatDateTime, formatFcfa, formatPhone, useTranslation } from '@iyodriver/core';
import { AppHeader, Button, PageHeading, Screen, Text, useTheme } from '@iyodriver/ui';
import { View } from 'react-native';

/** Phase 1 placeholder: proves shared UI, fonts, formatters and EN/FR i18n are wired up. */
export default function PlaceholderScreen() {
  const { t, i18n } = useTranslation();
  const theme = useTheme();
  const toggleLanguage = () => void i18n.changeLanguage(i18n.language === 'fr' ? 'en' : 'fr');

  return (
    <Screen
      header={<AppHeader badge={t('placeholder.badge')} flowLabel={t('placeholder.flowLabel')} />}
      footer={
        <>
          <Button label={t('placeholder.primary')} />
          <Button label={t('placeholder.secondary')} variant="secondary" onPress={toggleLanguage} />
        </>
      }
    >
      <PageHeading hero title={t('placeholder.title')} subtitle={t('placeholder.subtitle')} />
      <View style={{ gap: theme.spacing.xs }}>
        <Text>{t('placeholder.sampleFare', { fare: formatFcfa(2500) })}</Text>
        <Text>{t('placeholder.sampleTime', { time: formatDateTime(new Date()) })}</Text>
        <Text variant="caption" color="muted">
          {t('placeholder.samplePhone', { phone: formatPhone('671234567') })}
        </Text>
      </View>
    </Screen>
  );
}
