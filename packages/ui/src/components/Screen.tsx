import type { ReactNode } from 'react';
import { ScrollView, StyleSheet, View, type ViewStyle } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useTheme } from '../theme';

export type ScreenProps = {
  /** Header row, rendered above the scrollable content. */
  header?: ReactNode;
  /** Pinned bottom action area (e.g. the primary 52 px button). */
  footer?: ReactNode;
  scroll?: boolean;
  /** Set false for edge-to-edge content such as full-bleed maps. */
  padded?: boolean;
  contentStyle?: ViewStyle;
  children: ReactNode;
};

/**
 * Shared screen layout: status bar → header → scrollable content → pinned footer.
 * The bottom tab bar (root screens only) is provided by the navigator, not by Screen.
 */
export function Screen({
  header,
  footer,
  scroll = true,
  padded = true,
  contentStyle,
  children,
}: ScreenProps) {
  const theme = useTheme();
  const paddingHorizontal = padded ? theme.spacing.screenPadding : 0;
  const content = [{ paddingHorizontal }, contentStyle];

  return (
    <SafeAreaView
      style={[styles.root, { backgroundColor: theme.colors.white }]}
      edges={footer ? ['top', 'left', 'right', 'bottom'] : ['top', 'left', 'right']}
    >
      {header ? <View style={{ paddingHorizontal }}>{header}</View> : null}
      {scroll ? (
        <ScrollView
          style={styles.flex}
          contentContainerStyle={[styles.scrollContent, ...content]}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {children}
        </ScrollView>
      ) : (
        <View style={[styles.flex, ...content]}>{children}</View>
      )}
      {footer ? (
        <View
          style={[
            styles.footer,
            { paddingHorizontal, paddingTop: theme.spacing.md, paddingBottom: theme.spacing.lg },
          ]}
        >
          {footer}
        </View>
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  flex: { flex: 1 },
  scrollContent: { flexGrow: 1 },
  footer: { gap: 12 },
});
