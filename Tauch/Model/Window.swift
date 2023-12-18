//
//  Window.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/06/03.
//

import UIKit

struct Window {
    //iOS15以降でも警告が出ないwindow
    static var first: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first
    }
}
