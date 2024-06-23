//
//  Setup.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import SwiftUI

struct Setup: View {
    @State private var instanceUrl: String = ""
    @State private var instancePassword: String = ""
    @State private var instanceEtapiToken: String = ""
    
    @FocusState private var instanceUrlFieldFocused: Bool
    @FocusState private var instancePasswordFieldFocused: Bool
    @FocusState private var instanceEtapiTokenFieldFocused: Bool
    
    @State private var useEtapiToken: Bool = false
    
    private var titleText: String = "Please setup before using"
    private var urlText: String = "INSTANCE URL"
    private var exampleURLText: String = "https://trilium.example.com"
    private var passwordText: String = "INSTANCE PASSWORD"
    private var passwordPlaceholderText: String = "Trilium instance login password"
    private var etapiPlaceholderText: String = "Generated ETAPI Token"
    private var etapiTokenBtnText: String = "ETAPI Token"
    private var passwordBtnText: String = "Password"
    private var etapiTokenText: String = "ETAPI TOKEN"
    
    func onSubmit() {
        UserDefaults.standard.set(instanceUrl, forKey: "instanceUrl")
        UserDefaults.standard.set(useEtapiToken ? instanceEtapiToken : instancePassword,
                                  forKey: useEtapiToken ? "instanceEtapiToken" : "instancePassword")
        UserDefaults.standard.set(true, forKey: "isSetupDone")
        print("Setup done")
        print("instanceUrl: \(instanceUrl)")
        print("instancePassword: \(instancePassword)")
        print("instanceEtapiToken: \(instanceEtapiToken)")
        return
    }
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            Image("IconColor")
            Text(titleText)
            Form {
                Section(header: Text(urlText)) {
                    TextField(urlText, text: $instanceUrl, prompt: Text(verbatim: exampleURLText))
                        .focused($instanceUrlFieldFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text(useEtapiToken ? etapiTokenText : passwordText),
                        footer: Text("Will be automaticly saved and using for login/authenticate to the instance")) {
                    SecureField(useEtapiToken ? etapiPlaceholderText : passwordPlaceholderText, text: useEtapiToken ? $instanceEtapiToken : $instancePassword)
                        .focused(useEtapiToken ? $instanceEtapiTokenFieldFocused : $instancePasswordFieldFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(false)
                    
                    Button {
                        useEtapiToken = !useEtapiToken
                        if(useEtapiToken) {
                            instancePassword = ""
                        } else {
                            instanceEtapiToken = ""
                        }
                    } label: {
                        Text("or use " + (useEtapiToken ? passwordBtnText : etapiTokenBtnText))
                    }
                    .buttonStyle(.borderless)
                }
                
                Button {
                    if (instanceUrl == "" || (useEtapiToken ? instanceEtapiToken : instancePassword) == "") {
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
    }
}

#Preview {
    Setup()
}
