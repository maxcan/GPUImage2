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
    public override init() {
        super.init()
        // TODO fix this.
        #if os(iOS)
            let lineGenerator = LineGenerator(size:Size(width:480, height:640))
        #else
            let lineGenerator = LineGenerator(size:Size(width:1280, height:720))
        #endif

        //
        //        let lineGenerator = LineGenerator(size:Size(width:0 , height: 0))
        lineGenerator.clearColor = Color.Black
        let blendFilter = AlphaBlend()
        let parallelCoordinateGenerator = ParallelCoordinateLineGenerator()

        parallelCoordinateGenerator.parallelLinesCallback = { lines in
            lineGenerator.renderLines(lines)
            print("Rendering lines: \(lines)")
        }
        self.configureGroup {input, output in
            // can we have "disconnected filters like this?  If not, we'll just
            // black out the output of the parallelCoordinateGenerator
            lineGenerator --> blendFilter
            input --> parallelCoordinateGenerator --> blendFilter
            blendFilter --> output
        }
    }
}

// Use the Line Generator filter for drawing.  We'll just use this to output the lines
public class ParallelCoordinateLineGenerator: OperationGroup {
    let parallelTransformOp: BasicOperation
    var maxLinePairsToRender:UInt32
    public var parallelLinesCallback:([Line] -> ())?

    public init(fragmentShader:String = ParallelCoordinateLineTransformFragmentShader) {
        parallelTransformOp = BasicOperation(fragmentShader: fragmentShader)
        maxLinePairsToRender = 999 // ???
        super.init()
        self.configureGroup{input, output in
            input --> self.parallelTransformOp --> output

        }
        //        outputImageRelay.newImageCallback = {[weak self] framebuffer in
        //            if let parallelLinesCallback = self?.parallelLinesCallback {
        //                parallelLinesCallback(self?.generateLineCoordinates(framebuffer) ?? [])
        //            }
        //        }
    }

    func generateLineCoordinates(framebuffer:Framebuffer) -> [Line]{

        let MAXLINESCALINGFACTOR : UInt32 = 4
        let maxLinePairsToRender : UInt32 = UInt32(framebuffer.size.width * framebuffer.size.height) / MAXLINESCALINGFACTOR;
        var lineCoordinates = Array<Line>(count: Int(maxLinePairsToRender) * 2, repeatedValue: Line.Segment(p1:Position(0,0),p2:Position(0,0)))

        // Copying from Harris Corner Detector
        let imageByteSize = Int(framebuffer.size.width * framebuffer.size.height * 4)
        let inputTextureSize = framebuffer.size
        let rawImagePixels = UnsafeMutablePointer<UInt8>.alloc(imageByteSize)

        glReadPixels(0, 0, framebuffer.size.width, framebuffer.size.height, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), rawImagePixels)

        let startTime = CFAbsoluteTimeGetCurrent()
        let xAspectMultiplier:Float = 1.0
        let yAspectMultiplier:Float = 1.0

        let imageWidth = framebuffer.size.width * 4

        var linePairsToRender:UInt32 = 0
        var currentByte = 0
        var lineStorageIndex:UInt32 = 0

        let maxLineStorageIndex:UInt32 = maxLinePairsToRender * 2

        var minY:Float = 100
        var maxY:Float = -100
        var minX:Float = 100
        var maxX:Float = -100

        while (currentByte < imageByteSize) {
            let colorByte = rawImagePixels[currentByte]
            if (colorByte > 0) {
                let xCoordinate = Int32(currentByte) % imageWidth
                let yCoordinate = Int32(currentByte) / imageWidth

                let normalizedXCoordinate:Float = (-1.0 + 2.0 * (Float)(xCoordinate / 4) / Float(inputTextureSize.width)) * xAspectMultiplier;
                let normalizedYCoordinate:Float = (-1.0 + 2.0 * (Float)(yCoordinate) / Float(inputTextureSize.height)) * yAspectMultiplier;

                // this might not be the most performant..
                minY = min(minY, normalizedYCoordinate);
                maxY = max(maxY, normalizedYCoordinate);
                minX = min(minX, normalizedXCoordinate);
                maxX = max(maxX, normalizedXCoordinate);
                //            NSLog(@"Parallel line coordinates: (%f, %f) - (%f, %f) - (%f, %f)", -1.0, -normalizedYCoordinate, 0.0, normalizedXCoordinate, 1.0, normalizedYCoordinate);
                // T space coordinates, (-d, -y) to (0, x)
                // Note - I really dont know if its better to just use signed ints.  Swift wont allow a UInt as an array index but
                // signed ints seem silly.  If this is a no-op, then fine.  But if casting like this hurts performance can look into
                // better solutions.

                lineCoordinates[Int(lineStorageIndex)] =
                    Line.Segment(p1: Position(-1.0, -normalizedYCoordinate),
                                 p2: Position(0.0, normalizedXCoordinate))
                lineStorageIndex += 1
                // S space coordinates, (0, x) to (d, y)
                lineCoordinates[Int(lineStorageIndex)] =
                    Line.Segment(p1: Position(0.0, normalizedXCoordinate),
                                 p2: Position(1.0, normalizedYCoordinate))
                lineStorageIndex += 1

                //                lineCoordinates!.append(-1.0)
                //                lineCoordinates!.append(-normalizedYCoordinate)
                //                lineCoordinates!.append(0.0)
                //                lineCoordinates!.append(normalizedXCoordinate)
                //                lineCoordinates!.append(0.0)
                //                lineCoordinates!.append(normalizedXCoordinate)
                //                lineCoordinates!.append(1.0)
                //                lineCoordinates!.append(normalizedYCoordinate)
                //
                linePairsToRender+=1
                //

                linePairsToRender = min(linePairsToRender, maxLinePairsToRender)
                lineStorageIndex = min(lineStorageIndex, maxLineStorageIndex)
            }
            currentByte += 8
        }
        //    NSLog(@"Line pairs to render: %d out of max: %d", linePairsToRender, maxLinePairsToRender);

        let currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
        print("Line generation processing time : \(1000.0 * currentFrameTime) ms for \(linePairsToRender) lines");
        return lineCoordinates
        //        outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
        //        [outputFramebuffer activateFramebuffer];
        //
        //        if (usingNextFrameForImageCapture)
        //        {
        //            [outputFramebuffer lock];
        //        }
        //
        //        [GPUImageContext setActiveShaderProgram:filterProgram];
        //        [self setUniformsForProgramAtIndex:0];
        //
        //        glClearColor(0.0, 0.0, 0.0, 1.0);
        //        glClear(GL_COLOR_BUFFER_BIT);
        //
        //        if (![GPUImageContext deviceSupportsFramebufferReads])
        //        {
        //            glBlendEquation(GL_FUNC_ADD);
        //            glBlendFunc(GL_ONE, GL_ONE);
        //            glEnable(GL_BLEND);
        //        }
        //        else
        //        {
        //        }
        //
        //        glLineWidth(1);
        //
        //        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, lineCoordinates);
        //        glDrawArrays(GL_LINES, 0, (linePairsToRender * 4));
        //
        //        if (![GPUImageContext deviceSupportsFramebufferReads])
        //        {
        //            glDisable(GL_BLEND);
        //        }
        //        [firstInputFramebuffer unlock];
        //        if (usingNextFrameForImageCapture)
        //        {
        //            dispatch_semaphore_signal(imageCaptureSemaphore);
        //        }
        //
    }
}
