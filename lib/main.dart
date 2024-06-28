import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:news_app/provider/news_provider.dart';
import 'package:news_app/screens/add_news.dart';
import 'package:provider/provider.dart';
import 'package:news_app/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NewsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF003049);
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: primaryColor),
        colorScheme: ColorScheme.light(
          background: const Color(0xFFd9d9d9),
          primary: const Color(0xFF003049),
          secondary: Colors.white,
          inversePrimary: Colors.grey.shade900,
        ),
      ),
      home: const HomePage(),
      routes: {
        AddNews.routeName: (context) => const AddNews(),
      },
    );
  }
}
