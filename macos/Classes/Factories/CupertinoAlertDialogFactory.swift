import FlutterMacOS
import Cocoa

class CupertinoAlertDialogViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: NSRect, viewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
    return CupertinoAlertDialogNSView(viewId: viewId, args: args, messenger: messenger)
  }
}