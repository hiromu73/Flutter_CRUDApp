import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/constants/string.dart';
import 'package:memoplace/ui/login/view_model/loginuser.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search_type.dart';
import 'package:permission_handler/permission_handler.dart';

// メモ内容の状態管理
final memoProvider = StateProvider.autoDispose((ref) => "");

class AddPage extends HookConsumerWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController editController = useTextEditingController();
    final checkList = ref
        .watch(autoCompleteSearchTypeProvider)
        .where((marker) => marker.check == true)
        .toList();

    List<String?> checkedMarkerNames =
        checkList.map((marker) => marker.name).toList();

    List<double> checkedMarkerLatitudes =
        checkList.map((marker) => marker.latitude).toList();

    List<double> checkedMarkerLongitudes =
        checkList.map((marker) => marker.longitude).toList();

    final textMemo = ref.watch(memoProvider);
    final userId = ref.watch(loginUserProvider);
    final FocusNode focusNode = useFocusNode();
    bool shouldDisplayContainer = checkedMarkerNames.isNotEmpty &&
        checkedMarkerNames.any((name) => name != null && name.isNotEmpty);
    Color baseColor = Colors.orange.shade100;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            addPage,
            style: TextStyle(color: Colors.black54),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black54,
              ),
              onPressed: () {
                context.push('/memolist');
              }),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height / 12),
                Container(
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
                    focusNode: focusNode,
                    controller: editController,
                    maxLength: null,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      fillColor: Colors.orange.shade100,
                      filled: true,
                      isDense: true,
                      hintText: memo,
                      hintStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w100),
                      prefixIcon: const Icon(Icons.create),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textAlign: TextAlign.left,
                    onChanged: (String value) async {
                      ref.read(memoProvider.notifier).state = value;
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 16),
                Container(
                  height: 50,
                  width: 100,
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
                  child: TextButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text(
                        positionSearch,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final permission = await Geolocator.checkPermission();
                        if ((permission == LocationPermission.always ||
                                permission == LocationPermission.whileInUse) &&
                            context.mounted) {
                          context.push('/setgooglemap');
                        } else {
                          if (context.mounted) {
                            return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: const Text(
                                        "デバイスの位置情報が許可されていません。\n位置情報を許可することでマップを表示でき、プッシュ通知も行えます。"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          openAppSettings();
                                        },
                                        child: const Text("設定"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text(ok),
                                      ),
                                    ],
                                  );
                                });
                          }
                        }
                      }),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 33),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "選択されている位置情報",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 33),
                      shouldDisplayContainer == true
                          ? Container(
                              padding: const EdgeInsets.all(10.0),
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
                              child: ListView.builder(
                                itemCount: checkedMarkerNames.length,
                                itemBuilder: (context, index) {
                                  // 削除ボタンを作っていく。
                                  return Text("・${checkedMarkerNames[index]!}");
                                },
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height / 66),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: const Text(
                            registration,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            if (textMemo != "") {
                              final date =
                                  DateTime.now().toLocal().toIso8601String();
                              await FirebaseFirestore.instance
                                  .collection('post')
                                  .doc(userId)
                                  .collection('documents')
                                  .add({
                                'text': textMemo,
                                'checkName': checkedMarkerNames.isNotEmpty
                                    ? checkedMarkerNames
                                    : null,
                                'latitude': checkedMarkerLatitudes.isNotEmpty
                                    ? checkedMarkerLatitudes
                                    : null,
                                'longitude': checkedMarkerLongitudes.isNotEmpty
                                    ? checkedMarkerLongitudes
                                    : null,
                                'date': date,
                                'alert': true,
                              });
                              if (context.mounted) {
                                context.go('/memolist');
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: const Text(memo),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(ok),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          }),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 10),
                    Container(
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
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: () async {
                          editController.clear();
                          ref
                              .read(autoCompleteSearchTypeProvider.notifier)
                              .noneAutoCompleteSearch();
                        },
                        child: const Text(
                          clear,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),

        // 今後つけたい機能？写真？カメラ？
        // floatingActionButton: Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     FloatingActionButton(
        //         heroTag: "hero2",
        //         child: const Icon(Icons.photo),
        //         onPressed: () => {}), //写真を選択して保存ができる。
        //     const SizedBox(
        //       width: 10,
        //     ),
        //     FloatingActionButton(
        //         heroTag: "hero3",
        //         child: const Icon(Icons.camera_alt_outlined), //カメラから撮って保存ができる。
        //         onPressed: () => {}),
        //   ],
        // ),
      ),
    );
  }
}

Widget markerNames(List<String?> name) {
  if (name.isNotEmpty) {
    return Column(children: [
      const Text("選択されている位置情報"),
      checkNames(name),
    ]);
  } else {
    return Container();
  }
}

Widget checkNames(List<String?> name) {
  return ListView.builder(
    itemCount: name.length,
    itemBuilder: (context, index) {
      return Text(name[index]!);
    },
  );
}
