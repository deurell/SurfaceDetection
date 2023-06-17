//
//  simd_float4x4+Translation.swift
//  SurfaceDetection
//
//  Created by Mikael Deurell on 2023-06-17.
//

import RealityKit

extension simd_float4x4 {
    init(translation: simd_float3) {
        self.init(
            simd_float4(1, 0, 0, translation.x),
            simd_float4(0, 1, 0, translation.y),
            simd_float4(0, 0, 1, translation.z),
            simd_float4(0, 0, 0, 1)
        )
    }
}
