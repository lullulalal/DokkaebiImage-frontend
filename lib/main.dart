import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:DokkaebieImage/bodies/color_transfer.dart';
import 'package:DokkaebieImage/bodies/noise_remover.dart';
import 'package:DokkaebieImage/bodies/main_contents.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DokkaebiImage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: const DokkaebiImage(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

class DokkaebiImage extends StatefulWidget {
  const DokkaebiImage({super.key});

  @override
  State<DokkaebiImage> createState() => _DokkaebiImageState();
}

class _DokkaebiImageState extends State<DokkaebiImage> {
  Widget? _currentBody;
  int numberOfTools = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentBody = MainContentBody(
      onToolTap: _showToolPage,
      onFooterPageSelected: (widget) => setState(() {
        _currentBody = widget;
      }),
      numberOfTools: numberOfTools,
    );
  }

  void _showToolPage(int index) {
    switch (index) {
      case 0:
        setState(() {
          _currentBody = const ColorTransferBody();
        });
        break;
      case 1:
        setState(() {
          _currentBody = const NoiseRemoverBody();
        });
        break;
      default:
        setState(() {
          _currentBody = MainContentBody(
            onToolTap: _showToolPage,
            onFooterPageSelected: (widget) => setState(() {
              _currentBody = widget;
            }),
            numberOfTools: numberOfTools,
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 65,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.redAccent),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tools',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
            ...List.generate(numberOfTools, (index) {
              return ListTile(
                leading: Image.asset(
                  'assets/images/tool${index + 1}.png',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  'tool${index + 1}_header'.tr(),
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                onTap: () => _showToolPage(index),
              );
            }),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentBody = MainContentBody(
                  onToolTap: _showToolPage,
                  onFooterPageSelected: (widget) => setState(() {
                    _currentBody = widget;
                  }),
                  numberOfTools: numberOfTools,
                );
              });
            },
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  'Dokkaebi',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  'Image',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.apps),
              color: Colors.black87,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: _currentBody,
    );
  }
}
