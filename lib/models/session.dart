import 'package:geocinema/models/cinema.dart';
import 'package:geocinema/models/film.dart';

class Session{

  final Film film;
  final Cinema cinema;
  final DateTime date;
  final bool is3d;
  final bool isImax;

  Session({this.film, this.cinema, this.date, this.is3d, this.isImax, });

}