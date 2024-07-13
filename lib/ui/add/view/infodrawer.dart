import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/add/view/addpage.dart';
import 'package:url_launcher/url_launcher.dart';

// InfoPage
class InfoDrawer extends StatefulWidget {
  const InfoDrawer({super.key});

  @override
  State<InfoDrawer> createState() => _InfoDrawer();
}

class _InfoDrawer extends State<InfoDrawer> {
  User? user = FirebaseAuth.instance.currentUser;

  final Uri url = Uri.parse(
      'https://six-entrance-6bc.notion.site/MemoPlace-edb72efeb04e4f478402670048de001e');
  final Uri googleFromurl = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSfGWcIVLPMoAI-YhooVh5GwOLftMWj9RzHFUwjagB0zkEYlsA/viewform?usp=sf_link');
  final Uri kiyaku = Uri.parse(
      'https://six-entrance-6bc.notion.site/bee86251f2614d959c66e7ef2372b306');

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.orange,
          ),
          child: Center(child: Text("アプリについて")),
        ),
        ListTile(
            title: const Text('ログアウト'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋チャット画面を破棄
              if (context.mounted) {
                await context.push('/login');
              }
            }),
        ListTile(
            title: const Text('アカウント削除'),
            onTap: () async {
              await deleteUser(user!.uid);
              if (context.mounted) {
                await context.push('/login');
              }
            }),
        ListTile(
            title: const Text('プライバシーポリシー'),
            onTap: () async {
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not Launch $url';
              }
            }),
        ListTile(
            title: const Text('利用規約'),
            onTap: () async {
              if (await canLaunchUrl(kiyaku)) {
                await launchUrl(kiyaku);
              } else {
                throw 'Could not Launch $url';
              }
            }),
        ListTile(
            title: const Text('ライセンス'),
            onTap: () async {
              await context.push('/licensepage');
            }),
        ListTile(
            title: const Text('問い合わせ'),
            onTap: () async {
              if (await canLaunchUrl(googleFromurl)) {
                print("test");
                await launchUrl(googleFromurl);
              } else {
                print("test1");
                throw 'Could not Launch $googleFromurl';
              }
            }),
        const ListTile(
          title: Text('バージョン 1.0.2'),
        ),
      ],
    );
  }
}
