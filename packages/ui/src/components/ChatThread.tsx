import ArrowUp from 'lucide-react-native/icons/arrow-up';
import Plus from 'lucide-react-native/icons/plus';
import { memo, useState, type ReactElement } from 'react';
import { FlatList, StyleSheet, TextInput, View } from 'react-native';

import { fontFamily, useTheme } from '../theme';
import { IconButton } from './IconButton';
import { Text } from './Text';

export type ChatMessage = {
  id: string;
  body: string;
  /** True when sent by the current user (right-aligned, pale yellow). */
  mine: boolean;
  /** Pre-formatted meta line, e.g. "09:39 · Read". */
  meta?: string;
};

export const ChatBubble = memo(function ChatBubble({ message }: { message: ChatMessage }) {
  const theme = useTheme();
  return (
    <View style={[styles.row, { alignItems: message.mine ? 'flex-end' : 'flex-start', gap: 3 }]}>
      <View
        style={[
          styles.bubble,
          {
            backgroundColor: message.mine ? theme.colors.accentSoft : theme.colors.surface,
            borderRadius: theme.radii.lg,
          },
        ]}
      >
        <Text variant="body">{message.body}</Text>
      </View>
      {message.meta ? (
        <Text variant="micro" color="textSecondary">
          {message.meta}
        </Text>
      ) : null}
    </View>
  );
});

export type ChatThreadProps = {
  messages: readonly ChatMessage[];
  /** Rendered above the first message (identity card, privacy note). */
  header?: ReactElement;
  /** Rendered below the last message (quick replies). */
  footer?: ReactElement;
};

/** Message list (Figma 2025:342): 280 px-max bubbles, radius 16, padding 14, 9 px meta line. */
export function ChatThread({ messages, header, footer }: ChatThreadProps) {
  const theme = useTheme();
  return (
    <FlatList
      data={messages}
      keyExtractor={(m) => m.id}
      renderItem={({ item }) => <ChatBubble message={item} />}
      ListHeaderComponent={header}
      ListFooterComponent={footer}
      contentContainerStyle={{
        gap: theme.spacing.stack,
        paddingHorizontal: theme.spacing.screenPadding,
        paddingBottom: theme.spacing.md,
      }}
      keyboardShouldPersistTaps="handled"
      showsVerticalScrollIndicator={false}
    />
  );
}

export type ChatComposerProps = {
  placeholder: string;
  sendLabel: string;
  attachLabel?: string;
  onSend: (text: string) => void;
  onAttach?: () => void;
  disabled?: boolean;
};

/** Figma "Message composer": 52 px grey bar, plus icon, input, 32 px yellow send button. */
export function ChatComposer({
  placeholder,
  sendLabel,
  attachLabel,
  onSend,
  onAttach,
  disabled,
}: ChatComposerProps) {
  const theme = useTheme();
  const [text, setText] = useState('');
  const canSend = text.trim().length > 0 && !disabled;

  const send = () => {
    if (!canSend) return;
    onSend(text.trim());
    setText('');
  };

  return (
    <View
      style={[
        styles.composer,
        {
          minHeight: theme.sizes.buttonHeight,
          backgroundColor: theme.colors.surface,
          borderRadius: theme.radii.md,
          gap: theme.spacing.md,
        },
      ]}
    >
      {onAttach && attachLabel ? (
        <IconButton
          icon={Plus}
          tone="ghost"
          size={24}
          iconSize={18}
          accessibilityLabel={attachLabel}
          onPress={onAttach}
        />
      ) : null}
      <TextInput
        value={text}
        onChangeText={setText}
        placeholder={placeholder}
        placeholderTextColor={theme.colors.textSecondary}
        editable={!disabled}
        multiline
        maxLength={1000}
        accessibilityLabel={placeholder}
        selectionColor={theme.colors.accent}
        maxFontSizeMultiplier={1.6}
        style={[styles.input, { fontFamily: fontFamily.regular, color: theme.colors.ink }]}
      />
      <IconButton
        icon={ArrowUp}
        tone="accent"
        shape="rounded"
        size={32}
        iconSize={18}
        accessibilityLabel={sendLabel}
        onPress={send}
        disabled={!canSend}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  row: { alignSelf: 'stretch' },
  bubble: { padding: 14, maxWidth: '82%' },
  composer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 6,
  },
  input: { flex: 1, fontSize: 12, maxHeight: 96, paddingVertical: 8 },
});
