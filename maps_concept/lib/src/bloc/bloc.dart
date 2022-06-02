import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProviderMaps with ChangeNotifier {
  LatLng? _gpsactual;
  LatLng _initialposition = const LatLng(-12.122711, -77.027475);
  bool activegps = true;
  TextEditingController locationController = TextEditingController();
  GoogleMapController? _mapController;

  LatLng get gpsPosition => _gpsactual!;

  LatLng get initialPos => _initialposition;
  final Set<Marker> _markers = Set();

  Set<Marker> get markers => _markers;

  GoogleMapController get mapController => _mapController!;
  String address = "";

  void getMoveCamera() async {
    GetAddressFromLatLong(
        _initialposition.latitude, _initialposition.longitude);
    locationController.text = address;
  }

  void getUserLocation() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      activegps = false;
    } else {
      activegps = true;
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _initialposition = LatLng(position.latitude, position.longitude);
      GetAddressFromLatLong(position.latitude, position.longitude);
      locationController.text = address;
      print("Address in getUserLocation ${locationController.text} $address");
      _addMarker(_initialposition, address);
      _mapController!.moveCamera(CameraUpdate.newLatLng(_initialposition));
      notifyListeners();
    }
  }

  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) async {
    _initialposition = position.target;
    notifyListeners();
  }

  Future<void> GetAddressFromLatLong(latitude, longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  }
}
