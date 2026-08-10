import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppPaletteScheme {
  const AppPaletteScheme({required this.id, required this.name, required this.primary, required this.primaryBright, required this.primaryDim, required this.secondary, required this.tertiary, required this.background, required this.surface, required this.surfaceElevated, required this.surfaceMuted, required this.outline, required this.outlineMuted, required this.track, required this.wheelNeutral, required this.wheelRisk});

  final int id;
  final String name;
  final Color primary;
  final Color primaryBright;
  final Color primaryDim;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color outline;
  final Color outlineMuted;
  final Color track;
  final Color wheelNeutral;
  final Color wheelRisk;
}

abstract final class AppPalette {
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFD5DCE7);
  static const textMuted = Color(0xFFA8B4C5);
  static const success = Color(0xFF6EE7B7);
  static const warning = Color(0xFFFDBA74);
  static const error = Color(0xFFFB7185);

  static const schemes = <AppPaletteScheme>[
    AppPaletteScheme(id: 0, name: 'Gece Safiri', primary: Color(0xFF4F82B5), primaryBright: Color(0xFF9BBBDD), primaryDim: Color(0xFF2B537E), secondary: Color(0xFF38BDF8), tertiary: Color(0xFFFDBA74), background: Color(0xFF0A1424), surface: Color(0xFF11243A), surfaceElevated: Color(0xFF183655), surfaceMuted: Color(0xFF0D1C30), outline: Color(0xFF5F8DB6), outlineMuted: Color(0xFF345675), track: Color(0xFF284A6B), wheelNeutral: Color(0xFF284A6B), wheelRisk: Color(0xFF9F5268)),
    AppPaletteScheme(id: 1, name: 'Z\u00fcmr\u00fct Orman', primary: Color(0xFF2F9E79), primaryBright: Color(0xFF8FE0BF), primaryDim: Color(0xFF1E6B53), secondary: Color(0xFF67C7B1), tertiary: Color(0xFFF2C14E), background: Color(0xFF071B17), surface: Color(0xFF0D2B23), surfaceElevated: Color(0xFF144436), surfaceMuted: Color(0xFF0A241D), outline: Color(0xFF4D9079), outlineMuted: Color(0xFF285A4A), track: Color(0xFF285044), wheelNeutral: Color(0xFF2A5A4E), wheelRisk: Color(0xFFB35F59)),
    AppPaletteScheme(id: 2, name: 'Okyanus', primary: Color(0xFF168AAD), primaryBright: Color(0xFF73CFE5), primaryDim: Color(0xFF0C536A), secondary: Color(0xFF5BC0EB), tertiary: Color(0xFFF4A261), background: Color(0xFF061A27), surface: Color(0xFF0B3044), surfaceElevated: Color(0xFF124A61), surfaceMuted: Color(0xFF082538), outline: Color(0xFF4F91A8), outlineMuted: Color(0xFF245A70), track: Color(0xFF285C74), wheelNeutral: Color(0xFF285468), wheelRisk: Color(0xFFC56C50)),
    AppPaletteScheme(id: 3, name: 'Koral Gece', primary: Color(0xFFD5645A), primaryBright: Color(0xFFF3A29A), primaryDim: Color(0xFF873B37), secondary: Color(0xFF6FA8DC), tertiary: Color(0xFFF6BD60), background: Color(0xFF200F15), surface: Color(0xFF32171D), surfaceElevated: Color(0xFF481F28), surfaceMuted: Color(0xFF28131A), outline: Color(0xFFA96669), outlineMuted: Color(0xFF6C3B45), track: Color(0xFF60353E), wheelNeutral: Color(0xFF5A343A), wheelRisk: Color(0xFFB04F5A)),
    AppPaletteScheme(id: 4, name: 'Amber \u015eehir', primary: Color(0xFFD69E2E), primaryBright: Color(0xFFF6D58A), primaryDim: Color(0xFF805B16), secondary: Color(0xFF63B3ED), tertiary: Color(0xFFF08A5D), background: Color(0xFF211707), surface: Color(0xFF34230A), surfaceElevated: Color(0xFF49310D), surfaceMuted: Color(0xFF2A1C08), outline: Color(0xFFA58132), outlineMuted: Color(0xFF6F541D), track: Color(0xFF624919), wheelNeutral: Color(0xFF5D4719), wheelRisk: Color(0xFFB45F3C)),
    AppPaletteScheme(id: 5, name: 'Slate', primary: Color(0xFF64748B), primaryBright: Color(0xFFCBD5E1), primaryDim: Color(0xFF334155), secondary: Color(0xFF94A3B8), tertiary: Color(0xFFA3E635), background: Color(0xFF10161D), surface: Color(0xFF1C2732), surfaceElevated: Color(0xFF2A3948), surfaceMuted: Color(0xFF151E27), outline: Color(0xFF8298A9), outlineMuted: Color(0xFF465A6A), track: Color(0xFF3B4D5D), wheelNeutral: Color(0xFF3B4855), wheelRisk: Color(0xFFA45B6A)),
    AppPaletteScheme(id: 6, name: 'Kobalt', primary: Color(0xFF3B82F6), primaryBright: Color(0xFF93C5FD), primaryDim: Color(0xFF1D4ED8), secondary: Color(0xFF22D3EE), tertiary: Color(0xFFFBBF24), background: Color(0xFF081633), surface: Color(0xFF102A55), surfaceElevated: Color(0xFF1B3C72), surfaceMuted: Color(0xFF0C2246), outline: Color(0xFF5D8DD2), outlineMuted: Color(0xFF2E568F), track: Color(0xFF2C518C), wheelNeutral: Color(0xFF2C4C82), wheelRisk: Color(0xFFC15C50)),
    AppPaletteScheme(id: 7, name: 'Jade', primary: Color(0xFF0F8B8D), primaryBright: Color(0xFF70D6C5), primaryDim: Color(0xFF075B5D), secondary: Color(0xFF7DD3FC), tertiary: Color(0xFFF4A261), background: Color(0xFF061D1F), surface: Color(0xFF0C3030), surfaceElevated: Color(0xFF164643), surfaceMuted: Color(0xFF092527), outline: Color(0xFF4F9990), outlineMuted: Color(0xFF276A66), track: Color(0xFF27605D), wheelNeutral: Color(0xFF275553), wheelRisk: Color(0xFFC56F58)),
    AppPaletteScheme(id: 8, name: 'G\u00fcl A\u011fac\u0131', primary: Color(0xFFB4536A), primaryBright: Color(0xFFF1A4B5), primaryDim: Color(0xFF762C46), secondary: Color(0xFF9BBBDD), tertiary: Color(0xFFF0B37E), background: Color(0xFF200C18), surface: Color(0xFF341525), surfaceElevated: Color(0xFF4A2035), surfaceMuted: Color(0xFF28101D), outline: Color(0xFFA97687), outlineMuted: Color(0xFF6F4055), track: Color(0xFF61364C), wheelNeutral: Color(0xFF5C3347), wheelRisk: Color(0xFFB85C6B)),
    AppPaletteScheme(id: 9, name: 'Grafit Lime', primary: Color(0xFF84A32E), primaryBright: Color(0xFFD5E69A), primaryDim: Color(0xFF536A1C), secondary: Color(0xFF86C5DA), tertiary: Color(0xFFF2B880), background: Color(0xFF141B08), surface: Color(0xFF273512), surfaceElevated: Color(0xFF394B1A), surfaceMuted: Color(0xFF1A240C), outline: Color(0xFF81984D), outlineMuted: Color(0xFF53652B), track: Color(0xFF485C22), wheelNeutral: Color(0xFF43521E), wheelRisk: Color(0xFFB96B4F)),
  ];

  static AppPaletteScheme _current = schemes.first;
  static final ValueNotifier<int> _selection = ValueNotifier<int>(_current.id);
  static AppPaletteScheme get current => _current;
  static ValueListenable<int> get listenable => _selection;
  static Color get background => _current.background;
  static Color get surface => _current.surface;
  static Color get surfaceElevated => _current.surfaceElevated;
  static Color get surfaceMuted => _current.surfaceMuted;
  static Color get outline => _current.outline;
  static Color get outlineMuted => _current.outlineMuted;
  static Color get track => _current.track;
  static Color get primary => _current.primary;
  static Color get primaryBright => _current.primaryBright;
  static Color get primaryDim => _current.primaryDim;
  static Color get secondary => _current.secondary;
  static Color get tertiary => _current.tertiary;
  static Color get wheelNeutral => _current.wheelNeutral;
  static Color get wheelRisk => _current.wheelRisk;

  static void select(int id) {
    final next = schemes.firstWhere((scheme) => scheme.id == id, orElse: () => schemes.first);
    if (_current.id == next.id) {
      return;
    }
    _current = next;
    _selection.value = next.id;
  }
}
