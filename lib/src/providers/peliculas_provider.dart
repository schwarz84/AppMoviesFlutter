import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:peliculas/src/models/pelicula_model.dart';
import 'package:peliculas/src/models/actor_model.dart';

class PeliculasProvider {

  String _apikey   = 'bb9d973e8be9f9b8942559c88b19cabc';
  String _url      = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularesPage = 0;
  bool _cargando     = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;

  void disposeStream() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {

    final respuesta = await http.get(url);
    final decodeData = json.decode(respuesta.body);

    final peliculas = new Peliculas.fromJsonList(decodeData['results']);

    return peliculas.items;
  }


  Future<List<Pelicula>>getenCine() async {


    final url = Uri.https(_url, '3/movie/now_playing', {

      'api_key'  : _apikey,
      'language' : _language,

    });

    return await _procesarRespuesta(url);

  }

  Future<List<Pelicula>>getPopulares() async { 

    if (_cargando) return [];

    _cargando = true;
    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular', {

      'api_key'  : _apikey,
      'language' : _language,
      'page'     : _popularesPage.toString(),

    });

    final respuesta = await _procesarRespuesta(url);
    _populares.addAll(respuesta);
    popularesSink(_populares);

    _cargando = false;

    return respuesta;

  }


  Future<List<Actor>>getActores(String peliId) async {

    final url = Uri.https(_url, '3/movie/$peliId/credits', {
      'api_key'  : _apikey,
      'language' : _language,
    });

    final respuesta = await http.get(url);
    final decodeData = json.decode(respuesta.body);

    final cast = Cast.fromJsonList(decodeData['cast']);

    return cast.actores;

  }

  Future<List<Pelicula>>searchMovie(String query) async {


    final url = Uri.https(_url, '3/search/movie', {

      'api_key'  : _apikey,
      'language' : _language,
      'query'    : query,

    });

    return await _procesarRespuesta(url);

  }
}
