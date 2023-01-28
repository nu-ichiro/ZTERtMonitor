//
//  SettingsView.swift
//  ZTERtMonitor2
//
//  Created by 中橋 一朗 on 2023/01/28.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("ZTERtHost") private var zteRtHost = "192.168.1.1"
    //@AppStorage("huaweiRtUserID") private var huaweiRtUserID = "admin"
    @AppStorage("ZTERtPassword") private var zteRtPassword = "xxxxx"

    var body: some View {
        Form {
            TextField("Host", text: $zteRtHost)
            //TextField("User ID", text: $huaweiRtUserID)
            SecureField("Password", text: $zteRtPassword)
        }
        .padding(16.0)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
