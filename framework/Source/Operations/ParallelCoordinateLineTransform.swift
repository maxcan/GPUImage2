#if os(Linux)
#if GLES
    import COpenGLES.gles2
    #else
    import COpenGL
#endif
#else
#if GLES
    import OpenGLES
    #else
    import OpenGL.GL3
#endif
#endif

/* Harris corner detector
 
 First pass: reduce to luminance and take the derivative of the luminance texture (GPUImageXYDerivativeFilter)
 
 Second pass: blur the derivative (GaussianBlur)
 
 Third pass: apply the Harris corner detection calculation
 
 This is the Harris corner detector, as described in
 C. Harris and M. Stephens. A Combined Corner and Edge Detector. Proc. Alvey Vision Conf., Univ. Manchester, pp. 147-151, 1988.
 */


//
//  ParallelCoordinateLineTransform.swift
//  GPUImage-Mac
//
//  Created by Max Cantor on 8/3/16.
//  Copyright © 2016 Sunset Lake Software LLC. All rights reserved.
//

import Foundation

public class ParallelCoordinateLineTransform: OperationGroup {
    let parallelTransformOp: BasicOperation
    var linePairsToRender: UInt
    var maxLinePairsToRender:UInt
    var lineCoordinates:Array<GLFloat>
    public init(fragmentShader:String = ParallelCoordinateLineTransformFragmentShader) {
        parallelTransformOp = BasicOperation(fragmentShader: fragmentShader)
        linePairsToRender = 0
        maxLinePairsToRender = 999 // ???
        super.init()
        self.configureGroup{input, output in
            input --> self.parallelTransformOp --> output
            
        }
        outputImageRelay.newImageCallback = {[weak self] framebuffer in
            self!.renderToTextureWithVertices(framebuffer)
        }
    }
    
    
    func renderToTextureWithVertices(framebuffer:Framebuffer) {
        glFinish();
        // Copying from Harris Corner Detector
        let imageByteSize = Int(framebuffer.size.width * framebuffer.size.height * 4)
        let inputTextureSize = framebuffer.size
        let rawImagePixels = UnsafeMutablePointer<UInt8>.alloc(imageByteSize)
        
        glReadPixels(0, 0, framebuffer.size.width, framebuffer.size.height, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), rawImagePixels)
        
        let xAspectMultiplier:CGFloat = 1.0
        let yAspectMultiplier:CGFloat = 1.0
        
        let imageWidth = framebuffer.size.width * 4
        
        linePairsToRender = 0;
        let currentByte = 0;
//        let lineStorageIndex:UInt = 0;
        let maxLineStorageIndexUInt = maxLinePairsToRender * 8 - 8;
        
        var minY:CGFloat = 100
        var maxY:CGFloat = -100
        var minX:CGFloat = 100
        var maxX:CGFloat = -100
        
//        var minY:GLfloat = 100
//        var maxY:GLfloat = -100
//        var minX:GLfloat = 100
//        var maxX:GLfloat = -100
        
        while (currentByte < imageByteSize) {
            let colorByte = rawImagePixels[currentByte]
            if (colorByte > 0) {
                let xCoordinate = Int32(currentByte) % imageWidth
                let yCoordinate = Int32(currentByte) / imageWidth
                
                let normalizedXCoordinate:CGFloat = (-1.0 + 2.0 * (CGFloat)(xCoordinate / 4) / CGFloat(inputTextureSize.width)) * xAspectMultiplier;
                let normalizedYCoordinate:CGFloat = (-1.0 + 2.0 * (CGFloat)(yCoordinate) / CGFloat(inputTextureSize.height)) * yAspectMultiplier;
                
                // this might not be the most performant..
                let minF = {(a:CGFloat,b:CGFloat) in ( a < b ? a : b) }
                let maxF = {(a:CGFloat,b:CGFloat) in ( a > b ? a : b) }
                minY = minF(minY, normalizedYCoordinate);
                maxY = maxF(maxY, normalizedYCoordinate);
                minX = minF(minX, normalizedXCoordinate);
                maxX = maxF(maxX, normalizedXCoordinate);
                //            NSLog(@"Parallel line coordinates: (%f, %f) - (%f, %f) - (%f, %f)", -1.0, -normalizedYCoordinate, 0.0, normalizedXCoordinate, 1.0, normalizedYCoordinate);
                // T space coordinates, (-d, -y) to (0, x)
                lineCoordinates.append(-1.0)
                lineCoordinates.append(-normalizedYCoordinate)
                lineCoordinates.append(0.0)
                lineCoordinates.append(normalizedXCoordinate)

                // S space coordinates, (0, x) to (d, y)
                lineCoordinates.append(0.0)
                lineCoordinates.append(normalizedXCoordinate)
                lineCoordinates.append(1.0)
                lineCoordinates.append(normalizedYCoordinate)
//
                linePairsToRender+=1
//
                linePairsToRender = MIN(linePairsToRender, maxLinePairsToRender);
                lineStorageIndex = MIN(lineStorageIndex, maxLineStorageIndex);
            }

        }
        
    }
}