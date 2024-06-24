import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/login/view_model/anonymous_class.dart';
import 'package:memoplace/ui/login/view_model/loginuser.dart';

final userIdProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<bool>((ref) => true);

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});
  static String get routeName => 'loginpage';
  static String get routeLocation => '/$routeName';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    final FocusNode emailFocusNode = useFocusNode();
    final FocusNode passwordFocusNode = useFocusNode();
    final email = useState<String>("");
    final password = useState<String>("");
    final infoText = useState<String>("");
    useFocusNode();
    final obscureText = useState(true);
    Color baseColor = Colors.orange.shade100;
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final authState = useState<User?>(FirebaseAuth.instance.currentUser);
    useEffect(() {
      final listener = FirebaseAuth.instance.authStateChanges().listen((user) {
        authState.value = user;
      });
      return listener.cancel;
    }, []);

    print(h);
    print(w);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Container(
                  color: baseColor,
                  child: Center(
                      child: Container(
                          height: 60,
                          width: 300,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(-3, -3),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Login Page",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          )))),
              const SizedBox(height: 100),
              Form(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                          color: baseColor,
                          child: Center(
                              child: Container(
                            height: 60,
                            width: 350,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(-3, -3),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              focusNode: emailFocusNode,
                              controller: emailController,
                              maxLength: null,
                              maxLines: 1,
                              keyboardType: TextInputType.multiline,
                              autofillHints: const [AutofillHints.email],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '値を入力してください';
                                } else if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'メールアドレスの形式が正しくありません';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.orange.shade100,
                                filled: true,
                                isDense: true,
                                hintText: "e-mail",
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                  horizontal: 15,
                                ),
                                hintStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w100),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              textAlign: TextAlign.start,
                              onChanged: (String value) async {
                                email.value = value;
                              },
                            ),
                          ))),
                      const SizedBox(height: 30),
                      Container(
                          color: baseColor,
                          child: Center(
                              child: Container(
                            height: 60,
                            width: 350,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(-3, -3),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              focusNode: passwordFocusNode,
                              controller: passwordController,
                              obscureText: obscureText.value,
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                fillColor: Colors.orange.shade100,
                                filled: true,
                                isDense: true,
                                hintText: "password",
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                  horizontal: 15,
                                ),
                                hintStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w100),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(obscureText.value
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    obscureText.value = !obscureText.value;
                                  },
                                ),
                              ),
                              textAlign: TextAlign.left,
                              onChanged: (String value) async {
                                password.value = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '入力欄が空欄です';
                                } else if (value.length < 6) {
                                  return '6文字以上で入力してください';
                                }
                                return null;
                              },
                            ),
                          ))),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Text(infoText.value),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              color: baseColor,
                              child: Center(
                                  child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(3, 3),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(-3, -3),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.orange.shade100,
                                    ),
                                    child: const Text(
                                      '登録',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        final FirebaseAuth auth =
                                            FirebaseAuth.instance;
                                        final result = await auth
                                            .createUserWithEmailAndPassword(
                                          email: email.value,
                                          password: password.value,
                                        );
                                        ref
                                            .read(loginUserProvider.notifier)
                                            .setLoginUser(result.user!.uid);
                                        final uid =
                                            ref.watch(loginUserProvider);
                                        ref
                                            .read(userIdProvider.notifier)
                                            .state = uid;
                                        if (context.mounted) {
                                          await context.push('/');
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'weak-password') {
                                          infoText.value =
                                              "passwordは6桁以上にして下さい";
                                        } else if (e.code ==
                                            'email-already-in-use') {
                                          infoText.value =
                                              'このメールアドレスは既に登録されています。';
                                        } else {
                                          infoText.value =
                                              'e-mailまたはpasswordが誤っています';
                                        }
                                      } catch (e) {
                                        infoText.value = 'アカウント登録できませんでした。';
                                      }
                                    }),
                              ))),
                          Container(
                              color: baseColor,
                              child: Center(
                                  child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(3, 3),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(-3, -3),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.orange.shade100,
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final FirebaseAuth auth =
                                          FirebaseAuth.instance;
                                      final result =
                                          await auth.signInWithEmailAndPassword(
                                        email: email.value,
                                        password: password.value,
                                      );
                                      await ref
                                          .read(loginUserProvider.notifier)
                                          .setLoginUser(result.user!.uid);
                                      final uid = ref.watch(loginUserProvider);
                                      ref.read(userIdProvider.notifier).state =
                                          uid;
                                      if (context.mounted) {
                                        await context.push('/memolist');
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'invalid-email') {
                                        infoText.value = 'e-mailが誤っています';
                                      } else if (e.code == 'wrong-password') {
                                        infoText.value = 'passwordが誤っています';
                                      } else if (e.code == 'user-not-found') {
                                        infoText.value = 'ユーザーが存在しません';
                                      }
                                    } catch (e) {
                                      infoText.value = 'ログインできませんでした';
                                    }
                                  },
                                ),
                              ))),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                          color: baseColor,
                          child: Center(
                              child: Container(
                            height: 40,
                            width: 140,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(3, 3),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(-3, -3),
                                ),
                              ],
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.orange.shade100,
                              ),
                              onPressed: () async {
                                await ref
                                    .read(anonymousClassProvider.notifier)
                                    .state
                                    .signInAnonymous();
                                User? user = FirebaseAuth.instance.currentUser;
                                await ref
                                    .read(loginUserProvider.notifier)
                                    .setLoginUser(user!.uid);
                                final uid = ref.watch(loginUserProvider);
                                ref.read(userIdProvider.notifier).state = uid;
                                if (context.mounted) {
                                  await context.push('/memolist');
                                }
                              },
                              child: const Text(
                                "登録せずに利用",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
