//
//  Widget_ExtensionBundle.swift
//  Widget-Extension
//
//  Created by Dylan Archer on 23/10/2024.
//

import WidgetKit
import SwiftUI

@main
struct Widget_ExtensionBundle: WidgetBundle {
    var body: some Widget {
        Widget_Extension()
        Widget_ExtensionControl()
    }
}
