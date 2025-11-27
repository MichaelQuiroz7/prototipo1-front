// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_chat.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BasicChat)
const basicChatProvider = BasicChatProvider._();

final class BasicChatProvider
    extends $NotifierProvider<BasicChat, List<types.Message>> {
  const BasicChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'basicChatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$basicChatHash();

  @$internal
  @override
  BasicChat create() => BasicChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<types.Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<types.Message>>(value),
    );
  }
}

String _$basicChatHash() => r'9900e6327a2cad59a2f204df25e5ffd3a08ac0c9';

abstract class _$BasicChat extends $Notifier<List<types.Message>> {
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
