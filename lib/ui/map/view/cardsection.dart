import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:memoplace/model/map/place.dart';
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
    List<String?> checkedMarkerNames =
        items.map((marker) => marker.name).toList();

    bool nameBool = checkedMarkerNames.isNotEmpty;
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey.withOpacity(0.6),
        ),
        height: 150,
        width: 450,
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: PageView(
            onPageChanged: (int index) async {
              final selectedShop = items.elementAt(index);
              print("pagecontroll");
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

// カード1枚1枚について
List<Widget> shopTiles(
    List<Place> items, double currentLatitude, double currentLongitude) {
  List<double> distances = items.map((place) {
    double distanceInMeters = Geolocator.distanceBetween(
      place.latitude,
      place.longitude,
      currentLatitude,
      currentLongitude,
    );
    return distanceInMeters;
  }).toList();

  final shopTiles = items.asMap().entries.map(
    (entry) {
      final index = entry.key;
      final place = entry.value;
      return Align(
        alignment: const Alignment(-3.5, 0.1),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            height: 150,
            width: 320,
            child: Center(
              child: Column(children: [
                ...(place.name == null)
                    ? [
                        const SizedBox.shrink(),
                      ]
                    : [
                        Text(place.name as String),
                        Text('現在地から${distances[index].ceilToDouble()} m')
                      ]
              ]),
            ),
          ),
        ),
      );
    },
  ).toList();
  return shopTiles;
}
