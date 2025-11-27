import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_povider.g.dart';

@riverpod
types.User geminiUser(Ref ref) {
  final userGemini = types.User(
    id: 'user-abc',
    firstName: 'Perfect Teeth',
    //lastName: 'Quiroz',
    imageUrl: 'https://picsum.photos/id/179/200/200',
  );
  return userGemini;
}


@riverpod
types.User userPerson(Ref ref) {
  final user = types.User(
  id: 'user-123',
  firstName: 'Michael',
  lastName: 'Quiroz',
  imageUrl: 'https://picsum.photos/id/177/200/200',
);
  return user;
}
