import 'dart:convert';

class OwnedAssetIdsCodec {
  String? encode(List<int> ids) => ids.isEmpty ? null : jsonEncode(ids);

  List<int> decode(String? value) {
    if (value == null || value.isEmpty) return const <int>[];
    try {
      return List<int>.unmodifiable(
        (jsonDecode(value) as List<dynamic>).cast<int>(),
      );
    } on Object {
      return const <int>[];
    }
  }
}
