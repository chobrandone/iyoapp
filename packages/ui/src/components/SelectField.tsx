import Check from 'lucide-react-native/icons/check';
import ChevronDown from 'lucide-react-native/icons/chevron-down';
import { useState } from 'react';
import { FlatList, Modal, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useTheme } from '../theme';
import { FormField } from './FormField';
import { Icon } from './Icon';
import { Text } from './Text';

export type SelectOption<T extends string = string> = {
  value: T;
  label: string;
  description?: string;
};

export type SelectFieldProps<T extends string> = {
  label?: string;
  helper?: string;
  error?: string;
  placeholder?: string;
  value: T | null;
  options: readonly SelectOption<T>[];
  onChange: (value: T) => void;
  /** Title of the picker sheet; defaults to the label. */
  sheetTitle?: string;
  disabled?: boolean;
  /** Spoken label for the sheet's backdrop. */
  closeLabel?: string;
};

/** Looks like a TextField with a chevron; opens a bottom sheet list of options. */
export function SelectField<T extends string>({
  label,
  helper,
  error,
  placeholder,
  value,
  options,
  onChange,
  sheetTitle,
  disabled = false,
  closeLabel = 'Close',
}: SelectFieldProps<T>) {
  const theme = useTheme();
  const [open, setOpen] = useState(false);
  const selected = options.find((o) => o.value === value);

  return (
    <FormField label={label} helper={helper} error={error}>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={label}
        accessibilityValue={{ text: selected?.label ?? placeholder ?? '' }}
        accessibilityState={{ disabled, expanded: open }}
        disabled={disabled}
        onPress={() => setOpen(true)}
        style={[
          styles.box,
          {
            minHeight: theme.sizes.inputMinHeight,
            borderRadius: theme.radii.md,
            borderColor: error
              ? theme.colors.danger
              : open
                ? theme.colors.accent
                : theme.colors.border,
            borderWidth: open || error ? 2 : 1,
            paddingHorizontal: open || error ? 12 : 13,
            backgroundColor: disabled ? theme.colors.surface : theme.colors.white,
          },
        ]}
      >
        <Text
          variant="input"
          color={selected ? 'ink' : 'muted'}
          style={styles.flex}
          numberOfLines={1}
        >
          {selected?.label ?? placeholder ?? ''}
        </Text>
        <Icon icon={ChevronDown} size={theme.sizes.iconSmall} />
      </Pressable>

      <Modal visible={open} transparent animationType="slide" onRequestClose={() => setOpen(false)}>
        <Pressable
          style={[styles.scrim, { backgroundColor: theme.colors.overlay }]}
          onPress={() => setOpen(false)}
          accessibilityRole="button"
          accessibilityLabel={closeLabel}
        />
        <SafeAreaView
          edges={['bottom']}
          style={[
            styles.sheet,
            {
              backgroundColor: theme.colors.white,
              borderTopLeftRadius: theme.radii.xl,
              borderTopRightRadius: theme.radii.xl,
            },
          ]}
        >
          <View style={[styles.grabber, { backgroundColor: theme.colors.border }]} />
          <Text
            variant="cardTitle"
            style={{ paddingHorizontal: theme.spacing.xxl, paddingVertical: theme.spacing.md }}
          >
            {sheetTitle ?? label}
          </Text>
          <FlatList
            data={options}
            keyExtractor={(o) => o.value}
            renderItem={({ item }) => {
              const isSelected = item.value === value;
              return (
                <Pressable
                  accessibilityRole="radio"
                  accessibilityState={{ selected: isSelected }}
                  onPress={() => {
                    onChange(item.value);
                    setOpen(false);
                  }}
                  style={({ pressed }) => [
                    styles.option,
                    {
                      paddingHorizontal: theme.spacing.xxl,
                      backgroundColor: pressed ? theme.colors.surface : theme.colors.white,
                    },
                  ]}
                >
                  <View style={styles.flex}>
                    <Text variant="rowTitle">{item.label}</Text>
                    {item.description ? (
                      <Text variant="caption" color="textSecondary">
                        {item.description}
                      </Text>
                    ) : null}
                  </View>
                  {isSelected ? <Icon icon={Check} size={theme.sizes.iconSmall} /> : null}
                </Pressable>
              );
            }}
          />
        </SafeAreaView>
      </Modal>
    </FormField>
  );
}

const styles = StyleSheet.create({
  box: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  flex: { flex: 1 },
  scrim: { flex: 1 },
  sheet: { maxHeight: '70%', paddingBottom: 8 },
  grabber: { alignSelf: 'center', width: 40, height: 4, borderRadius: 2, marginTop: 8 },
  option: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 52,
    paddingVertical: 10,
    gap: 12,
  },
});
