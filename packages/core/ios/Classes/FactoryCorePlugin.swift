import Flutter
import UIKit
import WidgetKit

public class FactoryCorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let symbolChannel = FlutterMethodChannel(
      name: "factory_core/sf_symbol",
      binaryMessenger: registrar.messenger()
    )
    let bridgeChannel = FlutterMethodChannel(
      name: "factory_core/widget_bridge",
      binaryMessenger: registrar.messenger()
    )
    let instance = FactoryCorePlugin()
    registrar.addMethodCallDelegate(instance, channel: symbolChannel)
    registrar.addMethodCallDelegate(instance, channel: bridgeChannel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "render":
      handleRender(call, result: result)
    case "publish":
      handlePublish(call, result: result)
    case "read":
      handleRead(call, result: result)
    case "clear":
      handleClear(call, result: result)
    case "reloadAllWidgets":
      handleReload(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - SF Symbol rendering

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

  // MARK: - Widget bridge

  private func handlePublish(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let suiteName = args["suiteName"] as? String,
      let payload = args["payload"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "Missing suiteName or payload", details: nil))
      return
    }
    let defaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    defaults.set(payload, forKey: "payload")
    reloadTimelines()
    result(nil)
  }

  private func handleRead(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let suiteName = args["suiteName"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "Missing suiteName", details: nil))
      return
    }
    let defaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    result(defaults.string(forKey: "payload"))
  }

  private func handleClear(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let suiteName = args["suiteName"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "Missing suiteName", details: nil))
      return
    }
    let defaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    defaults.removeObject(forKey: "payload")
    reloadTimelines()
    result(nil)
  }

  private func handleReload(result: @escaping FlutterResult) {
    reloadTimelines()
    result(nil)
  }

  private func reloadTimelines() {
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }

  // MARK: - Helpers

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
