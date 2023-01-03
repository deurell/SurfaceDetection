//
//  ContentView.swift
//  SurfaceDetection
//
//  Created by Mikael Deurell on 2023-01-02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ARContainer()
            .ignoresSafeArea()
    }
}

struct ARContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> DetectionView {
        let arView = DetectionView(frame: .zero)
        arView.setup()
        return arView
    }
    
    func updateUIView(_ uiView: DetectionView, context: Context) { }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
