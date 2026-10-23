part of chem_lab;

class ChemLabApp extends StatelessWidget {
  const ChemLabApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Virtual Chemistry Lab',
      theme: ThemeData(
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(6.0),
        radius: const Radius.circular(3.0),
        thumbColor: WidgetStateProperty.all(const Color(0xFF4A8FE7).withValues(alpha: 0.6)),
        crossAxisMargin: 2.0,
        mainAxisMargin: 4.0,
      ),brightness: Brightness.dark, fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: LC.bgDeep, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}



