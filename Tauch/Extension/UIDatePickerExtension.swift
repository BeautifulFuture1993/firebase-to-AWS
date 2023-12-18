//
//  UIDatePickerExtension.swift
//  Tauch
//
//  Created by Apple on 2022/12/06.
//

import UIKit

extension UIDatePicker {
    
    func ageLimitDate() {
        let calendar = Calendar(identifier: .gregorian)
        let nowYear = calendar.component(.year, from: Date())
        let minimumDateComponents = DateComponents(year: nowYear - 120, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        let maximumDateComponents = DateComponents(year: nowYear - 16, month: 12, day: 31, hour: 0, minute: 0, second: 0)
        let minimumDate = calendar.date(from: minimumDateComponents)
        let maximumDate = calendar.date(from: maximumDateComponents)
        self.date = maximumDate ?? Date()
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.calendar = calendar
        self.locale = Locale(identifier: "ja_JP")
        self.datePickerMode = .date
        self.preferredDatePickerStyle = .wheels
    }
}
