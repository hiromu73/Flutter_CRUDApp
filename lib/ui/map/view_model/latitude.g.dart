// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latitude.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentPositionHash() => r'3abd741cd71d7bdcd474eb10908f5097d7e67b00';

/// See also [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider = AutoDisposeFutureProvider<Position>.internal(
  currentPosition,
  name: r'currentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentPositionRef = AutoDisposeFutureProviderRef<Position>;
String _$latitudeHash() => r'600adb2a11c199b8d6fa24689145e543dbf5d036';

/// See also [Latitude].
@ProviderFor(Latitude)
final latitudeProvider = AutoDisposeNotifierProvider<Latitude, double>.internal(
  Latitude.new,
  name: r'latitudeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$latitudeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Latitude = AutoDisposeNotifier<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
