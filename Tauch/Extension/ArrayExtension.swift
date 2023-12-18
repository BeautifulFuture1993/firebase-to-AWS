//
//  ArrayExtension.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/12.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        //indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        return indices.contains(index) ? self[index] : nil
    }
    func safeRange(range: Range<Int>) -> ArraySlice<Element> {
        return self.dropFirst(range.startIndex).prefix(range.endIndex)
    }
}
