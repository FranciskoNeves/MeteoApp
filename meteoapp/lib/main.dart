import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meteoapp/details.dart';
import 'package:intl/intl.dart';
import 'package:flutter_unity/flutter_unity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.blue[900],
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark),
      home: MyHomePage(title: 'Cities Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> citiesID = [2267056, 2267094, 2740636, 2735941, 2268337];
  bool throwError = false;

  Future<List<City>> _getCities() async {
    List<City> cities = [];
    for (var id in citiesID) {
      try {
        var url =
            'http://api.openweathermap.org/data/2.5/forecast?APPID=5741efab2d550b7937f8bd2f5a82d482&id=$id';
        var data = await http.get(url);
        Map jsonData = json.decode(data.body);
        //Convert Datetime to format dd-MM-yy HH:mm:ss
        DateTime parsedDatetime = DateTime.parse(jsonData['list'][0]['dt_txt']);
        var datetimeFormatter = DateFormat("dd-MM-yy HH:mm:ss");
        String datetime = datetimeFormatter.format(parsedDatetime);
        //Convert Temperature from Kelvin to Celsius and round to one decimal place
        double tempCelsius = double.parse(
            (jsonData['list'][0]['main']['temp'] - 273.15).toStringAsFixed(1));
        City city = new City(jsonData['city']['name'], tempCelsius,
            jsonData['list'][0]['weather'][0]['main'], datetime);
        cities.add(city);
      } catch (e) {
        throwError = true;
      }
    }
    return cities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(letterSpacing: 5.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: FutureBuilder(
          future: _getCities(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Loading..."),
                ),
              );
            } else {
              if (throwError) {
                return Container(
                  child: Center(
                    child: Text(
                        "There's an error when retrieving the data. See if you are connected to the internet!"),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        title: Text(snapshot.data[index].cityName),
                        subtitle: Text(snapshot.data[index].datetime),
                        trailing: Text(
                            snapshot.data[index].temperature.toString() + "ºC"),
                        onTap: () {
                          /* Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    DetailsPage(snapshot.data[index]))); */
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UnityViewPage()));
                        });
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class City {
  final String cityName;
  final double temperature;
  final String weather;
  final String datetime;

  City(this.cityName, this.temperature, this.weather, this.datetime);
}

class UnityViewPage extends StatefulWidget {
  @override
  _UnityViewPageState createState() => _UnityViewPageState();
}

class _UnityViewPageState extends State<UnityViewPage> {
  UnityViewController unityViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: UnityView(
        onCreated: onUnityViewCreated,
        onReattached: onUnityViewReattached,
        onMessage: onUnityViewMessage,
      ),
    );
  }

  void onUnityViewCreated(UnityViewController controller) {
    print('onUnityViewCreated');

    unityViewController = controller;

    controller.send(
      'Cube',
      'SetRotationSpeed',
      '30',
    );
  }

  void onUnityViewReattached(UnityViewController controller) {
    print('onUnityViewReattached');
  }

  void onUnityViewMessage(UnityViewController controller, String message) {
    print('onUnityViewMessage');

    print(message);
  }
}
