//
//  QRCodeGenerator.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 13.12.25.
//

import Foundation
import AppKit
import CoreImage
import CoreGraphics
import os

/// Abstraction over QR code generations
protocol QRCodeGeneratorProtocol {
    /// Generates a QR code from text.
    /// - Parameters:
    ///   - text: The text the QR code should hold.
    ///   - size: The size of the QR code.
    /// - Returns: The image of the QR code.
    func generateQRCode(from text: String, size: CGFloat) -> NSImage?
    
    /// Generates a PDF file with QR code and a title.
    /// - Parameters:
    ///   - text: The text the QR code should hold.
    ///   - title: The tile of the PDF file.
    ///   - pageSize: The page size of the PDF file.
    ///   - qrSize: The size of the QR code.
    /// - Returns: The data of the PDF file.
    func generatePDF(text: String, title: String, pageSize: CGSize, qrSize: CGFloat) -> Data?
}


/// Default implementation of `QRCodeGeneratorProtocol`.
final class QRCodeGenerator: QRCodeGeneratorProtocol {
    let context: CIContext
    
    /// Default initializer.
    init() {
        self.context = CIContext()
    }
}

extension QRCodeGenerator {
    func generateQRCode(from text: String, size: CGFloat) -> NSImage? {
        guard let data = text.data(using: .utf8) else {
            LoggerConfig.shared.logCore(level: .error, "Error creating data from text \(text)")
            return nil
        }

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            LoggerConfig.shared.logCore(level: .error, "CIQRCodeGenerator filter not available")
            return nil
        }
        filter.setValue(data as NSData, forKey: "inputMessage")
        filter.setValue("M" as NSString, forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else {
            LoggerConfig.shared.logCore(level: .error, "Failed to generate QR CIImage")
            return nil
        }

        let extent = outputImage.extent.integral
        let scaleX = size / extent.width
        let scaleY = size / extent.height
        let scale = max(scaleX, scaleY)
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))


        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent, format: .L8, colorSpace: colorSpace, deferred: false) else {
            LoggerConfig.shared.logCore(level: .error, "Failed to create CGImage from QR CIImage")
            return nil
        }

        let finalSize = NSSize(width: size, height: size)
        let nsImage = NSImage(size: finalSize)
        nsImage.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .none
        NSImage(cgImage: cgImage, size: scaledImage.extent.size).draw(in: NSRect(origin: .zero, size: finalSize))
        nsImage.unlockFocus()
        return nsImage
    }
    
    func generatePDF(text: String, title: String, pageSize: CGSize = CGSize(width: 595, height: 842), qrSize: CGFloat = 256) -> Data? {
        // Create QR image
        guard let qrImage = generateQRCode(from: text, size: qrSize) else {
            LoggerConfig.shared.logCore(level: .error, "Failed to generate QR image for PDF")
            return nil
        }

        // Prepare a mutable data buffer for the PDF
        let mutableData = NSMutableData()
        guard let consumer = CGDataConsumer(data: mutableData as CFMutableData) else {
            LoggerConfig.shared.logCore(level: .error, "Failed to create CGDataConsumer for PDF")
            return nil
        }

        // PDF metadata (title)
        let pdfInfo: [CFString: Any] = [
            kCGPDFContextTitle: title,
            kCGPDFContextCreator: "AdminPanel"
        ]

        var mediaBox = CGRect(origin: .zero, size: pageSize)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, pdfInfo as CFDictionary) else {
            LoggerConfig.shared.logCore(level: .error, "Failed to create PDF context")
            return nil
        }

        // Begin a page
        pdfContext.beginPDFPage(nil as CFDictionary?)

        // Flip the context to macOS coordinate system for drawing text/images easily
        pdfContext.saveGState()
        pdfContext.translateBy(x: 0, y: pageSize.height)
        pdfContext.scaleBy(x: 1, y: -1)

        // Margins and layout
        let margin: CGFloat = 40
        let titleFont = NSFont.systemFont(ofSize: 24, weight: .semibold)

        // Draw title using Core Text via NSAttributedString -> draw in flipped context
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let titleAttr = NSAttributedString(
            string: title,
            attributes: [
                .font: titleFont,
                .foregroundColor: NSColor.black,
                .paragraphStyle: paragraph
            ]
        )

        // Title rect at top
        let titleHeight = titleAttr.size().height
        let titleRect = CGRect(x: margin, y: margin, width: pageSize.width - margin * 2, height: titleHeight)
        // Because context is flipped, drawing at y: margin places it near the top after the flip above
        // Use NSGraphicsContext to draw attributed string into current context
        NSGraphicsContext.saveGraphicsState()
        let nsCtx = NSGraphicsContext(cgContext: pdfContext, flipped: true)
        NSGraphicsContext.current = nsCtx
        titleAttr.draw(in: titleRect)
        NSGraphicsContext.current = nil
        NSGraphicsContext.restoreGraphicsState()

        // Draw QR code centered below the title
        let qrOriginY = margin + titleHeight + 24
        let qrRect = CGRect(
            x: (pageSize.width - qrSize) / 2.0,
            y: qrOriginY,
            width: qrSize,
            height: qrSize
        )

        if let cgImage = qrImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            pdfContext.interpolationQuality = CGInterpolationQuality.none
            pdfContext.draw(cgImage, in: qrRect)
        } else {
            // Fallback: draw via NSImage into context if cgImage unavailable
            NSGraphicsContext.saveGraphicsState()
            let nsCtx = NSGraphicsContext(cgContext: pdfContext, flipped: true)
            NSGraphicsContext.current = nsCtx
            qrImage.draw(in: qrRect)
            NSGraphicsContext.current = nil
            NSGraphicsContext.restoreGraphicsState()
        }

        // Restore and end page
        pdfContext.restoreGState()
        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return mutableData as Data
    }
}

