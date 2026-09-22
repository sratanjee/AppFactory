import 'dart:io';
import 'dart:typed_data';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
      responseDataCallback: (data) async {
        if (data == null) return;

        // Screenshots are stored under data['screenshots'] as a list of maps
        // with 'screenshotName' and 'bytes' keys.
        final screenshots = data['screenshots'];
        if (screenshots == null) {
          print('No screenshots found in response data.');
          return;
        }

        final list = screenshots as List<dynamic>;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          final name = map['screenshotName'] as String? ?? 'screenshot';
          final rawBytes = map['bytes'] as List<dynamic>;

          // Convert to Uint8List.
          final bytes = Uint8List.fromList(rawBytes.cast<int>());

          final file = File('screenshots/$name.png');
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(bytes);
          print('screenshot saved: ${file.path} (${bytes.length} bytes)');
        }
      },
    );
