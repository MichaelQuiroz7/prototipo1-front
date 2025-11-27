import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototipo1_app/config/theme/dark_mode_notifier.dart';
import 'package:prototipo1_app/presentation/client/providers/chat/chat_with_context.dart';
import 'package:prototipo1_app/presentation/client/providers/chat/is_gemini_writing.dart';
import 'package:prototipo1_app/presentation/client/providers/users/user_povider.dart';
import 'package:prototipo1_app/presentation/client/widgets/Chat/custom_bottom_input.dart';

final messages = <types.Message>[];

class ChatContextScreen extends ConsumerWidget {

  const ChatContextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGemini = ref.watch(geminiUserProvider);
    final user = ref.watch(userPersonProvider);
    final isGeminiWriting = ref.watch(isGeminiWritingProvider);
    final messages = ref.watch(chatWithContextProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ValueListenableBuilder<bool>(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, _) {
          return Chat(
            messages: messages,
            onSendPressed: (_) { },
            user: user,
            theme: isDarkMode ? DarkChatTheme() : DefaultChatTheme(),
            showUserNames: true,
            showUserAvatars: true,

            //Custom input area
            customBottomWidget: CustomBottomInput(
              onSend: (partialText, {images = const []}) {
                final chatNotifier = ref.read(chatWithContextProvider.notifier);
                chatNotifier.addMessage(partialText: partialText, author: user, images: images);
              },
            ),

            typingIndicatorOptions: TypingIndicatorOptions(
              typingUsers: isGeminiWriting ? [userGemini] : [],
              customTypingWidget: const Center(child: Text('escribiendo...')),
            ),
          );
        },
      ),
    );
  }
}
