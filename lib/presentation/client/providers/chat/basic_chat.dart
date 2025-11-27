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
    return [];
  }

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
    // Fire-and-forget the AI response; it's handled internally and updates state
    _geminiTextResponse(partialText.text);

  }


  Future<void> _addTextMessageWithImages({
    required types.PartialText partialText,
    required types.User author,
    required List<XFile> images
  }) async {
    // upload/create images sequentially to ensure size is available
    for (final image in images) {
      await _createImageMessage(author, image);
    }

    _createTextMessage(author, partialText.text);
    // Optionally trigger AI response here
    _geminiTextResponseStream(
      partialText.text,
      images: images
      );

  }


  Future<void> _geminiTextResponse(String prompt) async {
    final geminiUser = ref.read(geminiUserProvider);

    _setGeminiWritingStatus(true);
    try {
      final messagePresentar = await gemini.getResponse(prompt);
      _createTextMessage(geminiUser, messagePresentar);
    } catch (e, st) {
      // ignore: avoid_print
      print('BasicChat._geminiTextResponse error: $e\n$st');
    } finally {
      _setGeminiWritingStatus(false);
    }
  }



  Future<void> _geminiTextResponseStream(String prompt, {List<XFile> images = const []}) async {
    final geminiUser = ref.read(geminiUserProvider);

    _setGeminiWritingStatus(true);
    try {
      final stream = await gemini.getResponseStream(prompt, files: images);
      final subscription = stream.listen((chunk) {
        // Convert chunk to string and add as message
        final text = chunk.toString();
        _createTextMessage(geminiUser, text);
      }, onError: (e, st) {
        // ignore: avoid_print
        print('BasicChat._geminiTextResponseStream error: $e\n$st');
      }, onDone: () {
       _setGeminiWritingStatus(false);
      });

      // Optionally await the stream completion if you want this method
      // to complete after the stream is done. Here we await onDone via
      // converting the subscription to a Future.
      await subscription.asFuture();
    } catch (e, st) {
      // ignore: avoid_print
      print('BasicChat._geminiTextResponseStream failed: $e\n$st');
      _setGeminiWritingStatus(false);
    }
    finally {
      _setGeminiWritingStatus(false);
    }
  }


  //Helpers
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



























































































































// import 'package:flutter/widgets.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:prototipo1_app/config/gemini/gemini_impl.dart';
// import 'package:prototipo1_app/presentation/providers/chat/is_gemini_writing.dart';
// import 'package:prototipo1_app/presentation/providers/users/user_povider.dart';
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

//   void addMessage({
//     required types.PartialText partialText,
//     required types.User author,
//   }) {

//     // TODO: Implementar la lógica para agregar un mensaje al chat
//     _addTextMessage(partialText: partialText, author: author);
  
//   }

//   void _addTextMessage({
//     required types.PartialText partialText,
//     required types.User author,
//   }) {
//     _createTextMessage(author, partialText.text);
//     _geminiTextResponse(partialText.text);

//   }

//   void _geminiTextResponse(String prompt) async {

//     final geminiUser = ref.read(geminiUserProvider);

//     _setGeminiWritingStatus(true);

//     final messagePresentar = await gemini.getResponse(prompt);

//     _setGeminiWritingStatus(false);

//     _createTextMessage(geminiUser, messagePresentar);

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


// }
