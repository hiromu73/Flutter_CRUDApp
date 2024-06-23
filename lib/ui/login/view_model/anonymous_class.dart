import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memoplace/ui/login/view_model/auth_provider.dart';

final anonymousClassProvider =
    StateProvider<AnonymousClass>((ref) => AnonymousClass(ref));

class AnonymousClass {
  Ref ref;
  AnonymousClass(this.ref);

  Future<void> signInAnonymous() async {
    await ref.read(firebaseAuthProvider).signInAnonymously();
  }
}
