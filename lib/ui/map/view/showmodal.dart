// 簡易検索モーダル
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memoplace/constants/string.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search_type.dart';
import 'package:memoplace/ui/map/view_model/latitude.dart';
import 'package:memoplace/ui/map/view_model/select_item.dart';

class ShowModal extends ConsumerWidget {
  const ShowModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("簡易選択モーダル");
    final selectItem = ref.watch(selectItemsProvider);
    final currentPositionFuture = ref.watch(currentPositionProvider);
    print(currentPositionFuture);

    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      height: 250,
      child: Column(
        children: [
          currentPositionFuture.maybeWhen(
              data: (date) => Wrap(
                    runSpacing: 16,
                    spacing: 16,
                    children: categoryList.keys.map((item) {
                      return InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32)),
                        onTap: () async {
                          if (selectItem.contains(item)) {
                            await ref
                                .read(selectItemsProvider.notifier)
                                .remove(item);
                            if (ref.watch(selectItemsProvider).isNotEmpty) {
                              List<String> japaneseNames =
                                  ref.watch(selectItemsProvider).split(',');
                              List<String> englishNames = [];
                              for (String japaneseName in japaneseNames) {
                                String trimmedJapaneseName =
                                    japaneseName.trim();
                                if (categoryList
                                    .containsKey(trimmedJapaneseName)) {
                                  englishNames
                                      .add(categoryList[trimmedJapaneseName]!);
                                }
                              }
                              await ref
                                  .read(autoCompleteSearchTypeProvider.notifier)
                                  .autoCompleteSearchType(englishNames,
                                      date.latitude, date.longitude);
                            } else {
                              await ref
                                  .read(autoCompleteSearchTypeProvider.notifier)
                                  .noneAutoCompleteSearch();
                            }
                          } else {
                            await ref
                                .read(selectItemsProvider.notifier)
                                .add(item);
                            List<String> japaneseNames =
                                ref.watch(selectItemsProvider).split(',');
                            List<String> englishNames = [];
                            for (String japaneseName in japaneseNames) {
                              String trimmedJapaneseName = japaneseName.trim();
                              if (categoryList
                                  .containsKey(trimmedJapaneseName)) {
                                englishNames
                                    .add(categoryList[trimmedJapaneseName]!);
                              }
                            }
                            await ref
                                .read(autoCompleteSearchTypeProvider.notifier)
                                .autoCompleteSearchType(englishNames,
                                    date.latitude, date.longitude);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32)),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            color: selectItem.contains(item)
                                ? Colors.blue
                                : Colors.white,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                                color: selectItem.contains(item)
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              orElse: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
          Expanded(
              child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    ref.read(selectItemsProvider.notifier).none();
                    await ref
                        .read(autoCompleteSearchTypeProvider.notifier)
                        .noneAutoCompleteSearch();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
