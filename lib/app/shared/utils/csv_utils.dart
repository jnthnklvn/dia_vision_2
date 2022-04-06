import 'package:csv/csv.dart';

class CsvUtils {
  /// Convert a map list to csv
  String? mapListToCsv(List<Map<String, dynamic>>? mapList,
      {ListToCsvConverter? converter}) {
    if (mapList == null) {
      return null;
    }
    converter ??= const ListToCsvConverter(fieldDelimiter: ";");
    var data = <List>[];
    var keys = <String>[];
    var keyIndexMap = <String, int>{};

    // Add the key and fix previous records
    int _addKey(String key) {
      var index = keys.length;
      keyIndexMap[key] = index;
      keys.add(key);
      for (var dataRow in data) {
        dataRow.add(null);
      }
      return index;
    }

    for (var map in mapList) {
      // This list might grow if a new key is found
      List<String?> dataRow =
          List.filled(keyIndexMap.length, null, growable: false);
      // Fix missing key
      map.forEach((key, value) {
        var keyIndex = keyIndexMap[key];
        if (keyIndex == null) {
          // New key is found
          // Add it and fix previous data
          keyIndex = _addKey(key);
          // grow our list
          dataRow = List.from(dataRow, growable: true)..add(value);
        } else {
          dataRow[keyIndex] = value;
        }
      });
      data.add(dataRow);
    }
    return converter.convert(<List>[keys, ...data]);
  }
}
