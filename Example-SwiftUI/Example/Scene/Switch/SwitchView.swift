//
//  SwitchView.swift
//  Example
//
//  Created by Dung Nguyen on 1/27/21.
//

import SwiftUI

struct SwitchView: View {
    @State var isLoggedIn: Bool = false
    
    var body: some View {
        if isLoggedIn {
            TodoTabBarView()
        } else {
            LoginSignupView()
        }
    }
}

struct SwitchView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchView()
    }
}
