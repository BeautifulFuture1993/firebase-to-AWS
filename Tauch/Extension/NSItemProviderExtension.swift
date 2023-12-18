//
//  NSItemProviderExtension.swift
//  Tauch
//
//  Created by Apple on 2023/08/20.
//

import Foundation

extension NSItemProvider {
    func loadObject(ofClass aClass : NSItemProviderReading.Type) async throws -> NSItemProviderReading {
        try await withCheckedThrowingContinuation { continuation in
            // print("will start loading object")
            self.loadObject(ofClass: aClass) { item, error in
                // print("did start loading object")
                if let error {
                    // print("end loading object")
                    return continuation.resume(throwing: error)
                }
                guard let item else {
                    // print("end loading object")
                    return continuation.resume(throwing: NSError())
                }
                // print("end loading object")
                continuation.resume(returning: item)
            }
        }
    }
}
