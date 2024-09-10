//
//  Extentions.swift
//  Mobily
//
//  Created by Mohamed Ragab on 06/09/2024.
//

import Foundation
import SwiftUI


enum ColorsEnum : String {
    case Bg     = "bg"
    case Main   = "main"
    case Second = "second"
    
    var color: Color {
            return Color(self.rawValue)
        }
}



enum FontsEnum : String {
    case Bold     = "LamaSans-Bold"
    case Medium   = "LamaSans-Medium"
    case Regular  = "LamaSans-Regular"
    
    var font: String {
           return String(self.rawValue) // You can adjust the size as needed
       }
}


extension Notification.Name {
    static let oauthRedirectReceived = Notification.Name("oauthRedirectReceived")
}
