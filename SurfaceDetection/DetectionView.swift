//
//  PlaneAnchorEntity.swift
//  SurfaceDetection
//
//  Created by Mikael Deurell on 2023-01-02.
//

import RealityKit
import ARKit
import Combine

class DetectionView: ARView, ARSessionDelegate {
    var arView: ARView { return self }
    
    var anchorEntity: AnchorEntity?
    var sub: Cancellable?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func setup() {
        arView.cameraMode = .ar
        setupARSession()
        setupScene()
    }
    
    private func setupARSession() {
        let session = self.session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        session.run(configuration)
    }
    
    private func setupScene() {
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any,
                                         minimumBounds: [0.5, 0.5]))
        printAnchorState()
        
        scene.anchors.append(anchor)
        self.anchorEntity = anchor
        
        sub = arView.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self) { event in
            self.printAnchorState()
            let mesh = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            self.anchorEntity?.addChild(entity)
        }
    }
    
    private func printAnchorState() {
        print("isAnchored: \(self.anchorEntity?.isAnchored ?? false)")
    }
}
