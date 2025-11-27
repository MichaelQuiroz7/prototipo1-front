import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototipo1_app/config/theme/dark_mode_notifier.dart';
import 'package:prototipo1_app/presentation/client/providers/chat/basic_chat.dart';
import 'package:prototipo1_app/presentation/client/providers/chat/is_gemini_writing.dart';
import 'package:prototipo1_app/presentation/client/providers/users/user_povider.dart';
import 'package:prototipo1_app/presentation/client/widgets/Chat/custom_bottom_input.dart';

final messages = <types.Message>[
  // types.TextMessage(
  //   author: user, createdAt: DateTime.now().millisecondsSinceEpoch,
  //   id: Uuid().v4(), text: 'Hola, ¿en qué puedo ayudarte?',
  // ),
  // types.TextMessage(
  //   author: userGemini, createdAt: DateTime.now().millisecondsSinceEpoch,
  //   id: Uuid().v4(), text: 'Pasa la tarea que quieres realizar',
  // ),
];

class BasicPromptScreen extends ConsumerWidget {
  const BasicPromptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGemini = ref.watch(geminiUserProvider);
    final user = ref.watch(userPersonProvider);
    final isGeminiWriting = ref.watch(isGeminiWritingProvider);
    final messages = ref.watch(basicChatProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Basico')),
      body: ValueListenableBuilder<bool>(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, _) {
          return Chat(
            messages: messages,
            onSendPressed: (types.PartialText partialText) {
              // final chatNotifier = ref.read(basicChatProvider.notifier);
              // chatNotifier.addMessage(partialText: partialText, author: user);
            },
            user: user,
            theme: isDarkMode ? DarkChatTheme() : DefaultChatTheme(),
            showUserNames: true,
            showUserAvatars: true,

            //Custom input area
            customBottomWidget: CustomBottomInput(
              onSend: (partialText, {images = const []}) {
                final chatNotifier = ref.read(basicChatProvider.notifier);
                chatNotifier.addMessage(partialText: partialText, author: user, images: images);
              },
            ),

            // //Selección de adjuntables
            // onAttachmentPressed: () async {
            //   // Implementar la lógica para adjuntar archivos
            //   ImagePicker picker = ImagePicker();
            //   final List<XFile> images = await picker.pickMultiImage(limit: 3);
            //   if (images.isEmpty) return;
            // },
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
