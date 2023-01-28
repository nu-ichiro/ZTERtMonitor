//
//  ZTEAPI.swift
//  ZTERtMonitor2
//
//  Created by NAKAHASHI Ichiro on 2023/01/28.
//

/*
 For API info, refer to the following sites:
 https://github.com/SpeckyYT/zte-cpe
 https://github.com/paulo-correia/ZTE_API_and_Hack
 http://www.bez-kabli.pl/viewtopic.php?t=62164
 */

import Foundation
import CryptoKit

private func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
    return iterator.map { String(format: "%02x", $0) }.joined()
}

enum ZTERtSessionError : Error {
    case LoginFailed
}

class ZTERtSession {
    var set_cmd, get_cmd, referer: String!

    var session: URLSession

    init() {
        session = URLSession.shared
    }

    func connect(host: String, password: String) async throws {

        set_cmd = "http://\(host)/goform/goform_set_cmd_process"
        get_cmd = "http://\(host)/goform/goform_get_cmd_process"
        referer = "http://\(host)/index.html"
        
        print("Connect: host=\(host)")
        
        var req = URLRequest(url: URL(string: get_cmd + "?isTest=false&cmd=LD")!)
        req.setValue(referer, forHTTPHeaderField: "Referer")
        let (ld_data, _) = try await URLSession.shared.data(for: req)
        let ld_json = try JSONSerialization.jsonObject(with: ld_data, options: []) as? [String: String]
        let LD = ld_json!["LD"]// as? String
        //print(LD!)
        
        let hashed_pw = hexString(SHA256.hash(data: password.data(using: .ascii)!).makeIterator()).uppercased()
        //print(hashed_pw)
        
        let token = hexString(SHA256.hash(data: (hashed_pw + LD!).data(using: .ascii)!).makeIterator()).uppercased()
        //print(token)
        
        req = URLRequest(url: URL(string: set_cmd)!)
        req.httpMethod = "POST"
        req.setValue(referer, forHTTPHeaderField: "Referer")
        let body_str = "goformId=LOGIN&isTest=false&password=\(token)"
        //debugPrint(body_str)
        req.httpBody = body_str.data(using: .utf8)
        
        let (login_data, _) = try await URLSession.shared.data(for: req)
        let login_json = try JSONSerialization.jsonObject(with: login_data, options: []) as? [String: String]
        let result = Int(login_json!["result"]!)!
        //print(result)
        
        if (result != 0) {
            print("Login failed!\n")
            throw ZTERtSessionError.LoginFailed
        }

    }

    /*
    func close() async throws {
        let requestXML = """
            <?xml version="1.0" encoding="utf-8"?>
            <request><Logout>1</Logout></request>
            """

        if csrf_token.count == 0 {
            print("CSRF token bag is empty. Session already expired?")
            return
        }
        
        var req = URLRequest(url: URL(string: "\(rt_host)api/user/logout")!)
        req.httpMethod = "POST"
        req.setValue(csrf_token[0], forHTTPHeaderField: "__RequestVerificationToken")
        req.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = requestXML.data(using: .utf8)
        
        let (_, _) = try await URLSession.shared.data(for: req)
        //debugPrint(String(data: data, encoding: .utf8))
        
        csrf_token = []
        print("Logoff")
    }

    func signalStatus() async -> (Int?, String?, String?, String?, String?) {
        var band: Int?
        var rsrq, rsrp, rssi, sinr: String?
        
        let req = URLRequest(url: URL(string: "\(rt_host)api/device/signal")!)
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let xml = XMLHash.parse(String(data:data, encoding: .utf8)!)
            if let s = xml["response"]["band"].element?.text {
                band = Int(s)
            }
            rsrq = xml["response"]["rsrq"].element?.text
            rsrp = xml["response"]["rsrp"].element?.text
            rssi = xml["response"]["rssi"].element?.text
            sinr = xml["response"]["sinr"].element?.text
        } catch {
            // retain default value
        }

        return (band, rsrq, rsrp, rssi, sinr)
    }

    func connectionStatus() async -> Int {
        var connStatus: Int = -1

        let req = URLRequest(url: URL(string: "\(rt_host)api/monitoring/status")!)
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let xml = XMLHash.parse(String(data:data, encoding: .utf8)!)
            connStatus = Int(xml["response"]["ConnectionStatus"].element!.text) ?? -1
        } catch {
            // retain default value
        }

        return connStatus
    }
     */
    
    func trafficStatus() async -> (Bool, Int?, Int?, String?, String?) {
        var loginStatus = false
        var downRate: Int?
        var upRate: Int?
        var networkType, networkProvider: String?
        
        var req = URLRequest(url: URL(string: get_cmd + "?isTest=false&multi_data=1&cmd=loginfo,realtime_rx_thrpt,realtime_tx_thrpt,network_provider,network_type")!)
        req.setValue(referer, forHTTPHeaderField: "Referer")
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            //let html = String(data: data, encoding: .utf8)
            //debugPrint(html!)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            let loginfo = json!["loginfo"]!
            loginStatus = (loginfo == "ok")
            downRate = Int(json!["realtime_rx_thrpt"]!)
            upRate = Int(json!["realtime_tx_thrpt"]!)
            networkType = json!["network_type"]
            networkProvider = json!["network_provider"]

            if (loginfo != "ok") {
                print("Forced logoff!!!!!\n")
            }

        } catch {
            // retain default value (nil?)
        }
        return (loginStatus, downRate, upRate, networkProvider, networkType)
    }
    
    /*
    func reboot() async throws {
        let requestXML = """
            <?xml version="1.0" encoding="utf-8"?>
            <request><Control>1</Control></request>
            """

        var req = URLRequest(url: URL(string: "\(rt_host)api/device/control")!)
        req.httpMethod = "POST"
        req.setValue(csrf_token[0], forHTTPHeaderField: "__RequestVerificationToken")
        req.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = requestXML.data(using: .utf8)
        
        let (_, _) = try await URLSession.shared.data(for: req)
        //debugPrint(String(data: data, encoding: .utf8))
        print("Rebooting...")
    }
     */
}
