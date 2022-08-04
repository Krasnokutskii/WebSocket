//
//  ViewController.swift
//  WebSocket
//
//  Created by Yaroslav Krasnokutskiy on 4.8.22..
//

import UIKit

class ViewController: UIViewController,URLSessionWebSocketDelegate{

    private var webSocket: URLSessionWebSocketTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self")!
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }

    func ping(){
        webSocket?.sendPing { error in
            print("Ping: Some error \(error.debugDescription)")
        }
    }
    func close(){
        webSocket?.cancel(with: .goingAway, reason: "E R R R O R".data(using: .utf8))
    }
    func send(){
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.webSocket?.send(.string("some number \(Int.random(in: 0...10))"), completionHandler: { error in
                print(error.debugDescription)
            })
        }
    }
    func receive(){
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result{
            case .success(let message):
                switch message{
                case .data(let data):
                    print(data)
                case .string(let line):
                    print(line)
                @unknown default:
                    print(" unknown")
                }
            case .failure(let error):
                print(error)
            }
            
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("did open with protocol")
        ping()
        receive()
        send()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("did close with, reason")
    }
}

