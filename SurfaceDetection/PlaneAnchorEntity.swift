//
//  PlaneAnchorEntity.swift
//  SurfaceDetection
//
//  Created by Mikael Deurell on 2023-01-02.
//

import RealityKit
import ARKit

class PlaneAnchorEntity: Entity, HasModel, HasAnchoring {
    
    @available(*, unavailable)
    required init() {
        fatalError("Not available")
    }
    
    /// Initialize the AnchorEntity. Model is provided using a ModelComponent while HasAnchoring is implemented by updating transform and mesh directly from ARSession.
    /// Adjust position to center of plane and rotate on Y with provided angle from the Anchor planeExtent.
    init(arPlaneAnchor: ARPlaneAnchor) {
        super.init()
        self.components.set(createModelComponent(arPlaneAnchor))
        self.transform.matrix = arPlaneAnchor.transform
        self.position += arPlaneAnchor.center
        self.orientation = simd_quatf(angle: arPlaneAnchor.planeExtent.rotationOnYAxis, axis: [0,1,0])
    }
    
    /// Create a model compontent with a planemesh using the size of the provided ARPlaneAnchor.
    private func createModelComponent(_ arPlaneAnchor: ARPlaneAnchor) -> ModelComponent {
        let mesh = MeshResource.generatePlane(width: arPlaneAnchor.planeExtent.width, depth: arPlaneAnchor.planeExtent.height)
        let material = UnlitMaterial(color: .lightGray.withAlphaComponent(0.5))
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        return modelComponent
    }
    
    /// Called when the ARsession has updated the anchor. Update the transform and the mesh with provided transform/size.
    /// Adjust position to center of plane and rotate on Y with provided angle from the Anchor planeExtent.
    func didUpdate(arPlaneAnchor: ARPlaneAnchor) throws {
        let updatedMesh = MeshResource.generatePlane(width: arPlaneAnchor.planeExtent.width, depth: arPlaneAnchor.planeExtent.height)
        self.model?.mesh = updatedMesh
        
        let translation = arPlaneAnchor.center
        let positionTransform = simd_float4x4(translation: translation)
        let rotationAngle = arPlaneAnchor.planeExtent.rotationOnYAxis
        let orientationTransform = float4x4(simd_quatf(angle: rotationAngle, axis: [0,1,0]))
        self.transform.matrix = simd_mul(arPlaneAnchor.transform, simd_mul(positionTransform, orientationTransform))
    }
}
