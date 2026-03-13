import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/recipe_provider.dart';
import 'providers/ai_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // API key for OpenAI. Provide it via `--dart-define=OPENAI_API_KEY=...`.
  // If you want to hard-code it for testing, set the default below.
  const openAiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  runApp(ReciFinderApp(openAiKey: openAiKey));
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
