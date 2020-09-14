import 'package:flutter/material.dart';
import 'package:meteoapp/main.dart';

class DetailsPage extends StatelessWidget {
  final City city;

  DetailsPage(this.city);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(city.cityName),
      ),
    );
  }
}
