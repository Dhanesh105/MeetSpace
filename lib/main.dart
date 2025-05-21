import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/booking_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookingProvider(),
      child: MaterialApp(
        title: 'Calendar Booking App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6200EE),        // Deep purple
            onPrimary: Colors.white,
            primaryContainer: Color(0xFFE9DDFF),
            secondary: Color(0xFF03DAC6),      // Teal
            onSecondary: Colors.black,
            secondaryContainer: Color(0xFFCEFAF8),
            tertiary: Color(0xFFFF8A65),       // Coral
            tertiaryContainer: Color(0xFFFFECE3),
            surface: Color(0xFFF8F9FA),  // Replace background with surface
            error: Color(0xFFB00020),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6200EE),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          // Card styling will be applied directly to Card widgets
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFB00020), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFB00020), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            hintStyle: TextStyle(color: Colors.grey.shade400),
            labelStyle: const TextStyle(color: Color(0xFF6200EE)),
            floatingLabelStyle: const TextStyle(
              color: Color(0xFF6200EE),
              fontWeight: FontWeight.bold,
            ),
            prefixIconColor: const Color(0xFF6200EE),
            suffixIconColor: const Color(0xFF6200EE),
            // Add shadow to input fields
            isDense: true,
            errorStyle: const TextStyle(
              color: Color(0xFFB00020),
              fontWeight: FontWeight.w500,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6200EE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6200EE),
              side: const BorderSide(color: Color(0xFF6200EE), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6200EE),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Color(0xFF212121),
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Color(0xFF212121),
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
              color: Color(0xFF212121),
            ),
            headlineLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
              color: Color(0xFF212121),
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
              color: Color(0xFF212121),
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF212121),
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              color: Color(0xFF212121),
            ),
            titleSmall: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: Color(0xFF212121),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              letterSpacing: 0.15,
              color: Color(0xFF424242),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              letterSpacing: 0.25,
              color: Color(0xFF424242),
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              letterSpacing: 0.4,
              color: Color(0xFF616161),
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.25,
              color: Color(0xFF6200EE),
            ),
          ),
          dividerTheme: const DividerThemeData(
            thickness: 1,
            space: 32,
            color: Color(0xFFE0E0E0),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF323232),
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 0.25,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
