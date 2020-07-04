import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocinema/pages/cinema_map.dart';
import 'package:geocinema/pages/film_list.dart';
import 'package:geocinema/pages/film_page.dart';
import 'package:geocinema/pages/session_page.dart';
import 'package:geocinema/repository.dart';

void main() {
  final Repository _repository = Repository();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<FilmListBloc>(
        create: (BuildContext context) => FilmListBloc(_repository),
      ),
      BlocProvider<MapBloc>(
        create: (BuildContext context) => MapBloc(_repository),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoCinema',
      initialRoute: '/',
      routes: {
        '/': (context) => FilmList(),
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case FilmPage.routeName:
            return MaterialPageRoute(
                builder: (BuildContext context) => FilmPage(
                      film: settings.arguments,
                    ));
          case CinemaMap.routeName:
            return MaterialPageRoute(
                builder: (BuildContext context) => CinemaMap(
                      film: settings.arguments,
                    ));
          case SessionPage.routeName:
            if (settings.arguments is Map<String, dynamic>) {
              return MaterialPageRoute(
                  builder: (BuildContext context) => SessionPage(
                        film: (settings.arguments
                            as Map<String, dynamic>)['film'],
                        cinema: (settings.arguments
                            as Map<String, dynamic>)['cinema'],
                      ));
            }
            return null;
          default:
            return null;
        }
      },
    );
  }
}
