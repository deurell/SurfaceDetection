//
//  PlaneAnchorEntity.swift
//  SurfaceDetection
//
//  Created by Mikael Deurell on 2023-01-02.
//

import RealityKit
import ARKit

class DetectionView: ARView, ARSessionDelegate {
    
    /// Dictionary with id from the ARPlaneAnchor as key and a PlaneAnchorEntity as value
    var planes = [UUID: PlaneAnchorEntity]()
    
    var arView: ARView { return self }
    
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
    }
    
    /// Start ARSession and setup self as delegate.
    private func setupARSession() {
        let session = self.session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        session.run(configuration)
        session.delegate = self
    }
    
    /// Anchors have been added. Add them to the dictionary and add PlaneAnchorEntities to the scene.
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let arPlaneAnchor = anchor as? ARPlaneAnchor {
                let id = arPlaneAnchor.identifier
                if planes.contains(where: {$0.key == id}) { fatalError("anchor already exists")}
                let planeAnchorEntity = PlaneAnchorEntity(arPlaneAnchor: arPlaneAnchor)
                self.scene.anchors.append(planeAnchorEntity)
                planes[id] = planeAnchorEntity
            }
        }
    }
    
    /// Anchors have been updated. call didUpdate on the planeanchor.
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                if let planeEntityAnchor = planes[planeAnchor.identifier] {
                    try? planeEntityAnchor.didUpdate(arPlaneAnchor: planeAnchor)
                } else {
                    fatalError("trying to update unexisting anchor")
                }
            }
        }
    }
    
    /// Anchors has been removed from the ARSession so remove them from our dictionary and also remove the planeanchors from the scene.
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                if let planeEntityAnchor = self.planes[planeAnchor.identifier] {
                    self.planes.removeValue(forKey: planeAnchor.identifier)
                    self.scene.anchors.remove(planeEntityAnchor)
                } else {
                    fatalError("trying to remove unexisting anchor")
                }
                
            }
        }
    }
}
