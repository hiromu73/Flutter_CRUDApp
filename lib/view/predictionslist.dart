import 'package:flutter/material.dart';
import 'package:flutter_crudapp/model.dart/riverpod.dart/textpredictions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredictionsList extends ConsumerWidget {
  const PredictionsList(WidgetRef ref, {super.key});

  // 仮に候補の一覧を表示する Widget を作成
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            final prediction = ref.watch(textPredictionsProvider);
            return Column(
              children: [
                //Text(ref.watch(textPredictionsProvider)),
              ],
            );
          },
        ),
      ),
    );
  }
}
