import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/recipe_provider.dart';
import 'providers/ai_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // API key for OpenAI. Provide via `--dart-define=OPENAI_API_KEY=...` when
  // running the app. In this sample we simply read it from the Dart
  // environment; the `AiService.fromEnvironment()` factory also uses the
  // same variable and will throw an error if it’s missing. Avoid committing
  // the key into source control – inject it at build/run time instead.
  const openAiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  runApp(const ReciFinderApp(openAiKey: openAiKey));
}

class ReciFinderApp extends StatelessWidget {
  /// API key passed from `main` so we can construct the AiProvider.
  final String openAiKey;

  const ReciFinderApp({super.key, required this.openAiKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider(apiKey: openAiKey)),
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
