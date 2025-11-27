// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_povider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geminiUser)
const geminiUserProvider = GeminiUserProvider._();

final class GeminiUserProvider
    extends $FunctionalProvider<types.User, types.User, types.User>
    with $Provider<types.User> {
  const GeminiUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiUserHash();

  @$internal
  @override
  $ProviderElement<types.User> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  types.User create(Ref ref) {
    return geminiUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(types.User value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<types.User>(value),
    );
  }
}

String _$geminiUserHash() => r'00804158ed2a7342a8c340dce4f2e727f8b35826';

@ProviderFor(userPerson)
const userPersonProvider = UserPersonProvider._();

final class UserPersonProvider
    extends $FunctionalProvider<types.User, types.User, types.User>
    with $Provider<types.User> {
  const UserPersonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPersonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPersonHash();

  @$internal
  @override
  $ProviderElement<types.User> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  types.User create(Ref ref) {
    return userPerson(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(types.User value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<types.User>(value),
    );
  }
}

String _$userPersonHash() => r'3a8fba683fa5be70d5a08fc3b5a568f101cbbf5f';
