import AppKit
let size = 1024.0
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()
let g = NSGradient(colors: [NSColor(red: 0.98, green: 0.84, blue: 0.25, alpha: 1), NSColor(red: 0.96, green: 0.62, blue: 0.10, alpha: 1)])!
g.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: -60)
let s = NSAttributedString(string: "🍌", attributes: [.font: NSFont.systemFont(ofSize: 640)])
let b = s.size()
s.draw(at: NSPoint(x: (size - b.width) / 2, y: (size - b.height) / 2 + 20))
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
