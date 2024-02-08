import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/constants/string.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/autocomplete_search_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './todoapp.dart';
// constants
import 'package:flutter_crudapp/constants/routes.dart' as routes;

// メモ内容の状態管理
final memoProvider = StateProvider.autoDispose((ref) => "");

class TodoAddPage extends ConsumerWidget {
  const TodoAddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // チェックがtrueとなっている状態をする。
    final checkList = ref
        .watch(autoCompleteSearchTypeProvider)
        .where((marker) => marker.check == true)
        .toList();

    // チェックがtrueとなっているマーカーのnameを取得
    List<String?> checkedMarkerNames =
        checkList.map((marker) => marker.name).toList();

// チェックがtrueとなっているマーカーのlatitudeを取得
    List<double> checkedMarkerLatitudes =
        checkList.map((marker) => marker.latitude).toList();

// チェックがtrueとなっているマーカーのlongitudeを取得
    List<double> checkedMarkerLongitudes =
        checkList.map((marker) => marker.longitude).toList();
    // print(checkedMarkerNames);
    // print(checkedMarkerLatitudes);
    // print(checkedMarkerLongitudes);

    // メモ内容
    final textMemo = ref.watch(memoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          addPage,
          style: TextStyle(color: Colors.black54),
        ),
        backgroundColor: const MaterialColor(
          0xFFFFFFFF,
          <int, Color>{
            500: Color(0xFFFFFFFF),
          },
        ),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black54,
            ),
            onPressed: () {
              Navigator.of(context).pop(const ToDoApp());
            }),
      ),
      body: Center(
        child: Container(
          color: Colors.yellow[50],
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                maxLength: null,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
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
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: () => routes.mapSamplePage(context: context),
                child: const Text(positionSearch),
              ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    const Text("選択されている位置情報"),
                    ListView.builder(
                      itemCount: checkedMarkerNames.length,
                      itemBuilder: (context, index) {
                        return Text(checkedMarkerNames[index]!);
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: () async {
                  if (textMemo != "") {
                    final date = DateTime.now().toLocal().toIso8601String();
                    await FirebaseFirestore.instance
                        .collection('post')
                        .doc()
                        .set({
                      'text': textMemo,
                      //'latitude': mapPosition.toString().split(','),
                      //'longitude': mapPosition.toString().split(','),
                      'date': date,
                      'alert': true,
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(registration),
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
    );
  }
}

Widget markerNames(List<String?> name) {
  if (name.isNotEmpty) {
    print("isNotEmpty");
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
