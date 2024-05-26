import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/login/view_model/loginuser.dart';
import 'package:lottie/lottie.dart';

final userIdProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<bool>((ref) => true);

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

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
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
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
                        child: Container(
                            height: 40,
                            width: 250,
                            alignment: Alignment.center,
                            child: const Text(
                              "Login Page",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ))))),
            Lottie.network(
              'https://lottie.host/538e41a6-d2d6-4b94-a605-79720152ba00/zMGzw7cSL2.json',
              errorBuilder: (context, error, stackTrace) {
                return const Padding(
                  padding: EdgeInsets.all(0.0),
                  child: CircularProgressIndicator(),
                );
              },
            ),
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
                          height: 55,
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
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '値を入力してください';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.orange.shade100,
                              filled: true,
                              isDense: true,
                              hintText: "メールアドレス",
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
                          height: 55,
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
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              fillColor: Colors.orange.shade100,
                              filled: true,
                              isDense: true,
                              hintText: "パスワード",
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
                                      final uid = ref.watch(loginUserProvider);
                                      ref.read(userIdProvider.notifier).state =
                                          uid;
                                      if (context.mounted) {
                                        await context.push('/memolist');
                                      }
                                    } catch (e) {
                                      infoText.value =
                                          "ログインに失敗しました：${e.toString()}";
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
                                  'ログイン',
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
                                  } catch (e) {
                                    infoText.value =
                                        "ログインに失敗しました：${e.toString()}";
                                  }
                                },
                              ),
                            ))),
                      ],
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
