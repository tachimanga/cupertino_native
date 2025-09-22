import FlutterMacOS
import Cocoa

class CupertinoAlertDialogNSView: NSView {
  private let channel: FlutterMethodChannel
  private var alert: NSAlert?
  private var alertStyle: String = "glass"
  
  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeAlertDialog_\(viewId)", binaryMessenger: messenger)
    
    var title: String = ""
    var message: String? = nil
    var actionTitles: [String] = []
    var actionStyles: [String] = []
    var actionEnabled: [Bool] = []
    var iconName: String? = nil
    var iconSize: CGFloat? = nil
    var iconColor: NSColor? = nil
    var iconMode: String? = nil
    var iconPalette: [NSColor] = []
    var iconGradient: Bool = false
    var isDark: Bool = false
    var tint: NSColor? = nil
    var alertStyleParam: String = "glass"
    
    if let dict = args as? [String: Any] {
      if let t = dict["title"] as? String { title = t }
      if let m = dict["message"] as? String { message = m }
      if let at = dict["actionTitles"] as? [String] { actionTitles = at }
      if let ast = dict["actionStyles"] as? [String] { actionStyles = ast }
      if let ae = dict["actionEnabled"] as? [Bool] { actionEnabled = ae }
      if let iconNameValue = dict["iconName"] as? String { iconName = iconNameValue }
      if let iconSizeValue = dict["iconSize"] as? NSNumber { iconSize = CGFloat(truncating: iconSizeValue) }
      if let ic = dict["iconColor"] as? NSNumber { iconColor = Self.colorFromARGB(ic.intValue) }
      if let im = dict["iconRenderingMode"] as? String { iconMode = im }
      if let ip = dict["iconPaletteColors"] as? [NSNumber] { 
        iconPalette = ip.map { Self.colorFromARGB($0.intValue) }
      }
      if let ig = dict["iconGradientEnabled"] as? Bool { iconGradient = ig }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { 
        tint = Self.colorFromARGB(n.intValue) 
      }
      if let alertStyleValue = dict["alertStyle"] as? String { alertStyleParam = alertStyleValue }
    }
    
    self.alertStyle = alertStyleParam
    
    super.init(frame: .zero)
    
    setupAlert(title: title, message: message, actionTitles: actionTitles, 
               actionStyles: actionStyles, actionEnabled: actionEnabled,
               iconName: iconName, iconSize: iconSize, iconColor: iconColor,
               iconMode: iconMode, iconPalette: iconPalette, iconGradient: iconGradient,
               isDark: isDark, tint: tint)
    
    self.channel.setMethodCallHandler(onMethodCall)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupAlert(title: String, message: String?, actionTitles: [String],
                         actionStyles: [String], actionEnabled: [Bool],
                         iconName: String?, iconSize: CGFloat?, iconColor: NSColor?,
                         iconMode: String?, iconPalette: [NSColor], iconGradient: Bool,
                         isDark: Bool, tint: NSColor?) {
    
    alert = NSAlert()
    guard let alert = alert else { return }
    
    // Set title and message
    alert.messageText = title
    if let message = message {
      alert.informativeText = message
    }
    
    // Apply liquid glass styling for macOS (macOS 13+)
    if #available(macOS 13.0, *) {
      switch alertStyle {
      case "glass", "prominentGlass":
        // Apply modern glass effect with macOS-appropriate corner radius
        alert.window.titlebarAppearsTransparent = true
        alert.window.backgroundColor = NSColor.clear
        
        // macOS alerts typically use 8pt corner radius
        if let contentView = alert.window.contentView {
          contentView.wantsLayer = true
          contentView.layer?.cornerRadius = 8.0
          contentView.layer?.masksToBounds = true
        }
        
        // Add visual effect view for glass effect
        let effectView = NSVisualEffectView()
        // Use more appropriate materials for alert dialogs
        effectView.material = isDark ? .menu : .popover
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = 8.0
        effectView.layer?.masksToBounds = true
        
        if let contentView = alert.window.contentView {
          effectView.frame = contentView.bounds
          effectView.autoresizingMask = [.width, .height]
          contentView.addSubview(effectView, positioned: .below, relativeTo: nil)
        }
        
        // Apply tint color
        if let tintColor = tint {
          alert.window.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        }
        
      default:
        break
      }
    }
    
