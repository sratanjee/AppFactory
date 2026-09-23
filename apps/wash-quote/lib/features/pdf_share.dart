import 'dart:io' show File;
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes the given PDF bytes to a stable file under the app's cache
/// directory and hands it to the platform share sheet. Uses cache (not
/// documents) so old share files aren't backed up.
Future<void> sharePdf(Uint8List bytes, {required String filenameBase}) async {
  final dir = await getApplicationCacheDirectory();
  final file = File(p.join(dir.path, '$filenameBase.pdf'));
  await file.writeAsBytes(bytes, flush: true);
  final params = ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]);
  await SharePlus.instance.share(params);
}
