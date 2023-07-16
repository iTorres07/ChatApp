import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ignore: constant_identifier_names
const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiZW1pdG9ycmVzNyIsImEiOiJjbGs0cHRhNWUwanRtM2Z0ankzeHpmYzNqIn0.zEXm5ezAjAChGtywsygrqg';

class LocationPage extends StatefulWidget {
  final String location;
  const LocationPage(this.location, {Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String location = widget.location;
    List<String> coordinates = location.split(',');
    double latitude = double.parse(coordinates[0]);
    double longitude = double.parse(coordinates[1]);
    LatLng myPosition = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapbox Flutter',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Mapbox API'),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                    height: 600,
                    child: FlutterMap(
                      options: MapOptions(
                        center: myPosition,
                        minZoom: 5,
                        maxZoom: 25,
                        zoom: 12,
                        enableScrollWheel: true,
                      ),
                      nonRotatedChildren: [
                        TileLayer(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                          additionalOptions: const {
                            'accessToken': MAPBOX_ACCESS_TOKEN,
                            'id': 'mapbox/streets-v12'
                          },
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: myPosition,
                              builder: (context) {
                                return const Icon(
                                  Icons.place,
                                  color: Colors.red,
                                  size: 40,
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
