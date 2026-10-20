part of chem_lab;

class ChemLabApp extends StatelessWidget {
  const ChemLabApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Virtual Chemistry Lab',
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: LC.bgDeep, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}



