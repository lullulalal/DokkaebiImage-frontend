import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:DokkaebieImage/footer/privacy_policy.dart';
import 'package:DokkaebieImage/footer/cookie_preferences.dart';
import 'package:DokkaebieImage/footer/terms_of_use.dart';

import 'package:DokkaebieImage/body/color_transfer.dart';
import 'package:DokkaebieImage/body/noise_remover.dart';

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
    _currentBody = _buildMainContent();
  }

  void _showToolPage(int index) {
    switch (index) {
      case 0:
        setState(() { _currentBody = const ColorTransferBody(); });
        break;
      case 1:
        setState(() { _currentBody = const NoiseRemoverBody(); });
        break;
      default:
        setState(() {
          _currentBody = _buildMainContent();
        });
    }
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            // Section 1
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'introduce_header'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'introduce_contents'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Gap Text and Wrap
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(numberOfTools, (index) {
                        return Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () => _showToolPage(index),
                            hoverColor: Colors.red[50],
                            child: Container(
                              width: 320,
                              height: 150,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/tool${index + 1}.png',
                                        width: 60,
                                        height: 60,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'tool${index + 1}_header'.tr(),
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.inter(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'tool${index + 1}_contents'.tr(),
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Section 2
            const SizedBox(height: 35),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 32,
                        children: [
                          Image.asset('images/logo.png', height: 90),
                          Text(
                            'explain_header'.tr(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'explain_contents'.tr(),
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.linkedin),
                            color: const Color(0xFF0A66C2),
                            iconSize: 22,
                            tooltip: 'LinkedIn',
                            onPressed: () async {
                              const url =
                                  'https://www.linkedin.com/in/minsu-seo-6b77a3112/';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.solidEnvelope),
                            color: Colors.black87,
                            iconSize: 22,
                            tooltip: 'Email',
                            onPressed: () async {
                              const email = 'mailto:lullulalal@gmail.com';
                              if (await canLaunchUrl(Uri.parse(email))) {
                                await launchUrl(Uri.parse(email));
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Section 3
            Container(
              width: double.infinity,
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<Locale>(
                        value: context.locale,
                        underline: const SizedBox(),
                        focusColor: Colors.transparent,
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ko'),
                            child: Text('한국어'),
                          ),
                        ],
                        onChanged: (locale) {
                          if (locale != null) {
                            context.setLocale(locale);
                          }
                        },
                      ),
                    ],
                  ),
                  Text(
                    '© 2025 Dokkaebi Image. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    children: [
                      _footerLink('privacy_policy_header'.tr(), () {
                        setState(() {
                          _currentBody = const PrivacyPolicyBody();
                        });
                      }),
                      _footerLink('terms_of_use_header'.tr(), () {
                        setState(() {
                          _currentBody = const TermsOfUseBody();
                        });
                      }),
                      _footerLink('cookie_preferences_header'.tr(), () {
                        setState(() {
                          _currentBody = const CookiePreferencesBody();
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
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
                _currentBody = _buildMainContent();
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
