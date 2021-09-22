//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Anmol on 08/04/21.
//

import Foundation

struct LoginResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String
}


