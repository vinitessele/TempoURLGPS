// ignore_for_file: prefer_typing_uninitialized_variables, duplicate_ignore, import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MaterialApp(
      title: "Weather App",
      home: Home(),
    ));

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var latitude;
  var longitude;
  var currentAddress;
  bool check = false;
  // ignore: prefer_typing_uninitialized_variables
  var temp;
  // ignore: prefer_typing_uninitialized_variables
  var description;
  // ignore: prefer_typing_uninitialized_variables
  var currently;
  // ignore: prefer_typing_uninitialized_variables
  var humidity;
  // ignore: prefer_typing_uninitialized_variables
  var windspeed;
  // ignore: prefer_typing_uninitialized_variables
  String? city;
  var sunrise;
  var sunset;

  void _Checkper() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude;
    longitude = position.longitude;
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    setState(() {
      check = true;
      currentAddress = "${place.locality},${place.postalCode},${place.country}";
      print(position.latitude);
    });
  }

  Future getWeather() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=e42b9722d62b644a3b13549d36292666'));
    var results = jsonDecode(response.body);
    setState(() {
      temp = results['main']['temp'].toString();
      description = results['weather'][0]['description'].toString();
      currently = results['weather'][0]['main'].toString();
      humidity = results['main']['humidity'].toString();
      windspeed = results['wind']['speed'].toString();
      city = results['name'].toString();
      sunrise = results['sys']['sunrise'].toString();
      sunset = results['sys']['sunset'].toString();
    });
  }

  String saudacao() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      return 'Boa tarde';
    } else if (hour >= 18 || hour < 5) {
      return 'Boa noite';
    } else {
      return 'Olá';
    }
  }

  @override
  void initState() {
    super.initState();
    //getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(
            '${saudacao()}',
            style: TextStyle(
              color: Color.fromARGB(255, 33, 4, 4),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _Checkper();
                    },
                    child: Text(
                      'Localiza aí',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      getWeather();;
                    },
                    child: Text(
                      'Como esta o tempo?',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      // ignore: unnecessary_null_comparison
                      "Currently" + city.toString() != null
                          ? city.toString()
                          : "Loading",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.8,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    temp != null ? temp.toString() + "\u0000" : "Loading",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      currently != null ? currently.toString() : "Loading",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    // ignore: deprecated_member_use
                    leading: const FaIcon(FontAwesomeIcons.thermometerHalf),
                    title: const Text('Temperature'),
                    trailing: Text(
                        temp != null ? temp.toString() + "\u00B0C" : "Loading"),
                  ),
                  ListTile(
                    // ignore: deprecated_member_use
                    leading: const FaIcon(FontAwesomeIcons.cloud),
                    title: const Text('Weather'),
                    trailing: Text(description != null
                        ? description.toString()
                        : "Loading"),
                  ),
                  ListTile(
                    // ignore: deprecated_member_use
                    leading: const FaIcon(FontAwesomeIcons.sun),
                    title: const Text('Humidity'),
                    trailing: Text(humidity != null
                        ? humidity.toString() + "%"
                        : "Loading"),
                  ),
                  ListTile(
                    // ignore: deprecated_member_use
                    leading: const FaIcon(FontAwesomeIcons.wind),
                    title: const Text('Wind Speed'),
                    trailing: Text(windspeed != null
                        ? windspeed.toString() + " m/s"
                        : "Loading"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
