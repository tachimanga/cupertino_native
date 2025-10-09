import FlutterMacOS
import Cocoa

class CupertinoTabBarNSView: NSView {
  private let channel: FlutterMethodChannel
  private let control: NSSegmentedControl
  private var currentLabels: [String] = []
  private var currentSymbols: [String] = []
  private var currentSizes: [NSNumber] = []
  private var currentTint: NSColor? = nil
  private var currentBackground: NSColor? = nil
  private var currentBadges: [String?] = []

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeTabBar_\(viewId)", binaryMessenger: messenger)
    self.control = NSSegmentedControl(labels: [], trackingMode: .selectOne, target: nil, action: nil)

    var labels: [String] = []
    var symbols: [String] = []
    var sizes: [NSNumber] = []
    var selectedIndex: Int = 0
    var isDark: Bool = false
    var tint: NSColor? = nil
    var bg: NSColor? = nil

    if let dict = args as? [String: Any] {
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      sizes = (dict["sfSymbolSizes"] as? [NSNumber]) ?? []
      if let v = dict["selectedIndex"] as? NSNumber { selectedIndex = v.intValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any] {
        if let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
        if let n = style["backgroundColor"] as? NSNumber { bg = Self.colorFromARGB(n.intValue) }
      }
      if let b = dict["badges"] as? [Any] {
        currentBadges = b.map { v in
          if v is NSNull { return nil }
          return (v as? String)
        }
      }
    }

    super.init(frame: .zero)

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    configureSegments(labels: labels, symbols: symbols, sizes: sizes)
    if selectedIndex >= 0 { control.selectedSegment = selectedIndex }
    // Save current style and content for retinting
    self.currentLabels = labels
    self.currentSymbols = symbols
    self.currentSizes = sizes
    self.currentTint = tint
    self.currentBackground = bg
    if let b = bg { wantsLayer = true; layer?.backgroundColor = b.cgColor }
    applySegmentTint()
    applyBadges()

    control.target = self
    control.action = #selector(onChanged(_:))

    addSubview(control)
    control.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      control.leadingAnchor.constraint(equalTo: leadingAnchor),
      control.trailingAnchor.constraint(equalTo: trailingAnchor),
      control.topAnchor.constraint(equalTo: topAnchor),
      control.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.control.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setSelectedIndex":
        if let args = call.arguments as? [String: Any], let idx = (args["index"] as? NSNumber)?.intValue {
          self.control.selectedSegment = idx
          self.applySegmentTint()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing index", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber { self.currentTint = Self.colorFromARGB(n.intValue) }
          if let n = args["backgroundColor"] as? NSNumber {
            let c = Self.colorFromARGB(n.intValue)
            self.currentBackground = c
            self.wantsLayer = true
            self.layer?.backgroundColor = c.cgColor
          }
          self.applySegmentTint()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setItems":
        if let args = call.arguments as? [String: Any] {
          let labels = (args["labels"] as? [String]) ?? []
          let symbols = (args["sfSymbols"] as? [String]) ?? []
          self.currentLabels = labels
          self.currentSymbols = symbols
          if let b = args["badges"] as? [Any] {
            self.currentBadges = b.map { v in
              if v is NSNull { return nil }
              return (v as? String)
            }
          }
          self.configureSegments(labels: labels, symbols: symbols, sizes: self.currentSizes)
          self.applySegmentTint()
          self.applyBadges()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing items", details: nil)) }
      case "setBadges":
        if let args = call.arguments as? [String: Any], let b = args["badges"] as? [Any] {
          self.currentBadges = b.map { v in
            if v is NSNull { return nil }
            return (v as? String)
          }
          self.applyBadges()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing badges", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  private func configureSegments(labels: [String], symbols: [String], sizes: [NSNumber]) {
    let count = max(labels.count, symbols.count)
    control.segmentCount = count
    for i in 0..<count {
      if i < symbols.count, #available(macOS 11.0, *), var image = NSImage(systemSymbolName: symbols[i], accessibilityDescription: nil) {
        if i < sizes.count, #available(macOS 12.0, *) {
          let size = CGFloat(truncating: sizes[i])
          let cfg = NSImage.SymbolConfiguration(pointSize: size, weight: .regular)
          image = image.withSymbolConfiguration(cfg) ?? image
        }
        control.setImage(image, forSegment: i)
      } else if i < labels.count {
        control.setLabel(labels[i], forSegment: i)
      } else {
        control.setLabel("", forSegment: i)
      }
    }
  }

  private func applySegmentTint() {
    let count = control.segmentCount
    guard count > 0 else { return }
    let sel = control.selectedSegment
    for i in 0..<count {
      // Only retint symbol-based segments
      if let name = (i < currentSymbols.count ? currentSymbols[i] : nil), !name.isEmpty,
         var image = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
        if i < currentSizes.count, #available(macOS 12.0, *) {
          let size = CGFloat(truncating: currentSizes[i])
          let cfg = NSImage.SymbolConfiguration(pointSize: size, weight: .regular)
          image = image.withSymbolConfiguration(cfg) ?? image
        }
        if i == sel, let tint = currentTint {
          if #available(macOS 12.0, *) {
            let cfg = NSImage.SymbolConfiguration(hierarchicalColor: tint)
            image = image.withSymbolConfiguration(cfg) ?? image
          } else {
            image = image.tinted(with: tint)
          }
        }
        control.setImage(image, forSegment: i)
      }
    }
  }

  private func applyBadges() {
    let count = max(currentLabels.count, currentSymbols.count)
    guard count > 0 else { return }
    // Ensure array sized
    if currentBadges.count < count {
      currentBadges += Array(repeating: nil, count: count - currentBadges.count)
    }
    for i in 0..<count {
      let base = (i < currentLabels.count ? currentLabels[i] : "")
      let badge = (i < currentBadges.count ? currentBadges[i] : nil)
      if let b = badge, !b.isEmpty {
        let composed = base.isEmpty ? b : "\(base) (\(b))"
        control.setLabel(composed, forSegment: i)
      } else {
        // Restore base label if any; leave image intact
        if !base.isEmpty {
          control.setLabel(base, forSegment: i)
        } else {
          control.setLabel("", forSegment: i)
        }
      }
    }
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }

  @objc private func onChanged(_ sender: NSSegmentedControl) {
    channel.invokeMethod("valueChanged", arguments: ["index": sender.selectedSegment])
  }
}

private extension NSImage {
  func tinted(with color: NSColor) -> NSImage {
    let img = NSImage(size: size)
    img.lockFocus()
    let rect = NSRect(origin: .zero, size: size)
    color.set()
    rect.fill()
    draw(in: rect, from: .zero, operation: .destinationIn, fraction: 1.0)
    img.unlockFocus()
    return img
  }
}
