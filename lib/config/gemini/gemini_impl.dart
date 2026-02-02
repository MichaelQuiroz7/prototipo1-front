import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class GeminiImpl {
  final Dio _http = Dio(BaseOptions(baseUrl: dotenv.env['ENDPOINT_API'] ?? ''));

  // Simple non-streaming call
  Future<String> getResponse(String prompt) async {
    try {
      final body = jsonEncode({'prompt': prompt});
      final response = await _http.post('/basic-prompt', data: body);
      return response.data;
    } catch (e) {
      return 'Por favor Intentelo más tarde...';
    }
  }

  // Streaming call: returns a Stream<String> where each event is a decoded chunk
  Future<Stream<String>> getResponseStream(String prompt, {List<XFile> files = const []}) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('prompt', prompt));

      if(files.isNotEmpty){
        for (final file in files) {
          formData.files.add(
            MapEntry('files', await MultipartFile.fromFile(file.path, filename: file.name)),
          );
        }
      }

      final response = await _http.post(
        '/basic-prompt-stream',
        data: formData,
        options: Options(responseType: ResponseType.stream, headers: {'Accept': 'text/event-stream'}),
      );

      final respData = response.data;
      // ignore: avoid_print
      print('GeminiImpl.getResponseStream respData runtimeType=${respData.runtimeType}');

      // If Dio returned a ResponseBody (common), it exposes a byte stream
      if (respData is ResponseBody) {
        final byteStream = respData.stream; // Stream<Uint8List>
        final stringStream = byteStream.map((uint8list) {
          try {
            final s = utf8.decode(uint8list);
            // debug prefix
            // ignore: avoid_print
            print('GeminiImpl chunk(prefix): ${s.substring(0, s.length < 120 ? s.length : 120)}');
            return s;
          } catch (e) {
            // ignore: avoid_print
            print('GeminiImpl chunk decode error: $e');
            return uint8list.toString();
          }
        });
        return stringStream;
      }

      // If backend returned a Stream<String> directly
      if (respData is Stream<String>) return respData;

      // If backend returned a Stream<List<int>>
      if (respData is Stream<List<int>>) {
        return respData.map((bytes) => utf8.decode(bytes));
      }

      // Fallback
      return Stream.value(respData?.toString() ?? '');
    } catch (e, st) {
      // ignore: avoid_print
      print('GeminiImpl.getResponseStream error: $e\n$st');
      return Stream.value('Por favor Intentelo más tarde...');
    }
  }




  Future<Stream<String>> getChatStream(String prompt, String chatId, {List<XFile> files = const []}) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('prompt', prompt));
      formData.fields.add(MapEntry('chatId', chatId));

      if(files.isNotEmpty){
        for (final file in files) {
          formData.files.add(
            MapEntry('files', await MultipartFile.fromFile(file.path, filename: file.name)),
          );
        }
      }

      final response = await _http.post(
        '/chat-stream',
        data: formData,
        options: Options(responseType: ResponseType.stream, headers: {'Accept': 'text/event-stream'}),
      );

      final respData = response.data;
      // ignore: avoid_print
      print('GeminiImpl.getResponseStream respData runtimeType=${respData.runtimeType}');

      // If Dio returned a ResponseBody (common), it exposes a byte stream
      if (respData is ResponseBody) {
        final byteStream = respData.stream; // Stream<Uint8List>
        final stringStream = byteStream.map((uint8list) {
          try {
            final s = utf8.decode(uint8list);
            // debug prefix
            // ignore: avoid_print
            print('GeminiImpl chunk(prefix): ${s.substring(0, s.length < 120 ? s.length : 120)}');
            return s;
          } catch (e) {
            // ignore: avoid_print
            print('GeminiImpl chunk decode error: $e');
            return uint8list.toString();
          }
        });
        return stringStream;
      }

      // If backend returned a Stream<String> directly
      if (respData is Stream<String>) return respData;

      // If backend returned a Stream<List<int>>
      if (respData is Stream<List<int>>) {
        return respData.map((bytes) => utf8.decode(bytes));
      }

      // Fallback
      return Stream.value(respData?.toString() ?? '');
    } catch (e, st) {
      // ignore: avoid_print
      print('GeminiImpl.getResponseStream error: $e\n$st');
      return Stream.value('Por favor Intentelo más tarde...');
    }
  }



  Future<Stream<String>> chatPlanDental(String prompt, String chatId, {List<XFile> files = const []}) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('prompt', prompt));
      formData.fields.add(MapEntry('chatId', chatId));

      if(files.isNotEmpty){
        for (final file in files) {
          formData.files.add(
            MapEntry('files', await MultipartFile.fromFile(file.path, filename: file.name)),
          );
        }
      }

      final response = await _http.post(
        '/chat-plan-dental',
        data: formData,
        options: Options(responseType: ResponseType.stream, headers: {'Accept': 'text/event-stream'}),
      );

      final respData = response.data;
      // ignore: avoid_print
      print('GeminiImpl.getResponseStream respData runtimeType=${respData.runtimeType}');

      // If Dio returned a ResponseBody (common), it exposes a byte stream
      if (respData is ResponseBody) {
        final byteStream = respData.stream; // Stream<Uint8List>
        final stringStream = byteStream.map((uint8list) {
          try {
            final s = utf8.decode(uint8list);
            // debug prefix
            // ignore: avoid_print
            print('GeminiImpl chunk(prefix): ${s.substring(0, s.length < 120 ? s.length : 120)}');
            return s;
          } catch (e) {
            // ignore: avoid_print
            print('GeminiImpl chunk decode error: $e');
            return uint8list.toString();
          }
        });
        return stringStream;
      }

      // If backend returned a Stream<String> directly
      if (respData is Stream<String>) return respData;

      // If backend returned a Stream<List<int>>
      if (respData is Stream<List<int>>) {
        return respData.map((bytes) => utf8.decode(bytes));
      }

      // Fallback
      return Stream.value(respData?.toString() ?? '');
    } catch (e, st) {
      // ignore: avoid_print
      print('GeminiImpl.getResponseStream error: $e\n$st');
      return Stream.value('Por favor Intentelo más tarde...');
    }
  }

  Future<String> chatPlanDentalFull(
  String prompt,
  String chatId, {
  List<XFile> files = const [],
}) async {
  try {
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));
    formData.fields.add(MapEntry('chatId', chatId));

    if (files.isNotEmpty) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.name,
            ),
          ),
        );
      }
    }

    final response = await _http.post(
      '/chat-plan-dental',
      data: formData,
      options: Options(
        responseType: ResponseType.plain, 
        headers: {'Accept': 'text/plain'},
      ),
    );

    // El backend devuelve un texto completo (tabla entera)
    if (response.data != null) {
      return response.data.toString();
    }

    return "";
  } catch (e, st) {
    debugPrint('error en chatPlanDentalFull: $e\n$st');
    //print(" Error en chatPlanDentalFull: $e\n$st");
    return "";
  }
}




 Future<String> getLoadHistoryChat(String chatId) async {
    try {
      //final body = jsonEncode({'chatId': chatId});
      final response = await _http.get('/chat-history', queryParameters: {'chatId': chatId});
      return response.data;
    } catch (e) {
      return 'Por favor Intentelo más tarde...';
    }
  }


  

}
