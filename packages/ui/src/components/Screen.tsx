import type { ReactNode } from 'react';
import { ScrollView, StyleSheet, View, type ViewStyle } from 'react-native';
import { SafeAreaView, type Edge } from 'react-native-safe-area-context';

import { useTheme } from '../theme';

export type ScreenProps = {
  /** Header row (AppHeader), rendered above the scrollable content. */
  header?: ReactNode;
  /** Page heading, scrolls with content. */
  heading?: ReactNode;
  /** Pinned bottom action area (e.g. the primary 52 px button). */
  footer?: ReactNode;
  scroll?: boolean;
  /** Set false for edge-to-edge content such as full-bleed maps. */
  padded?: boolean;
  /**
   * Set true on tab root screens: the tab bar already pads the bottom inset,
   * so the screen must not add it again.
   */
  inTabs?: boolean;
  contentStyle?: ViewStyle;
  children: ReactNode;
};

/**
 * Shared screen layout from Figma: status bar → header row → page heading →
 * content column (gap 14) → pinned actions (padding 8 / 16, gap 10).
 * The bottom tab bar (root screens only) comes from the navigator.
 */
export function Screen({
  header,
  heading,
  footer,
  scroll = true,
  padded = true,
  inTabs = false,
  contentStyle,
  children,
}: ScreenProps) {
  const theme = useTheme();
  const paddingHorizontal = padded ? theme.spacing.screenPadding : 0;
  const edges: Edge[] = inTabs ? ['top', 'left', 'right'] : ['top', 'left', 'right', 'bottom'];
  const column = [
    { paddingHorizontal, gap: theme.spacing.stack, paddingBottom: theme.spacing.lg },
    contentStyle,
  ];

  return (
    <SafeAreaView style={[styles.root, { backgroundColor: theme.colors.white }]} edges={edges}>
      {header ? (
        <View style={{ paddingHorizontal: theme.spacing.screenPadding }}>{header}</View>
      ) : null}
      {scroll ? (
        <ScrollView
          style={styles.flex}
          contentContainerStyle={[styles.scrollContent, ...column]}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {heading}
          {children}
        </ScrollView>
      ) : (
        <View style={[styles.flex, ...column]}>
          {heading}
          {children}
        </View>
      )}
      {footer ? (
        <View
          style={{
            paddingHorizontal: theme.spacing.screenPadding,
            paddingTop: theme.spacing.sm,
            paddingBottom: theme.spacing.lg,
            gap: 10,
          }}
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
});
