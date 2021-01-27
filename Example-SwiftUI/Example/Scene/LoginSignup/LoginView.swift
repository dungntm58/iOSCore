//
//  LoginView.swift
//  Example
//
//  Created by Dung Nguyen on 1/27/21.
//

import SwiftUI

struct LoginView: View {
    @State var selection: Int? = nil
    
    var body: some View {
        NavigationLink(
            destination: SignupView(),
            tag: 1,
            selection: $selection) {
            Button("Sign up") {
                self.selection = 1
            }
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
