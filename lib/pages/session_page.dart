import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocinema/models/session.dart';
import 'package:geocinema/repository.dart';
import 'package:intl/intl.dart';

import '../models/cinema.dart';
import '../models/film.dart';

class SessionPage extends StatelessWidget {
  static const String routeName = '/session';

  final Film film;
  final Cinema cinema;

  const SessionPage({Key key, this.film, this.cinema}) : super(key: key);

  static void open(BuildContext context, Film film, Cinema cinema) {
    Navigator.of(context)
        .pushNamed(routeName, arguments: {'film': film, 'cinema': cinema});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cinema.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              //TODO
            },
          )
        ],
      ),
      body: BlocBuilder(
        bloc: BlocProvider.of<SessionBloc>(context)
          ..add(Fetch(film: film, cinema: cinema)),
        builder: (BuildContext context, state) {
          if (state is Loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is Error) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is Success) {
            return ListView(
                children: state.sessions.keys.map((key) => DaySessionsCard(
                          date: key,
                          sessions: state.sessions[key],
                        ))
                    .toList());
          }
        },
      ),
    );
  }
}

class DaySessionsCard extends StatelessWidget {
  final DateTime date;
  final List<Session> sessions;

  const DaySessionsCard({Key key, this.date, this.sessions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(DateFormat.),//'23 May, Thursday'),
          Divider(),
          Wrap(
            children: sessions
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: OutlineButton(
                        onPressed: () {
                          //TODO
                        },
                        child: Text(e),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

abstract class SessionEvent {}

class Fetch extends SessionEvent {
  final Film film;
  final Cinema cinema;

  Fetch({this.film, this.cinema});
}

abstract class SessionState {}

class Loading extends SessionState {}

class Error extends SessionState {
  final String message;

  Error(this.message);
}

class Success extends SessionState {
  final Map<DateTime, List<Session>> sessions;

  Success(this.sessions);
}

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final Repository _repository;
  Film _film;
  Cinema _cinema;
  Map<DateTime, List<Session>> _sessions = {};

  SessionBloc(this._repository);

  @override
  SessionState get initialState => Loading();

  @override
  Stream<SessionState> mapEventToState(SessionEvent event) async* {
    if (event is Fetch) {
      _film = event.film;
      _cinema = event.cinema;

      try {
        List<Session> sessions = await _repository.getSessions(_film, _cinema);
        for (Session ses in sessions) {
          DateTime date = DateTime(ses.date.year, ses.date.month, ses.date.day);
          if (!_sessions.containsKey(date)) {
            _sessions.putIfAbsent(date, () {
              return _sessions[date]..add(ses);
            });
          }
        }
        yield Success(_sessions);
      } on HttpException catch (e) {
        yield Error(e.message);
      }
    }
  }
}
