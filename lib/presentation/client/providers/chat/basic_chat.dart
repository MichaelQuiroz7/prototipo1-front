import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:prototipo1_app/config/gemini/gemini_impl.dart';
import 'package:prototipo1_app/presentation/client/providers/chat/is_gemini_writing.dart';
import 'package:prototipo1_app/presentation/client/providers/users/user_povider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'basic_chat.g.dart';

final uuid = Uuid();

@riverpod
class BasicChat extends _$BasicChat {

  final gemini = GeminiImpl();

  @override
  List<types.Message> build() {

    final geminiUser = ref.read(geminiUserProvider);

    // 👇 Mensaje de bienvenida automático
    final welcomeMessage = types.TextMessage(
      author: geminiUser,
      id: uuid.v4(),
      text: "👋 Bienvenido a Perfect Teeth.\n\nEstoy aquí para ayudarte con cualquier duda sobre tratamientos, citas, odontograma o salud bucal.\n\n¿En qué puedo ayudarte hoy?",
    );

    return [welcomeMessage];
  }

  // =====================================================
  // AGREGAR MENSAJE
  // =====================================================
  Future<void> addMessage({
    required types.PartialText partialText,
    required types.User author,
    List<XFile> images = const [],
  }) async {

    if(images.isNotEmpty){
      await _addTextMessageWithImages(
        partialText: partialText,
        author: author,
        images: images
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
    _geminiTextResponse(partialText.text);
  }

  Future<void> _addTextMessageWithImages({
    required types.PartialText partialText,
    required types.User author,
    required List<XFile> images
  }) async {

    for (final image in images) {
      await _createImageMessage(author, image);
    }

    _createTextMessage(author, partialText.text);

    _geminiTextResponseStream(
      partialText.text,
      images: images
    );
  }

  // =====================================================
  // GEMINI RESPUESTA NORMAL
  // =====================================================
  Future<void> _geminiTextResponse(String prompt) async {
    final geminiUser = ref.read(geminiUserProvider);

    _setGeminiWritingStatus(true);

    try {
      final messagePresentar = await gemini.getResponse(prompt);
      _createTextMessage(geminiUser, messagePresentar);
    } catch (e, st) {
      print('BasicChat._geminiTextResponse error: $e\n$st');
    } finally {
      _setGeminiWritingStatus(false);
    }
  }

  // =====================================================
  // GEMINI STREAM
  // =====================================================
  Future<void> _geminiTextResponseStream(
    String prompt,
    {List<XFile> images = const []}
  ) async {

    final geminiUser = ref.read(geminiUserProvider);

    _setGeminiWritingStatus(true);

    try {
      final stream = await gemini.getResponseStream(
        prompt,
        files: images
      );

      final subscription = stream.listen(
        (chunk) {
          final text = chunk.toString();
          _createTextMessage(geminiUser, text);
        },
        onError: (e, st) {
          print('BasicChat._geminiTextResponseStream error: $e\n$st');
        },
        onDone: () {
          _setGeminiWritingStatus(false);
        },
      );

      await subscription.asFuture();
    } catch (e, st) {
      print('BasicChat._geminiTextResponseStream failed: $e\n$st');
      _setGeminiWritingStatus(false);
    } finally {
      _setGeminiWritingStatus(false);
    }
  }

  // =====================================================
  // HELPERS
  // =====================================================
  void _setGeminiWritingStatus(bool isWriting) {
    final geminiIsWriting = ref.read(isGeminiWritingProvider.notifier);

    isWriting
      ? geminiIsWriting.setIsWriting()
      : geminiIsWriting.setIsNotWriting();
  }

  void _createTextMessage(types.User author, String text) {
    final message = types.TextMessage(
      author: author,
      id: uuid.v4(),
      text: text,
    );

    state = [message, ...state];
  }

  Future<void> _createImageMessage(
    types.User author,
    XFile image
  ) async {

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


// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:image_picker/image_picker.dart';
// import 'package:prototipo1_app/config/gemini/gemini_impl.dart';
// import 'package:prototipo1_app/presentation/client/providers/chat/is_gemini_writing.dart';
// import 'package:prototipo1_app/presentation/client/providers/users/user_povider.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:uuid/uuid.dart';

// part 'basic_chat.g.dart';

// final uuid = Uuid();

// @riverpod
// class BasicChat extends _$BasicChat {

//   final gemini = GeminiImpl();
  
//   @override
//   List<types.Message> build() {
//     return [];
//   }

//   Future<void> addMessage({
//     required types.PartialText partialText,
//     required types.User author,
//     List<XFile> images = const [],
//   }) async {

//     if(images.isNotEmpty){
//       await _addTextMessageWithImages(
//         partialText: partialText,
//         author: author,
//         images: images
        
//       );
//       return;
//     }

//     _addTextMessage(partialText: partialText, author: author);
  
//   }

//   void _addTextMessage({
//     required types.PartialText partialText,
//     required types.User author,
//   }) {
//     _createTextMessage(author, partialText.text);
//     // Fire-and-forget the AI response; it's handled internally and updates state
//     _geminiTextResponse(partialText.text);

//   }


//   Future<void> _addTextMessageWithImages({
//     required types.PartialText partialText,
//     required types.User author,
//     required List<XFile> images
//   }) async {
//     // upload/create images sequentially to ensure size is available
//     for (final image in images) {
//       await _createImageMessage(author, image);
//     }

//     _createTextMessage(author, partialText.text);
//     // Optionally trigger AI response here
//     _geminiTextResponseStream(
//       partialText.text,
//       images: images
//       );

//   }


//   Future<void> _geminiTextResponse(String prompt) async {
//     final geminiUser = ref.read(geminiUserProvider);

//     _setGeminiWritingStatus(true);
//     try {
//       final messagePresentar = await gemini.getResponse(prompt);
//       _createTextMessage(geminiUser, messagePresentar);
//     } catch (e, st) {
//       // ignore: avoid_print
//       print('BasicChat._geminiTextResponse error: $e\n$st');
//     } finally {
//       _setGeminiWritingStatus(false);
//     }
//   }



//   Future<void> _geminiTextResponseStream(String prompt, {List<XFile> images = const []}) async {
//     final geminiUser = ref.read(geminiUserProvider);

//     _setGeminiWritingStatus(true);
//     try {
//       final stream = await gemini.getResponseStream(prompt, files: images);
//       final subscription = stream.listen((chunk) {
//         // Convert chunk to string and add as message
//         final text = chunk.toString();
//         _createTextMessage(geminiUser, text);
//       }, onError: (e, st) {
//         // ignore: avoid_print
//         print('BasicChat._geminiTextResponseStream error: $e\n$st');
//       }, onDone: () {
//        _setGeminiWritingStatus(false);
//       });

//       // Optionally await the stream completion if you want this method
//       // to complete after the stream is done. Here we await onDone via
//       // converting the subscription to a Future.
//       await subscription.asFuture();
//     } catch (e, st) {
//       // ignore: avoid_print
//       print('BasicChat._geminiTextResponseStream failed: $e\n$st');
//       _setGeminiWritingStatus(false);
//     }
//     finally {
//       _setGeminiWritingStatus(false);
//     }
//   }


//   //Helpers
//   void _setGeminiWritingStatus(bool isWriting) {
//     final geminiIsWriting = ref.read(isGeminiWritingProvider.notifier);
//     isWriting
//     ? geminiIsWriting.setIsWriting()
//     : geminiIsWriting.setIsNotWriting();
//   }

//   void _createTextMessage(types.User author, String partialText) {
//     final message = types.TextMessage(
//       author: author, 
//       id: uuid.v4(), 
//       text: partialText,
//       );

//     state = [message, ...state];
//   }


//   Future<void> _createImageMessage(types.User author, XFile image) async {
//     final message = types.ImageMessage(
//       author: author,
//       id: uuid.v4(),
//       uri: image.path,
//       name: image.name,
//       size: await image.length(),
//     );

//     state = [message, ...state];
//   }


// }