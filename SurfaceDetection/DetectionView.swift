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
    var fish: Entity?
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
        arView.environment.lighting.intensityExponent = 2.0
        scene.anchors.append(anchor)
        self.anchorEntity = anchor
        
        sub = arView.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self) {event in
            guard let anchorEntity = self.anchorEntity else { fatalError() }
            guard let fishEntity = try? Entity.load(named: "fish_sardine") else { fatalError() }
            self.printAnchorState()
            
            fishEntity.position = Constants.fishStartPosition
            anchorEntity.transform.scale = simd_float3(repeating: Constants.scale)
            self.fish = fishEntity
            anchorEntity.addChild(fishEntity)
            self.anchorEntity?.addChild(fishEntity)
            
            self.setupGestureRecognizers()
        }
    }
    
    private func setupGestureRecognizers() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            if let fish = self.fish {
                guard let animationFromUsdz = fish.availableAnimations.first,
                      let bezierAnimationResource = AnimationResource.quadracticBezierAnimation(start: Constants.fishStartPosition / Constants.scale,
                                                                                                control: [0, 0.4, 0] / Constants.scale,
                                                                                                end: Constants.fishEndPosition / Constants.scale,
                                                                                                step: 0.025,
                                                                                                speed: 4.7,
                                                                                                timingFunction: AnimationResource.quadraticEaseInOut),
                      
                        let animationGroup = try? AnimationResource.group(with: [animationFromUsdz, bezierAnimationResource])
                else { fatalError() }
                
                fish.playAnimation(animationGroup)
            }
        }
    }
    
    private func printAnchorState() {
        print("isAnchored: \(self.anchorEntity?.isAnchored ?? false)")
    }
    
    enum Constants {
        static let fishStartPosition: simd_float3 = [-0.2, 0, 0]
        static let fishEndPosition: simd_float3 = [0.2, 0, 0]
        static let scale: Float = 0.03
    }
}
