//
//  FontLoader.swift
//  AlinaTest
//

import CoreText
import Foundation

enum FontLoader {

    static func loadFonts() {
        let fontFiles = [
            "GTFlexa-CnMd",
            "InstrumentSansSemiCondensed-Medium"
        ]

        for name in fontFiles {
            guard let url = Bundle.main.url(forResource: name, withExtension: "otf") else {
                print("[FontLoader] ⚠️ Missing: \(name).otf")
                continue
            }
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                if let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
                   let first = descriptors.first,
                   let psName = CTFontDescriptorCopyAttribute(first, kCTFontNameAttribute) as? String {
                    print("[FontLoader] ✅ Loaded: \(psName)")
                }
            } else {
                print("[FontLoader] ❌ Failed: \(name) – \(error?.takeRetainedValue() as Any)")
            }
        }
    }
}
