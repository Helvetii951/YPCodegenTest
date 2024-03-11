//
//  ViewController.swift
//  YPCodegenTest
//
//  Created by Renat Galiamov on 02.03.2024.
//

import UIKit
import OpenAPIRuntime
import OpenAPIURLSession

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        makeRequests()
    }
    
    func makeRequests() {
        let client = Client(
            serverURL: try! Servers.server1(),
            transport: URLSessionTransport()
        )
        let service = NetworkService(client: client,
                                     apikey: "db79e432-d07b-4bcb-962b-5d4797702cd0")
        
        Task {
            do {
                let stations = try await service.getListOfAllStations()
                print("stations: \(stations)")
            } catch {
                print("request failed: \(error)")
            }
        }
    }
}

