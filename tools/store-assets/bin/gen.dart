import 'dart:io';
import 'dart:math' as math;

import 'package:args/args.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Placeholder store-asset generator. Draws with the `image` package —
/// intentionally simple, no anti-aliasing sophistication, no real fonts;
/// the release agent replaces every output with polished art.
///
/// Generates six files under apps/<slug>/store/{android,ios}/:
///   - android/icon_512.png       512x512
///   - android/icon_1024.png     1024x1024
///   - android/feature.png       1024x500 (Play feature graphic)
///   - android/screenshot_1.png  1080x1920
///   - ios/icon_1024.png         1024x1024
///   - ios/screenshot_1.png      1290x2796  (iPhone 6.9" App Store size)
Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('slug', mandatory: true, help: 'App slug, e.g. wash-quote')
    ..addOption('accent', mandatory: true, help: 'Accent hex, e.g. #0a6ea8')
    ..addOption('name', mandatory: true, help: 'App display name')
    ..addOption('out', defaultsTo: 'apps',
        help: 'Root of apps/ (default: apps).')
    ..addFlag('help', abbr: 'h', negatable: false);

  final args = parser.parse(argv);
  if (args['help'] as bool) {
    stdout
      ..writeln('Usage: dart run gen --slug <slug> --accent <#hex> --name "<name>"')
      ..writeln()
      ..writeln(parser.usage);
    exit(0);
  }

  final slug = args['slug'] as String;
  final accent = _parseHex(args['accent'] as String);
  final name = args['name'] as String;
  final outRoot = args['out'] as String;

  final androidDir = Directory(p.join(outRoot, slug, 'store', 'android'))
    ..createSync(recursive: true);
  final iosDir = Directory(p.join(outRoot, slug, 'store', 'ios'))
    ..createSync(recursive: true);

  await _writePng(p.join(androidDir.path, 'icon_512.png'),
      _icon(512, accent));
  await _writePng(p.join(androidDir.path, 'icon_1024.png'),
      _icon(1024, accent));
  await _writePng(p.join(iosDir.path, 'icon_1024.png'),
      _icon(1024, accent));

  await _writePng(p.join(androidDir.path, 'feature.png'),
      _featureGraphic(accent, name));

  await _writePng(p.join(androidDir.path, 'screenshot_1.png'),
      _homeScreenshot(1080, 1920, accent, name));
  await _writePng(p.join(iosDir.path, 'screenshot_1.png'),
      _homeScreenshot(1290, 2796, accent, name));

  stdout.writeln('wrote 6 placeholder assets to apps/$slug/store/');
}

Future<void> _writePng(String path, img.Image image) async {
  await File(path).writeAsBytes(img.encodePng(image));
}

img.Color _parseHex(String hex) {
  final s = hex.replaceFirst('#', '');
  final v = int.parse(s, radix: 16);
  return img.ColorRgb8((v >> 16) & 0xff, (v >> 8) & 0xff, v & 0xff);
}

img.Color get _white => img.ColorRgb8(255, 255, 255);
img.Color get _neutralBg => img.ColorRgb8(242, 242, 247);
img.Color get _neutralText => img.ColorRgb8(60, 60, 67);
img.Color get _muted => img.ColorRgb8(142, 142, 147);

/// Icon: solid accent background with a white water-drop glyph.
img.Image _icon(int size, img.Color accent) {
  final image = img.Image(width: size, height: size);
  img.fill(image, color: accent);
  _drawWaterDrop(
    image,
    centerX: size / 2,
    centerY: size / 2 + size * 0.03,
    height: size * 0.55,
    color: _white,
  );
  return image;
}

/// Play feature graphic: accent background, small drop on left, big
/// name text right of centre.
img.Image _featureGraphic(img.Color accent, String name) {
  final image = img.Image(width: 1024, height: 500);
  img.fill(image, color: accent);
  _drawWaterDrop(
    image,
    centerX: 180,
    centerY: 250,
    height: 220,
    color: _white,
  );
  final font = img.arial48;
  final text = name;
  final approxWidth = text.length * 20; // arial48 avg ~20px/char
  img.drawString(
    image,
    text,
    font: font,
    x: 340,
    y: 250 - font.lineHeight ~/ 2,
    color: _white,
  );
  // If the name is very short, add a subtitle line.
  if (approxWidth < 340) {
    img.drawString(
      image,
      'App Factory',
      font: img.arial24,
      x: 340,
      y: 250 + font.lineHeight ~/ 2 + 4,
      color: _white,
    );
  }
  return image;
}

