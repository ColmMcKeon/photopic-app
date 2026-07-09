import Cocoa

// Usage: swift make_icon.swift <source.png> <out_1024.png>
let args = CommandLine.arguments
guard args.count >= 3 else { fputs("usage: make_icon.swift <src> <out>\n", stderr); exit(1) }
let srcPath = args[1], outPath = args[2]

guard let src = NSImage(contentsOfFile: srcPath),
      let tiff = src.tiffRepresentation,
      let rep0 = NSBitmapImageRep(data: tiff),
      let srcCG = rep0.cgImage else { fatalError("could not load source") }

let w = srcCG.width, h = srcCG.height

// Draw source into a known RGBA8 buffer so we can scan pixels reliably.
let cs = CGColorSpaceCreateDeviceRGB()
guard let scan = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
                           bytesPerRow: w * 4, space: cs,
                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError() }
scan.draw(srcCG, in: CGRect(x: 0, y: 0, width: w, height: h))
guard let buf = scan.data else { fatalError() }
let px = buf.bindMemory(to: UInt8.self, capacity: w * h * 4)

// Content = pixel that is neither transparent nor near-white.
func isContent(_ x: Int, _ y: Int) -> Bool {
  let i = (y * w + x) * 4
  let r = Int(px[i]), g = Int(px[i+1]), b = Int(px[i+2]), a = Int(px[i+3])
  if a < 24 { return false }
  return !(r > 236 && g > 236 && b > 236)
}

var minX = w, minY = h, maxX = 0, maxY = 0
for y in 0..<h {
  for x in 0..<w where isContent(x, y) {
    if x < minX { minX = x }; if x > maxX { maxX = x }
    if y < minY { minY = y }; if y > maxY { maxY = y }
  }
}
guard maxX > minX, maxY > minY else { fatalError("no content found") }

// Square-up the crop around the detected content (keeps the icon from distorting).
let cw = maxX - minX + 1, ch = maxY - minY + 1
let side = max(cw, ch)
let cx = (minX + maxX) / 2, cy = (minY + maxY) / 2
var sx = cx - side / 2, sy = cy - side / 2
sx = max(0, min(sx, w - side)); sy = max(0, min(sy, h - side))
var cropSide = min(side, min(w - sx, h - sy))
// Shave the light bevel rim so the rounded corners sit clean on the dark square.
let inset = Int(Double(cropSide) * 0.02)
sx += inset; sy += inset; cropSide -= 2 * inset
guard let cropped = srcCG.cropping(to: CGRect(x: sx, y: sy, width: cropSide, height: cropSide)) else { fatalError("crop failed") }

fputs("content bbox: \(minX),\(minY) → \(maxX),\(maxY)  crop \(cropSide)px\n", stderr)

// Render 1024 master: transparent canvas, ~4% margin, rounded-corner clip.
let out = 1024
guard let ctx = CGContext(data: nil, width: out, height: out, bitsPerComponent: 8,
                          bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError() }
ctx.clear(CGRect(x: 0, y: 0, width: out, height: out))

let pad = CGFloat(out) * 0.04
let rect = CGRect(x: pad, y: pad, width: CGFloat(out) - 2*pad, height: CGFloat(out) - 2*pad)
let radius = rect.width * 0.2237   // Apple "squircle"-ish corner radius
let clip = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
ctx.addPath(clip); ctx.clip()
ctx.draw(cropped, in: rect)

guard let img = ctx.makeImage() else { fatalError() }
let outRep = NSBitmapImageRep(cgImage: img)
guard let png = outRep.representation(using: .png, properties: [:]) else { fatalError() }
try! png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
