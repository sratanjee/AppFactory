import 'dart:io' show Directory, File, Platform;

import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wash_quote/l10n/app_strings.dart';

/// Opens the platform camera and copies the captured file into the app's
/// documents directory (permanent, backed up per PLAN §4). Returns the
/// stored path or `null` if the user cancels or denies permission.
///
/// The permission dialog itself is shown by iOS/Android on first use of
/// `ImageSource.camera`; we surface a one-line rationale first so the user
/// sees why the app is asking (DESIGN_GUIDE §3).
Future<String?> capturePhotoFromCamera(BuildContext context) async {
  final proceed = await _showRationale(context);
  if (!proceed) return null;
  if (!context.mounted) return null;

  final picker = ImagePicker();
  try {
    final file = Platform.isIOS || Platform.isAndroid
        ? await picker.pickImage(source: ImageSource.camera, imageQuality: 88)
        : await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return await _persist(file);
  } on Object {
    return null;
  }
}

Future<bool> _showRationale(BuildContext context) async {
  final result = await AdaptiveDialog.confirm<bool>(
    context,
    title: AppStrings.cameraRationale,
    actions: const [
      AdaptiveDialogAction(
        label: AppStrings.notLater,
        value: false,
        isCancel: true,
      ),
      AdaptiveDialogAction(
        label: AppStrings.cameraAllow,
        value: true,
      ),
    ],
  );
  return result == true;
}

Future<String> _persist(XFile file) async {
  final dir = await getApplicationDocumentsDirectory();
  final photosDir = Directory(p.join(dir.path, 'photos'));
  if (!photosDir.existsSync()) {
    photosDir.createSync(recursive: true);
  }
  final ext = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
  final name = 'photo_${DateTime.now().millisecondsSinceEpoch}$ext';
  final target = File(p.join(photosDir.path, name));
  await File(file.path).copy(target.path);
  return target.path;
}