/// Home-screen mockup matching spec 01 §8: white background, segmented
/// Quotes/Invoices control, large accent "New quote from the driveway"
/// hero card, horizontal quote thumbnails, accepted-jobs list, bottom
/// tab bar. Coordinates scale from a reference 1080×1920 canvas.
img.Image _homeScreenshot(int width, int height, img.Color accent, String name) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: _white);

  final sx = width / 1080; // horizontal scale factor
  final sy = height / 1920;
  double x(double v) => v * sx;
  double y(double v) => v * sy;
  int xi(double v) => x(v).round();
  int yi(double v) => y(v).round();

  // Status bar backdrop (subtle grey).
  img.fillRect(image,
      x1: 0, y1: 0, x2: width, y2: yi(88).toInt(), color: _neutralBg);

  // Title "Jobs".
  img.drawString(image, 'Jobs',
      font: img.arial48, x: xi(56), y: yi(140), color: _neutralText);

  // Segmented control — rounded rect with two divisions.
  _drawRoundedRect(image,
      left: xi(56), top: yi(228), right: xi(524), bottom: yi(300),
      radius: 22, color: _neutralBg);
  // Selected half (Quotes).
  _drawRoundedRect(image,
      left: xi(64), top: yi(236), right: xi(288), bottom: yi(292),
      radius: 18, color: _white);
  img.drawString(image, 'Quotes',
      font: img.arial24, x: xi(120), y: yi(250), color: _neutralText);
  img.drawString(image, 'Invoices',
      font: img.arial24, x: xi(360), y: yi(250), color: _muted);

  // Hero accent card "New quote from the driveway".
  _drawRoundedRect(image,
      left: xi(56), top: yi(360), right: width - xi(56), bottom: yi(668),
      radius: 44, color: accent);
  // Camera-glyph disc.
  img.fillCircle(image,
      x: xi(148), y: yi(514), radius: (48 * sx).round(),
      color: img.ColorRgba8(255, 255, 255, 60));
  _drawCameraGlyph(image, cx: xi(148), cy: yi(514), size: (46 * sx).round(),
      color: _white);
  img.drawString(image, 'New quote from the driveway',
      font: img.arial48, x: xi(220), y: yi(468), color: _white);
  img.drawString(image, 'Snap the surface, pick a service, send the PDF.',
      font: img.arial24, x: xi(220), y: yi(540), color: _white);

  // "Waiting on the customer" section header.
  img.drawString(image, 'Waiting on the customer  ·  4  ·  \$1,865',
      font: img.arial24, x: xi(56), y: yi(720), color: _muted);

  // Horizontal photo-thumbnail cards.
  for (var i = 0; i < 3; i++) {
    final left = xi(56 + 320.0 * i);
    _drawRoundedRect(image,
        left: left, top: yi(770), right: left + xi(280), bottom: yi(1080),
        radius: 20, color: _neutralBg);
    // Photo placeholder.
    _drawRoundedRect(image,
        left: left + xi(16), top: yi(786),
        right: left + xi(264), bottom: yi(1000),
        radius: 12, color: img.ColorRgb8(200, 210, 220));
    // Status pill.
    _drawRoundedRect(image,
        left: left + xi(16), top: yi(1020),
        right: left + xi(150), bottom: yi(1060),
        radius: 20, color: img.ColorRgb8(220, 232, 240));
    img.drawString(image, 'Sent 2d ago',
        font: img.arial14, x: left + xi(30), y: yi(1032),
        color: _neutralText);
  }

  // "Accepted this week" list header.
  img.drawString(image, 'Accepted this week',
      font: img.arial24, x: xi(56), y: yi(1140), color: _neutralText);

  // Three list rows.
  for (var i = 0; i < 3; i++) {
    final rowY = yi(1210.0 + 100.0 * i);
    img.fillCircle(image,
        x: xi(72), y: rowY + yi(24), radius: (8 * sx).round(), color: accent);
    img.drawString(image, 'Job #${2041 + i} · driveway wash',
        font: img.arial24, x: xi(104), y: rowY, color: _neutralText);
    img.drawString(image, '\$${325 + i * 40}',
        font: img.arial24, x: width - xi(140), y: rowY, color: _neutralText);
    // Hairline.
    img.drawLine(image,
        x1: xi(56), y1: rowY + yi(70),
        x2: width - xi(56), y2: rowY + yi(70),
        color: img.ColorRgb8(230, 230, 235));
  }

  // Bottom tab bar.
  img.fillRect(image,
      x1: 0, y1: height - yi(160), x2: width, y2: height, color: _neutralBg);
  const tabs = ['Jobs', 'Customers', 'Services', 'Money'];
  for (var i = 0; i < tabs.length; i++) {
    final tabX = xi(90 + 270.0 * i);
    final selected = i == 0;
    img.drawString(image, tabs[i],
        font: img.arial24, x: tabX,
        y: height - yi(90),
        color: selected ? accent : _muted);
  }

  return image;
}

