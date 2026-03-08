import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/recipe_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ReciFinderApp());
}

class ReciFinderApp extends StatelessWidget {
  const ReciFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: 'ReciFinder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
