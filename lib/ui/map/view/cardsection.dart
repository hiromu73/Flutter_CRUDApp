




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:memoplace/ui/map/view/set_googlemap.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search_type.dart';
import 'package:memoplace/ui/map/view_model/latitude.dart';
import 'package:memoplace/ui/map/view_model/longitude.dart';

class CardSection extends ConsumerWidget {
  final TextEditingController textController = TextEditingController();
  final PageController pageController;
  CardSection({Key? key, required this.pageController}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final GoogleMapController? mapController =
        ref.read(googleMapControllerProvider);
    final items = ref.watch(autoCompleteSearchTypeProvider);
    final latitude = ref.watch(latitudeProvider);
    final longitude = ref.watch(longitudeProvider);

// 画面が戻った時,cardがあればcardの1番目にする。
// 画面が戻った時にCardSectionの最初の要素にスクロールする
    // void scrollToFirstElement() {
    //   if (items.isNotEmpty) {
    //     pageController.animateToPage(0,
    //         duration: const Duration(milliseconds: 500), curve: Curves.ease);
    //   }
    // }

    List<String?> checkedMarkerNames =
        items.map((marker) => marker.name).toList();

    bool nameBool = checkedMarkerNames.length > 1;
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.withOpacity(0.6),
        ),
        height: 150,
        width: 380,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: PageView(
            onPageChanged: (int index) async {
              final selectedShop = items.elementAt(index);
              if (mapController != null) {
                final zoomLevel = await mapController.getZoomLevel();
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target:
                          LatLng(selectedShop.latitude, selectedShop.longitude),
                      zoom: zoomLevel,
                    ),
                  ),
                );
              }
            },
            controller: pageController,
            children: [
              ...(nameBool)
                  ? [
                      ...shopTiles(items, latitude, longitude),
                    ]
                  : [
                      const SizedBox.shrink(),
                    ]
            ]));
  }
}
