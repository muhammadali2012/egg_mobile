import 'package:egg_mobile/login_screen.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator('localhost', 55796);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favourite = <WordPair>[];

  void toogelFavourite() {
    if (favourite.contains(current)) {
      favourite.remove(current);
    } else {
      favourite.add(current);
    }
    notifyListeners();
  }

  bool isSaved() {
    return favourite.contains(current) ? true : false;
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void removeFavourite(WordPair fav) {
    favourite.remove(fav);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = Favourite();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LoginScreen();

    // return LayoutBuilder(builder: (context, constraints) {
    //   return Scaffold(
    //     body: Row(
    //       children: [
    //         SafeArea(
    //           child: NavigationRail(
    //             extended: constraints.maxWidth >= 600,
    //             destinations: [
    //               NavigationRailDestination(
    //                 icon: Icon(Icons.home),
    //                 label: Text('Home'),
    //               ),
    //               NavigationRailDestination(
    //                 icon: Icon(Icons.favorite),
    //                 label: Text('Favorites'),
    //               ),
    //             ],
    //             selectedIndex: selectedIndex,
    //             onDestinationSelected: (value) {
    //               print('selected: $value');
    //               setState(() {
    //                 selectedIndex = value;
    //               });
    //             },
    //           ),
    //         ),
    //         Expanded(
    //           child: Container(
    //             color: Theme.of(context).colorScheme.primaryContainer,
    //             child: page,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favourite.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toogelFavourite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
            onPressed: () {
              appState.toogelFavourite();
            },
            icon: Icon(
              appState.isSaved() ? Icons.favorite : Icons.favorite_outline,
              color: Colors.pink,
            ),
            label: Text("like")),
        SizedBox(
          width: 20,
        ),
        ElevatedButton(
          onPressed: () {
            appState.getNext();
          },
          child: Text('Next'),
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class Favourite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.headlineLarge!
        .copyWith(color: theme.colorScheme.onPrimary);

    var appState = context.watch<MyAppState>();
    var favourite = appState.favourite;

    return ListView(
      children: [
        Text("Favourites Names", style: style),
        for (var fav in favourite)
          ListTile(
            title: Text(fav.asLowerCase),
            leading: Icon(Icons.favorite),
            onTap: () {
              appState.removeFavourite(fav);
            },
          ),
      ],
    );
  }
}
