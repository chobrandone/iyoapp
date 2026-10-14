import { Pressable, StyleSheet, View, type ViewStyle } from 'react-native';
import ChevronLeft from 'lucide-react-native/icons/chevron-left';

import { useTheme } from '../theme';
import { Icon } from './Icon';
import { Text } from './Text';

export type PageHeadingProps = {
  title: string;
  subtitle?: string;
  /** Use the larger hero size (welcome / onboarding screens). */
  hero?: boolean;
  /** Shows a back chevron before the title (e.g. "‹ Chat with Daniel"). */
  onBack?: () => void;
  backLabel?: string;
  style?: ViewStyle;
};

/** Figma "Page heading": 24 px SemiBold title, 12 px secondary subtitle, padding 16 / 14. */
export function PageHeading({
  title,
  subtitle,
  hero = false,
  onBack,
  backLabel = 'Back',
  style,
}: PageHeadingProps) {
  const theme = useTheme();
  return (
    <View style={[{ gap: 3, paddingTop: theme.spacing.lg, paddingBottom: 14 }, style]}>
      <View style={styles.titleRow}>
        {onBack ? (
          <Pressable
            onPress={onBack}
            accessibilityRole="button"
            accessibilityLabel={backLabel}
            hitSlop={12}
            style={{ marginLeft: -6, marginRight: theme.spacing.xs }}
          >
            <Icon icon={ChevronLeft} size={26} strokeWidth={2.25} />
          </Pressable>
        ) : null}
        <Text variant={hero ? 'hero' : 'title'} accessibilityRole="header" style={styles.flex}>
          {title}
        </Text>
      </View>
      {subtitle ? (
        <Text variant="body" color="textSecondary">
          {subtitle}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  titleRow: { flexDirection: 'row', alignItems: 'center' },
  flex: { flex: 1 },
});
