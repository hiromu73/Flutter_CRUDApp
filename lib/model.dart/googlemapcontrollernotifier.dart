import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapControllerNotifier extends StateNotifier<GoogleMapController?> {
  GoogleMapControllerNotifier() : super(null);

  void setController(GoogleMapController controller) {
    state = controller;
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}
