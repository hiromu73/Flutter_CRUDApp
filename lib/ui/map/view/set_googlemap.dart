import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/map/view/cardsection.dart';
import 'package:memoplace/ui/map/view/showmodal.dart';
import 'package:memoplace/ui/map/view/showtextmoal.dart';
import 'package:memoplace/ui/map/view_model/googlemap_controller_notifier.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search_type.dart';
import 'package:memoplace/ui/map/view_model/latitude.dart';
import 'package:memoplace/ui/map/view_model/autocomplete_search.dart';
import 'package:memoplace/ui/map/view_model/longitude.dart';
import 'package:memoplace/ui/map/view_model/select_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final googleMapControllerProvider =
    StateNotifierProvider<GoogleMapControllerNotifier, GoogleMapController?>(
  (ref) => GoogleMapControllerNotifier(),
);

class SetGoogleMap extends ConsumerWidget {
  SetGoogleMap({Key? key}) : super(key: key);
  late GoogleMapController _mapController;
  static String get routeName => 'setgooglemap';
  static String get routeLocation => '/setgooglemap';

  final pageController = PageController(
    viewportFraction: 0.85,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPositionFuture = ref.watch(currentPositionProvider);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final selectItems = ref.watch(selectItemsProvider);
    final selectItemeMakers = ref.watch(autoCompleteSearchTypeProvider);
    // double currentLatitude = ref.watch(latitudeProvider);
    // double currentlongitudeProvider = ref.watch(longitudeProvider);

    // 各マーカー情報
    Set<Marker> markers = Set<Marker>.of(selectItemeMakers.map((item) => Marker(
          markerId: MarkerId(item.uid),
          position: LatLng(item.latitude, item.longitude),
          infoWindow: InfoWindow(title: item.name),
          icon: item.check
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarker,
          onTap: () async {
            await ref
                .read(autoCompleteSearchTypeProvider.notifier)
                .toggleMarkerCheck(item.uid);
            final index = selectItemeMakers.indexWhere((shop) => shop == item);
            pageController.jumpToPage(index);
          },
        )));

    //
    CameraPosition initialCameraPosition = selectItemeMakers.isNotEmpty
        ? CameraPosition(
            target: LatLng(selectItemeMakers.first.latitude,
                selectItemeMakers.first.longitude),
            zoom: 15.0,
          )
        : currentPositionFuture.maybeWhen(
            data: (data) => CameraPosition(
              target: LatLng(data.latitude, data.longitude),
              zoom: 15.0,
            ),
            orElse: () => const CameraPosition(
              target: LatLng(0, 0),
              zoom: 15.0,
            ),
          );

    List<String> idList = [];
    var uuid = const Uuid();
    var newId = uuid.v4();
    while (idList.any((id) => id == newId)) {
      newId = uuid.v4();
    }

    pageController.addListener(() {
      int pageIndex = pageController.page!.toInt();
      if (pageIndex >= 0 && pageIndex < selectItemeMakers.length) {
        final item = selectItemeMakers[pageIndex];
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(item.latitude, item.longitude),
              zoom: 15.0,
            ),
          ),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            currentPositionFuture.maybeWhen(
              data: (data) => GoogleMap(
                key: ValueKey(newId),
                onMapCreated: (GoogleMapController controller) {
                  print("mapが作られた");
                  print(initialCameraPosition);
                  _mapController = controller;
                  ref
                      .read(googleMapControllerProvider.notifier)
                      .setController(controller);
                  ref.read(latitudeProvider.notifier).state = data.latitude;
                  ref.read(longitudeProvider.notifier).state = data.longitude;
                },
                markers: markers,
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onTap: (LatLng latLang) {
                  // // map上に新たにマーカーを追加(初回時はチェックされている状態なので緑になる。)
                  // final latitude = latLang.latitude;
                  // final longitude = latLang.longitude;
                  // final uid =
                  //     '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
                  // ref
                  //     .read(autoCompleteSearchTypeProvider.notifier)
                  //     .onTapAddMarker(latitude, longitude, uid, true);
                },
                zoomGesturesEnabled: true,
              ),
              orElse: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            // 簡易選択
            Align(
              alignment: const Alignment(0.8, -0.85),
              child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 50,
                    height: 40,
                    child: const Icon(
                      Icons.dehaze_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onTap: () async {
                    await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withOpacity(0.6),
                        builder: (context) {
                          return const ShowModal();
                        });
                  }),
            ),
            //テキスト検索
            Align(
                alignment: const Alignment(-0.6, -0.85),
                child: SizedBox(
                  width: 200,
                  height: 40,
                  child: TextFormField(
                    autofocus: false,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    controller: TextEditingController(text: selectItems),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      iconColor: Colors.grey,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      hintText: AppLocalizations.of(context)!.location_search,
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onTap: () async {
                      await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          enableDrag: true,
                          barrierColor: Colors.black.withOpacity(0.6),
                          builder: (context) {
                            return ShowTextModal();
                          });
                    },
                  ),
                )),

            Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ClipOval(
                        child: Material(
                          color: Colors.blue[400],
                          child: InkWell(
                              splashColor: Colors.blue[400],
                              child: const SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(Icons.create, color: Colors.white),
                              ),
                              onTap: () => context.go('/addpage')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 現在位置ボタン
                      ClipOval(
                        child: Material(
                          color: Colors.blue[400],
                          child: InkWell(
                            splashColor: Colors.blue[400],
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child:
                                  Icon(Icons.my_location, color: Colors.white),
                            ),
                            onTap: () async {
                              print("現在位置 $currentPositionFuture");
                              await _mapController
                                  .animateCamera(CameraUpdate.newCameraPosition(
                                currentPositionFuture.maybeWhen(
                                  data: (data) => CameraPosition(
                                    target:
                                        LatLng(data.latitude, data.longitude),
                                    zoom: 15.0,
                                  ),
                                  orElse: () => const CameraPosition(
                                    target: LatLng(0, 0),
                                    zoom: 15.0,
                                  ),
                                ),
                              ));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                      alignment: const Alignment(0.0, 0.95),
                      child: CardSection(pageController: pageController)),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> setMarkder(WidgetRef ref) async {
  final checkedPlaces =
      await ref.read(autoCompleteSearchProvider.notifier).getCheckedPlaces();
  for (final place in checkedPlaces) {
    await ref.read(autoCompleteSearchTypeProvider.notifier).addMarker(
        place.name!, place.latitude, place.longitude, place.uid, place.check);
  }
}