// --- primitive helpers ------------------------------------------------

void _drawRoundedRect(
  img.Image image, {
  required int left,
  required int top,
  required int right,
  required int bottom,
  required int radius,
  required img.Color color,
}) {
  // image v4 provides drawRect with radius param.
  img.fillRect(
    image,
    x1: left,
    y1: top,
    x2: right,
    y2: bottom,
    color: color,
    radius: radius,
  );
}

/// Approximated water-drop: a circle with a triangle on top.
void _drawWaterDrop(
  img.Image image, {
  required double centerX,
  required double centerY,
  required double height,
  required img.Color color,
}) {
  // Bulb radius = height * 0.35.
  final r = height * 0.35;
  // Bulb center is below the drop's overall center.
  final bulbCy = centerY + height * 0.15;
  img.fillCircle(image,
      x: centerX.round(), y: bulbCy.round(), radius: r.round(), color: color);
  // Triangle tip pointing up.
  final tipY = centerY - height / 2;
  // Sides of the triangle tangent to the bulb.
  final baseY = bulbCy - r * 0.15;
  final baseHalfW = r * 0.86;
  _fillTriangle(
    image,
    x1: centerX,
    y1: tipY,
    x2: centerX - baseHalfW,
    y2: baseY,
    x3: centerX + baseHalfW,
    y3: baseY,
    color: color,
  );
}

/// Simple scanline triangle fill — accurate enough for a placeholder.
void _fillTriangle(
  img.Image image, {
  required double x1,
  required double y1,
  required double x2,
  required double y2,
  required double x3,
  required double y3,
  required img.Color color,
}) {
  final yMin = math.min(y1, math.min(y2, y3)).floor();
  final yMax = math.max(y1, math.max(y2, y3)).ceil();
  for (var y = yMin; y <= yMax; y++) {
    final xs = <double>[];
    _edgeIntersect(y, x1, y1, x2, y2, xs);
    _edgeIntersect(y, x2, y2, x3, y3, xs);
    _edgeIntersect(y, x3, y3, x1, y1, xs);
    if (xs.length < 2) continue;
    xs.sort();
    img.drawLine(
      image,
      x1: xs.first.floor(),
      y1: y,
      x2: xs.last.ceil(),
      y2: y,
      color: color,
    );
  }
}

void _edgeIntersect(
  int y,
  double x1,
  double y1,
  double x2,
  double y2,
  List<double> xs,
) {
  if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y)) {
    xs.add(x1 + (y - y1) * (x2 - x1) / (y2 - y1));
  }
}

/// Small camera-outline glyph.
void _drawCameraGlyph(
  img.Image image, {
  required int cx,
  required int cy,
  required int size,
  required img.Color color,
}) {
  final half = size ~/ 2;
  img.fillRect(image,
      x1: cx - half, y1: cy - half ~/ 2,
      x2: cx + half, y2: cy + half,
      color: color, radius: half ~/ 4);
  img.fillCircle(image,
      x: cx, y: cy + size ~/ 8, radius: size ~/ 4, color: _white);
  img.fillCircle(image,
      x: cx, y: cy + size ~/ 8, radius: size ~/ 5, color: color);
}
