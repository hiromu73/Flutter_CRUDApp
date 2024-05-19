import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'loginuser.g.dart';

@riverpod
class LoginUser extends _$LoginUser {
  @override
  String build() => "test";

  Future<void> setLoginUser(String uid) async {
    print(uid);
    state = uid;
  }
}
