////
////  SwiftUiViewController.swift
////  practiceConsumeAPI
////
////  Created by Adrian Garcia on 6/09/25.
////
//
//import SwiftUI
//import UIKit
//
//// Este ViewController hospedará tu interfaz SwiftUI
//class SwiftUIViewController: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Crear la vista SwiftUI
//        let swiftUIView = ContentView()
//        
//        // Crear un UIHostingController con la vista SwiftUI
//        let hostingController = UIHostingController(rootView: swiftUIView)
//        
//        // Añadir el hosting controller como child
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        
//        // Configurar constraints
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//        
//        hostingController.didMove(toParent: self)
//    }
//}
