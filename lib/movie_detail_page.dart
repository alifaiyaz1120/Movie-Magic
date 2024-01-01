// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:postgres/legacy.dart';
import 'package:postgres/postgres.dart';
import 'Backend/backend.dart';
import 'package:localstorage/localstorage.dart';

class DetailsPage extends StatefulWidget {
  @override
  const DetailsPage({super.key, required this.movieId});
  final int movieId;
  @override
  // ignore: library_private_types_in_public_api
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Map<String, dynamic> _movieDetails = <String, dynamic>{};
  List<dynamic> _reviews = [];

  bool inWatchlist = false;
  final LocalStorage storage = LocalStorage('MovieApp.json');

  @override
  void initState() {
    super.initState();
    _getMovieDetails(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242A32),
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              (inWatchlist == true ? Icons.bookmark : Icons.bookmark_outline),
              color: Colors.white,
            ),
            onPressed: () {
              if (inWatchlist) {
                removeFromWatchlist(
                    storage.getItem('userID'), _movieDetails['id']);
                setState(() {
                  inWatchlist = false;
                });
              } else {
                addToWatchlist(storage.getItem('userID'), _movieDetails['id']);
                setState(() {
                  inWatchlist = true;
                });
              }
            },
          )
        ],
        title: const Center(
          child: Text(
            "Details",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Column(children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                        width: double.infinity,
                        height: 225,
                        decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(_movieDetails[
                                          'poster_path'] !=
                                      null
                                  ? 'https://image.tmdb.org/t/p/w500${_movieDetails['backdrop_path']}'
                                  : ""),
                              fit: BoxFit.fill,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            )))),
                Positioned(
                  bottom: 0,
                  left: 25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 95,
                        height: 120,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_movieDetails['poster_path'] !=
                                    null
                                ? 'https://image.tmdb.org/t/p/w500${_movieDetails['poster_path']}'
                                : ""),
                            fit: BoxFit.fill,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 250,
                        height: 60,
                        child: Text(
                          // ignore: prefer_if_null_operators
                          _movieDetails['title'] != null
                              ? _movieDetails['title']
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            _movieDetails['title'] != null
                ? _movieDetails['release_date'] +
                    '  |  ' +
                    _movieDetails['runtime'].toString() +
                    ' Minutes  |  ' +
                    _movieDetails['genres'][0]['name']
                : '',
            style: const TextStyle(
              color: Color(0xFF92929D),
              fontSize: 16,
              fontFamily: 'Montserrat',
              height: 0,
              letterSpacing: 0.12,
            ),
          ),
          _buildMovieDetails(),
          const SizedBox(
            height: 10,
          ),
        ]),
      ),
    );
  }

  Widget _buildMovieDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const TabBar(
                isScrollable: true,
                labelStyle: TextStyle(fontSize: 16),
                indicatorWeight: 3.0,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 16.0),
                tabs: [
                  Tab(text: 'About Movie'),
                  Tab(text: 'Reviews'),
                ],
                indicatorColor: Colors.blue,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: TabBarView(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Text(
                            // ignore: prefer_if_null_operators
                            _movieDetails['overview'] != null
                                ? _movieDetails['overview']
                                : '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                        )),
                    _buildReviews(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return ListView.builder(
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.black), // Black outline
            color: Colors.black26, // Transparent background
          ),
          child: ListTile(
            title: Text(
              '${_reviews[index]['author']}',
              style: TextStyle(color: Colors.blue),
            ),
            subtitle: Text(
              '${_reviews[index]['content']}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Future<void> _getMovieDetails(int movieID) async {
    try {
      final movieDetails = await fetchMovieDetails(movieID);
      final reviews = await fetchMovieReviews(movieID);

      final results = await fetchMovieDetails(movieID);

      // int x = storage.getItem('userID');
      _checkWatchlist(movieID);
      // getWatchList(x);
      setState(() {
        _movieDetails = movieDetails;
        _reviews = reviews['results'] ?? [];
      });
    } catch (error) {
      print('Error fetching movie details: $error');
    }
  }

  void _checkWatchlist(int movieID) async {
    try {
      final results = await fetchMovieDetails(movieID);

      int x = storage.getItem('userID');

      Future<bool> check = isInWatchlist(x, movieID);
      if (await check) {
        setState(() {
          inWatchlist = true;
        });
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error searching movies: $error');
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: DetailsPage(
      movieId: 6,
    ),
  ));
}
