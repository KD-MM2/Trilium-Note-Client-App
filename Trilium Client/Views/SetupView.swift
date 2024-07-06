//
//  SetupView.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import Alamofire
import SwiftUI

struct SetupView: View {
    @AppStorage("isSetupDone") private var isSetupDone: Bool = false
    @AppStorage("instanceUrl") private var instanceUrl: String = ""
    @AppStorage("instanceEtapiToken") private var instanceEtapiToken: String = ""
    @AppStorage("instancePassword") private var instancePassword: String = ""
    
    @FocusState private var instanceUrlFieldFocused: Bool
    @FocusState private var instancePasswordFieldFocused: Bool
    @FocusState private var instanceEtapiTokenFieldFocused: Bool
    
    @AppStorage("useEtapiToken") private var useEtapiToken: Bool = false
    
    @State var showAlert: Bool = false
    
    func onSubmit() {
        isSetupDone = true
        Router.shared.path.append(.Home)
    }
    
    var body: some View {
        VStack {
            Image("IconColor")
            Text("Please setup before using")
            Form {
                Section(header: Text("INSTANCE URL")) {
                    TextField("INSTANCE URL", text: $instanceUrl, prompt: Text(verbatim: "https://trilium.example.com"))
                        .focused($instanceUrlFieldFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text(useEtapiToken ? "ETAPI TOKEN" : "INSTANCE PASSWORD"),
                        footer: Text("Will be automaticly saved and using for login/authenticate to the instance"))
                {
                    // TODO: if token not exist, use password to login and set token
                    SecureField(useEtapiToken ? "Generated ETAPI Token" : "Login Password", text: useEtapiToken ? $instanceEtapiToken : $instancePassword)
                        .focused(useEtapiToken ? $instanceEtapiTokenFieldFocused : $instancePasswordFieldFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(false)
                    
                    Button {
                        useEtapiToken = !useEtapiToken
                        if useEtapiToken {
                            instancePassword = ""
                        } else {
                            instanceEtapiToken = ""
                        }
                    } label: {
                        Text("or use " + (useEtapiToken ? "INSTANCE PASSWORD" : "ETAPI TOKEN"))
                    }
                    .buttonStyle(.borderless)
                }
                
                Button {
                    if instanceUrl == "" || (useEtapiToken ? instanceEtapiToken : instancePassword) == "" {
                        showAlert.toggle()
                    } else {
                        onSubmit()
                    }
                } label: {
                    Text("Signin")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .scrollDisabled(true)
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Error"), message: Text("Please fill all fields"))
            })
        }
        .toolbar(.hidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    SetupView()
}