    // Add icon if provided
    if let iconName = iconName {
      var finalImage: NSImage?
      
      // Try SF Symbol first (macOS 11+)
      if #available(macOS 11.0, *) {
        finalImage = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
        
        // Apply size if provided
        if let size = iconSize, let image = finalImage {
          let config = NSImage.SymbolConfiguration(pointSize: size, weight: .regular)
          finalImage = image.withSymbolConfiguration(config)
        }
        
        // Apply color and rendering mode
        if let color = iconColor, let image = finalImage {
          let coloredImage = NSImage(size: image.size)
          coloredImage.lockFocus()
          color.set()
          image.draw(in: NSRect(origin: .zero, size: image.size))
          coloredImage.unlockFocus()
          finalImage = coloredImage
        }
        
        // Apply rendering modes for SF Symbols
        if let mode = iconMode, let image = finalImage {
          switch mode {
          case "hierarchical":
            if #available(macOS 12.0, *) {
              let config = NSImage.SymbolConfiguration(hierarchicalColor: iconColor ?? .labelColor)
              finalImage = image.withSymbolConfiguration(config)
            }
          case "palette":
            if #available(macOS 12.0, *), !iconPalette.isEmpty {
              let config = NSImage.SymbolConfiguration(paletteColors: iconPalette)
              finalImage = image.withSymbolConfiguration(config)
            }
          case "multicolor":
            if #available(macOS 12.0, *) {
              let config = NSImage.SymbolConfiguration.preferringMulticolor()
              finalImage = image.withSymbolConfiguration(config)
            }
          default:
            break
          }
        }
      }
      
      if let image = finalImage {
        alert.icon = image
      }
    }
    
    // Add action buttons
    for (index, actionTitle) in actionTitles.enumerated() {
      let style = index < actionStyles.count ? actionStyles[index] : "defaultAction"
      let enabled = index < actionEnabled.count ? actionEnabled[index] : true
      
      let button = alert.addButton(withTitle: actionTitle)
      button.isEnabled = enabled && style != "disabled"
      
      // Detect dark mode
      let isDarkMode = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
      
      // Set button style based on action style
      switch style {
      case "cancel":
        button.keyEquivalent = "\u{1b}" // Escape key
        if #available(macOS 11.0, *) {
          button.bezelStyle = .rounded
          button.contentTintColor = .white
          // Set red background for cancel buttons
          button.layer?.backgroundColor = NSColor.systemRed.cgColor
          button.layer?.cornerRadius = 6
        }
      case "destructive":
        if #available(macOS 11.0, *) {
          button.hasDestructiveAction = true
          button.bezelStyle = .rounded
          button.contentTintColor = .white
          // Set red background for destructive buttons
          button.layer?.backgroundColor = NSColor.systemRed.cgColor
          button.layer?.cornerRadius = 6
        }
      case "primary":
        if #available(macOS 11.0, *) {
          button.bezelStyle = .rounded
          button.contentTintColor = .white
          // Set blue background for primary buttons
          button.layer?.backgroundColor = NSColor.systemBlue.cgColor
          button.layer?.cornerRadius = 6
        }
        button.keyEquivalent = "\r" // Return key for primary action
      case "secondary":
        if #available(macOS 11.0, *) {
          button.bezelStyle = .roundRect
          button.contentTintColor = isDarkMode ? .secondaryLabelColor.withAlphaComponent(0.8) : .secondaryLabelColor
        }
      case "success":
        if #available(macOS 11.0, *) {
          button.bezelStyle = .rounded
          button.contentTintColor = isDarkMode ? .systemGreen.withAlphaComponent(0.9) : .systemGreen
        }
      case "warning":
        if #available(macOS 11.0, *) {
          button.bezelStyle = .rounded
          button.contentTintColor = isDarkMode ? .systemOrange.withAlphaComponent(0.9) : .systemOrange
        }
      case "info":
        if #available(macOS 11.0, *) {
          button.bezelStyle = .rounded
          button.contentTintColor = isDarkMode ? .systemBlue.withAlphaComponent(0.8) : .systemBlue
        }
      case "disabled":
        button.isEnabled = false
        if #available(macOS 11.0, *) {
          button.contentTintColor = isDarkMode ? .tertiaryLabelColor.withAlphaComponent(0.6) : .tertiaryLabelColor
        }
      case "defaultAction":
        if index == 0 {
          button.keyEquivalent = "\r" // Return key for first action
        }
      default:
        break
      }
      
      // Apply button styling for glass effect
      if alertStyle == "glass" || alertStyle == "prominentGlass" {
        if #available(macOS 11.0, *) {
          button.bezelStyle = .rounded
        }
      }
    }
    
    // Show the alert
    DispatchQueue.main.async { [weak self] in
      if let window = NSApp.mainWindow ?? NSApp.keyWindow {
        alert.beginSheetModal(for: window) { response in
          let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
          self?.channel.invokeMethod("actionPressed", arguments: ["index": buttonIndex])
        }
      } else {
        // No window available, run as app modal
        let response = alert.runModal()
        let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
        self?.channel.invokeMethod("actionPressed", arguments: ["index": buttonIndex])
      }
    }
  }
  
  private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setBrightness":
      if let args = call.arguments as? [String: Any],
         let isDark = args["isDark"] as? Bool {
        updateBrightness(isDark: isDark)
      }
      result(nil)
      
    case "setStyle":
      if let args = call.arguments as? [String: Any],
         let tint = args["tint"] as? NSNumber {
        updateStyle(tint: Self.colorFromARGB(tint.intValue))
      }
      result(nil)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func updateBrightness(isDark: Bool) {
    guard let alert = alert else { return }
    
    if #available(macOS 13.0, *) {
      if alertStyle == "glass" || alertStyle == "prominentGlass" {
        // Update appearance
        alert.window.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        
        // Update visual effect view material
        if let contentView = alert.window.contentView {
          for subview in contentView.subviews {
            if let effectView = subview as? NSVisualEffectView {
              effectView.material = isDark ? .menu : .popover
              break
            }
          }
        }
      }
    }
  }
  
  private func updateStyle(tint: NSColor) {
    guard let alert = alert else { return }
    
    // Update button tint colors
    for button in alert.buttons {
      if #available(macOS 10.14, *) {
        button.contentTintColor = tint
      }
    }
  }
  
  static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(red: r, green: g, blue: b, alpha: a)
  }
}