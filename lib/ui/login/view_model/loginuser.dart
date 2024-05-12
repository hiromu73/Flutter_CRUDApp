import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loginuser.g.dart';

@riverpod
class LoginUser extends _$LoginUser {
  @override
  User? build() => null;

  Future<void> getLoginUser(User uid) async {
    state = uid;
  }
}
