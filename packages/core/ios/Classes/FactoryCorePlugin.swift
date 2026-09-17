import Flutter
import UIKit

public class FactoryCorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "factory_core/sf_symbol",
      binaryMessenger: registrar.messenger()
    )
    let instance = FactoryCorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "render":
      handleRender(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleRender(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let name = args["name"] as? String,
      let pointSize = args["pointSize"] as? Double
    else {
      result(FlutterError(code: "bad_args", message: "Missing or malformed arguments", details: nil))
      return
    }

    let weight = Self.parseWeight(args["weight"] as? String ?? "regular")
    let tintARGB = args["tintARGB"] as? Int
    let dpr = args["devicePixelRatio"] as? Double ?? Double(UIScreen.main.scale)

    let config = UIImage.SymbolConfiguration(pointSize: CGFloat(pointSize), weight: weight)
    guard var image = UIImage(systemName: name, withConfiguration: config) else {
      result(nil)
      return
    }
    if let argb = tintARGB {
      image = image.withTintColor(Self.color(fromARGB: argb), renderingMode: .alwaysOriginal)
    }

    let renderer = UIGraphicsImageRenderer(
      size: image.size,
      format: {
        let format = UIGraphicsImageRendererFormat()
        format.scale = CGFloat(dpr)
        format.opaque = false
        return format
      }()
    )
    let data = renderer.pngData { _ in
      image.draw(in: CGRect(origin: .zero, size: image.size))
    }
    result(FlutterStandardTypedData(bytes: data))
  }

  private static func parseWeight(_ s: String) -> UIImage.SymbolWeight {
    switch s {
    case "ultraLight": return .ultraLight
    case "thin": return .thin
    case "light": return .light
    case "medium": return .medium
    case "semibold": return .semibold
    case "bold": return .bold
    case "heavy": return .heavy
    case "black": return .black
    default: return .regular
    }
  }

  private static func color(fromARGB argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xff) / 255.0
    let r = CGFloat((argb >> 16) & 0xff) / 255.0
    let g = CGFloat((argb >> 8) & 0xff) / 255.0
    let b = CGFloat(argb & 0xff) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
