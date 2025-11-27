// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_with_context.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatWithContext)
const chatWithContextProvider = ChatWithContextProvider._();

final class ChatWithContextProvider
    extends $NotifierProvider<ChatWithContext, List<types.Message>> {
  const ChatWithContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatWithContextProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatWithContextHash();

  @$internal
  @override
  ChatWithContext create() => ChatWithContext();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<types.Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<types.Message>>(value),
    );
  }
}

String _$chatWithContextHash() => r'26f49025d21a49efdcadf7c296dbe74b60d1b295';

abstract class _$ChatWithContext extends $Notifier<List<types.Message>> {
  List<types.Message> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<types.Message>, List<types.Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<types.Message>, List<types.Message>>,
              List<types.Message>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
