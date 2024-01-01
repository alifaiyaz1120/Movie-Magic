import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_magic/movie_detail_page.dart';
import 'package:movie_magic/watch_list_page.dart';
import 'Backend/backend.dart';

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const WatchListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242A32),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF242A32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30.0,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.bookmark,
                size: 30.0,
              ),
              label: 'Watch List',
            ),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  HomePageContentState createState() => HomePageContentState();
}

class HomePageContentState extends State<HomePageContent> {
  final _searchController = TextEditingController();
  var _searchedMovies = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateMovies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateMovies() async {
    try {
      final searchTerm = _searchController.text.trim();

      if (searchTerm.isEmpty || searchTerm.length == 1) {
        final movies = await fetchMoviesByFilter(MovieFilter.popular);
        setState(() {
          _searchedMovies = movies?['results'] ?? [];
        });
      } else {
        final movies = await searchMovies(searchTerm);

        if (searchTerm.length == 1 && (movies == null || movies.isEmpty)) {
          setState(() {
            _searchedMovies = [];
          });
        } else {
          setState(() {
            _searchedMovies = movies ?? [];
          });
        }
      }
    } catch (error) {
      print('Error fetching movies: $error');
      setState(() {
        _searchedMovies = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              const Text(
                'What are you feeling?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color.fromARGB(255, 77, 77, 77),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 77, 77, 77),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _searchController.text.isEmpty
                    ? const Center(
                        child: Text(
                          'Start typing to search for movies.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : _searchedMovies.isEmpty
                        ? const Center(
                            child: Text(
                              'No movies found.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : _buildSearchResults(),
              ),
              const SizedBox(height: 16.0),
              _buildPopularMoviesCarousel(),
              const SizedBox(height: 16.0),
              _buildMovieTabs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchedMovies.take(5).length,
      itemBuilder: (context, index) {
        final movie = _searchedMovies[index];
        final backdropPath = movie['backdrop_path'];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(movieId: movie['id']),
              ),
            );
          },
          child: ListTile(
            title: Text(
              movie['title'] ?? 'Movie Title Not Available',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: backdropPath != null
                ? SizedBox(
                    width: 50.0,
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500$backdropPath',
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        );
                      },
                    ),
                  )
                : Container(),
          ),
        );
      },
    );
  }

  Widget _buildMovieTabs() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Now Playing'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Top Rated'),
                  Tab(text: 'Popular'),
                ],
                labelColor: Colors.white,
                labelStyle: TextStyle(fontSize: 10),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMovies(MovieFilter.nowPlaying),
                    _buildMovies(MovieFilter.upcoming),
                    _buildMovies(MovieFilter.topRated),
                    _buildMovies(MovieFilter.popular),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildAsyncFetchError(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else {
      return null;
    }
  }

  Widget _buildPopularMoviesCarousel() {
    return FutureBuilder(
        future: fetchMoviesByFilter(MovieFilter.popular),
        builder: (context, snapshot) {
          final errorWidget = _buildAsyncFetchError(context, snapshot);
          if (errorWidget != null) {
            return errorWidget;
          }

          final popularMovies = snapshot.data['results'].take(10).toList();
          return CarouselSlider(
              options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(seconds: 2),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  viewportFraction: 1.0,
                  enlargeCenterPage: true),
              items: List.generate(
                popularMovies.length,
                (index) {
                  final movie = popularMovies[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(
                            movieId: movie['id'],
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie['backdrop_path']}',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ));
        });
  }

  Widget _buildMovies(MovieFilter movieFilter) {
    return FutureBuilder(
        future: fetchMoviesByFilter(movieFilter),
        builder: (context, snapshot) {
          final errorWidget = _buildAsyncFetchError(context, snapshot);
          if (errorWidget != null) {
            return errorWidget;
          }

          final nowPlayingMovies = snapshot.data['results'];
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: (nowPlayingMovies.length / 3).ceil(),
            itemBuilder: (context, rowIndex) {
              final startIndex = rowIndex * 3;
              var endIndex = (rowIndex + 1) * 3;
              if (endIndex > nowPlayingMovies.length) {
                endIndex = nowPlayingMovies.length;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: List.generate(
                    endIndex - startIndex,
                    (index) {
                      final movie = nowPlayingMovies[startIndex + index];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                    movieId: movie['id'],
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        });
  }
}
