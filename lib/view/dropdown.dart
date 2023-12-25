import 'package:flutter/material.dart';
import 'package:flutter_crudapp/model.dart/map_doropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DropdownButtonMenu extends ConsumerWidget {
  const DropdownButtonMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String isSelectedValue =
        ref.watch(mapDoropDownProvider as ProviderListenable<String>);
    return DropdownButton(
      items: const [
        DropdownMenuItem(
          value: 'あ',
          child: Text('あ'),
        ),
        DropdownMenuItem(
          value: 'い',
          child: Text('い'),
        ),
        DropdownMenuItem(
          value: 'う',
          child: Text('う'),
        ),
        DropdownMenuItem(
          value: 'え',
          child: Text('え'),
        ),
        DropdownMenuItem(
          value: 'お',
          child: Text('お'),
        ),
      ],
      value: isSelectedValue,
      onChanged: (String? value) {
        ref.read(mapDoropDownProvider.notifier).changeList(value);
      },
    );
  }
}
