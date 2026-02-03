import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:prototipo1_app/config/gemini/gemini_impl.dart';
import 'package:prototipo1_app/presentation/client/providers/chat/is_gemini_writing.dart';
import 'package:prototipo1_app/presentation/client/providers/users/user_povider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'chat_with_context.g.dart';

final uuid = Uuid();

@Riverpod(keepAlive: true)
class ChatWithContext extends _$ChatWithContext {
  final gemini = GeminiImpl();

  late types.User geminiUser;
  late types.User chatUser;
  late String chatId;

  @override
List<types.Message> build() {
  geminiUser = ref.read(geminiUserProvider);
  chatUser = ref.read(userPersonProvider);
  chatId = uuid.v4();

  final welcomeMessage = types.TextMessage(
    author: geminiUser,
    id: uuid.v4(),
    text:
        "👋 Bienvenido a Perfect Teeth.\n\nEstoy aquí para ayudarte con tratamientos, citas o dudas sobre tu salud bucal.\n\n¿En qué puedo ayudarte hoy?",
  );

  return [welcomeMessage];
}


  Future<void> addMessage({
    required types.PartialText partialText,
    required types.User author,
    List<XFile> images = const [],
  }) async {
    if (images.isNotEmpty) {
      await _addTextMessageWithImages(
        partialText: partialText,
        author: author,
        images: images,
      );
      return;
    }

    _addTextMessage(partialText: partialText, author: author);
  }

  void _addTextMessage({
    required types.PartialText partialText,
    required types.User author,
  }) {
    _createTextMessage(author, partialText.text);
    _geminiTextResponseStream(partialText.text);
  }

  Future<void> _addTextMessageWithImages({
    required types.PartialText partialText,
    required types.User author,
    required List<XFile> images,
  }) async {
    // upload/create images sequentially to ensure size is available
    for (final image in images) {
      await _createImageMessage(author, image);
    }

    _createTextMessage(author, partialText.text);
    // Optionally trigger AI response here
    _geminiTextResponseStream(partialText.text, images: images);
  }

Future<String> generarPlanConOdontogramaFull(String prompt) async {
  try {
    final response = await gemini.chatPlanDentalFull(prompt, chatId);
    debugPrint('Respuesta chat with context Plan de Cuidado Full correctamente');
    //debugPrint('Respuesta chat with context Plan de Cuidado Full: $response');
    //print(  " Respuesta chat with context Plan de Cuidado Full: $response");
    return response.toString();
  } catch (e) {
    debugPrint('Error en generarPlanConOdontogramaFull: $e');
    //print(" Error en generarPlanConOdontogramaFull: $e");
    return "";
  }
}


  
  Future<void> _geminiTextResponseStream(
    String prompt, {
    List<XFile> images = const [],
  }) async {
    final geminiUser = ref.read(geminiUserProvider);

    _setGeminiWritingStatus(true);
    try {
      final stream = await gemini.getChatStream(prompt, chatId, files: images);
      final subscription = stream.listen(
        (chunk) {
          // Convert chunk to string and add as message
          final text = chunk.toString();
          _createTextMessage(geminiUser, text);
        },
        onError: (e, st) {
          // ignore: avoid_print
          print('BasicChat._geminiTextResponseStream error: $e\n$st');
        },
        onDone: () {
          _setGeminiWritingStatus(false);
        },
      );

      // Optionally await the stream completion if you want this method
      // to complete after the stream is done. Here we await onDone via
      // converting the subscription to a Future.
      await subscription.asFuture();
    } catch (e, st) {
      // ignore: avoid_print
      print('BasicChat._geminiTextResponseStream failed: $e\n$st');
      _setGeminiWritingStatus(false);
    } finally {
      _setGeminiWritingStatus(false);
    }
  }

  //Helpers Methods

  void newChat() {
    chatId = uuid.v4();
    state = [];
  }

  // Future<void> loadPreviusMessages( String chatId) async {
  //   final List<types.Message> historyChat = (await gemini.getLoadHistoryChat(chatId)) as List<types.Message>;
  //   state = [...historyChat, ...state];
  // }

  void _setGeminiWritingStatus(bool isWriting) {
    final geminiIsWriting = ref.read(isGeminiWritingProvider.notifier);
    isWriting
        ? geminiIsWriting.setIsWriting()
        : geminiIsWriting.setIsNotWriting();
  }

  void _createTextMessage(types.User author, String partialText) {
    final message = types.TextMessage(
      author: author,
      id: uuid.v4(),
      text: partialText,
    );

    state = [message, ...state];
  }

  Future<void> _createImageMessage(types.User author, XFile image) async {
    final message = types.ImageMessage(
      author: author,
      id: uuid.v4(),
      uri: image.path,
      name: image.name,
      size: await image.length(),
    );

    state = [message, ...state];
  }
}
