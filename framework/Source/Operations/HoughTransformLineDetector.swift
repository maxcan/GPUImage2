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

//
//  HoughTransformLineDetector.swift
//  GPUImage-Mac
//
//  Created by Max Cantor on 8/6/16.
//  Copyright © 2016 Sunset Lake Software LLC. All rights reserved.
//

import Foundation

public class HoughTransformLineDetector: OperationGroup {

    public var linesDetectedCallback:([Line] -> ())?
    public var edgeThreshold:Float = 0.9
    public var lineDetectionThreshold:Float = 0.2
    public override init() {
        super.init()
        let thresholdEdgeDetectionFilter = CannyEdgeDetection()
        let parallelCoordsTransformFilter = ParallelCoordinateLineTransform()
        let nonMaximumSuppression = TextureSamplingOperation(fragmentShader:ThresholdedNonMaximumSuppressionFragmentShader)
        var threshold:Float = 0.2 { didSet { nonMaximumSuppression.uniformSettings["threshold"] = threshold } }
        nonMaximumSuppression.uniformSettings["threshold"] = 0.2
        
//        let directionalNonMaximumSuppression = TextureSamplingOperation(vertexShader:OneInputVertexShader, fragmentShader:DirectionalNonMaximumSuppressionFragmentShader)
        
//        let nonMaximumSuppressionFlt =
//            ( sharedImageProcessingContext.deviceSupportsFramebufferReads()
//                ? Thre
//                : ParallelCoordinateLineTransformFragmentShader
//        )
        
        outputImageRelay.newImageCallback = {[weak self] framebuffer in
            if let linesDetectedCallback = self?.linesDetectedCallback {
                linesDetectedCallback(extractLinesFromImage(framebuffer))
            }
        }

        self.configureGroup {input, output in
            input --> thresholdEdgeDetectionFilter --> parallelCoordsTransformFilter --> nonMaximumSuppression --> output
        }
    }
}

func extractLinesFromImage(framebuffer: Framebuffer) -> [Line] {
//    var numLines = 0
    let frameSize = framebuffer.size
//    let maxLines = 528
    let pixCount = UInt32(frameSize.width * frameSize.height)
    //    NSAssert(self.outputTextureOptions.internalFormat == GL_RGBA, @"The output texture format for this filter must be GL_RGBA.");
    //    NSAssert(self.outputTextureOptions.type == GL_UNSIGNED_BYTE, @"The type of the output texture of this filter must be GL_UNSIGNED_BYTE.");
    let chanCount: UInt32 = 4
    let imageByteSize = Int(pixCount * chanCount) // since we're comparing to currentByte, might as well cast here
    let rawImagePixels = UnsafeMutablePointer<UInt8>.alloc(Int(imageByteSize))
    glReadPixels(0, 0, frameSize.width, frameSize.height, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), rawImagePixels)
    // since we only set one position with each iteration of the loop, we'll have ot set positions then combine into lines
    //    linesArray = calloc(1024 * 2, sizeof(GLfloat)); - lines is 2048 floats - which is 1024 positions or 528 lines
//    var positions = Array<Position>()
    var lines = Array<Line>()

    let imageWidthInt = Int(framebuffer.size.width * 4)
      //
//    let startTime = CFAbsoluteTimeGetCurrent()
    var currentByte:Int = 0
//    var cornerStorageIndex: UInt32 = 0
    var lineStrengthCounter: UInt64 = 0
    while (currentByte < imageByteSize) {
        let colorByte = rawImagePixels[currentByte]
        if (colorByte > 0) {
            let xCoordinate = currentByte % imageWidthInt
            let yCoordinate = currentByte / imageWidthInt
            lineStrengthCounter += UInt64(colorByte)
            let normalizedXCoordinate = -1.0 + 2.0 * (Float)(xCoordinate / 4) / Float(frameSize.width)
            let normalizedYCoordinate = -1.0 + 2.0 * (Float)(yCoordinate) / Float(frameSize.height)
//            print("(\(xCoordinate), \(yCoordinate)), [\(rawImagePixels[currentByte]), \(rawImagePixels[currentByte+1]), \(rawImagePixels[currentByte+2]), \(rawImagePixels[currentByte+3]) ] ")
            let nextLine =
                ( normalizedXCoordinate < 0.0
                ? ( normalizedXCoordinate > -0.05
                    // T space
                    // m = -1 - d/u
                    // b = d * v/u
                    ? Line.Infinite(slope:100000.0, intercept: normalizedYCoordinate)
                    : Line.Infinite(slope: -1.0 - 1.0 / normalizedXCoordinate, intercept: 1.0 * normalizedYCoordinate / normalizedXCoordinate)
                )
                : ( normalizedXCoordinate < 0.05
                    // S space
                    // m = 1 - d/u
                    // b = d * v/u
                    ? Line.Infinite(slope: 100000.0, intercept: normalizedYCoordinate)
                    : Line.Infinite(slope: 1.0 - 1.0 / normalizedXCoordinate,intercept: 1.0 * normalizedYCoordinate / normalizedXCoordinate)
                    )
                )
            lines.append(nextLine)
        }
        currentByte += 4
    }
    return lines
}
    //
//                if (normalizedXCoordinate < 0.0) {
//                    // T space
//                    // m = -1 - d/u
//                    // b = d * v/u
//                    if (normalizedXCoordinate > -0.05) // Test for the case right near the X axis, stamp the X intercept instead of the Y
//                    {
////                        linesArray[cornerStorageIndex++] = 100000.0;
////                        linesArray[cornerStorageIndex++] = normalizedYCoordinate;
//                    }
//                    else
//                    {
////                        linesArray[cornerStorageIndex++] = -1.0 - 1.0 / normalizedXCoordinate;
////                        linesArray[cornerStorageIndex++] = 1.0 * normalizedYCoordinate / normalizedXCoordinate;
//                    }
//                }
//                else
//                {
//                    // S space
//                    // m = 1 - d/u
//                    // b = d * v/u
//                    if (normalizedXCoordinate < 0.05) // Test for the case right near the X axis, stamp the X intercept instead of the Y
//                    {
////                        linesArray[cornerStorageIndex++] = 100000.0;
////                        linesArray[cornerStorageIndex++] = normalizedYCoordinate;
//                    }
//                    else
//                    {
////                        linesArray[cornerStorageIndex++] = 1.0 - 1.0 / normalizedXCoordinate;
////                        linesArray[cornerStorageIndex++] = 1.0 * normalizedYCoordinate / normalizedXCoordinate;
//                    }
//                }

    //            numberOfLines++;
    //
    //            numberOfLines = MIN(numberOfLines, 1023);
    //            cornerStorageIndex = MIN(cornerStorageIndex, 2040);
    //        }
    //        currentByte +=4;
    //    }
    //
    //    //    CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
    //    //    NSLog(@"Processing time : %f ms", 1000.0 * currentFrameTime);
    //
    //    if (linesDetectedBlock != NULL)
    //    {
    //        linesDetectedBlock(linesArray, numberOfLines, frameTime);
    //    }
    //    }
    //
//        }
//
//}

//
//    //    }
//    [self addFilter:thresholdEdgeDetectionFilter];
//
//    // Second pass: extract the white points and draw representative lines in parallel coordinate space
//    parallelCoordinateLineTransformFilter = [[GPUImageParallelCoordinateLineTransformFilter alloc] init];
//    [self addFilter:parallelCoordinateLineTransformFilter];
//
//    // Third pass: apply non-maximum suppression
//    if ([GPUImageContext deviceSupportsFramebufferReads])
//    {
//        nonMaximumSuppressionFilter = [[GPUImageThresholdedNonMaximumSuppressionFilter alloc] initWithPackedColorspace:YES];
//    }
//    else
//    {
//        nonMaximumSuppressionFilter = [[GPUImageThresholdedNonMaximumSuppressionFilter alloc] initWithPackedColorspace:NO];
//    }
//    [self addFilter:nonMaximumSuppressionFilter];
//
//    __unsafe_unretained GPUImageHoughTransformLineDetector *weakSelf = self;
//    #ifdef DEBUGLINEDETECTION
//    _intermediateImages = [[NSMutableArray alloc] init];
//    __unsafe_unretained NSMutableArray *weakIntermediateImages = _intermediateImages;
//
//    //    __unsafe_unretained GPUImageOutput<GPUImageInput> *weakEdgeDetectionFilter = thresholdEdgeDetectionFilter;
//    //    [thresholdEdgeDetectionFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime){
//    //        [weakIntermediateImages removeAllObjects];
//    //        UIImage *intermediateImage = [weakEdgeDetectionFilter imageFromCurrentFramebuffer];
//    //        [weakIntermediateImages addObject:intermediateImage];
//    //    }];
//    //
//    //    __unsafe_unretained GPUImageOutput<GPUImageInput> *weakParallelCoordinateLineTransformFilter = parallelCoordinateLineTransformFilter;
//    //    [parallelCoordinateLineTransformFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime){
//    //        UIImage *intermediateImage = [weakParallelCoordinateLineTransformFilter imageFromCurrentFramebuffer];
//    //        [weakIntermediateImages addObject:intermediateImage];
//    //    }];
//
//    __unsafe_unretained GPUImageOutput<GPUImageInput> *weakNonMaximumSuppressionFilter = nonMaximumSuppressionFilter;
//    [nonMaximumSuppressionFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime){
//    UIImage *intermediateImage = [weakNonMaximumSuppressionFilter imageFromCurrentFramebuffer];
//    [weakIntermediateImages addObject:intermediateImage];
//
//    [weakSelf extractLineParametersFromImageAtFrameTime:frameTime];
//    }];
//    #else
//    [nonMaximumSuppressionFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime) {
//    [weakSelf extractLineParametersFromImageAtFrameTime:frameTime];
//    }];
//    #endif
//
//    [thresholdEdgeDetectionFilter addTarget:parallelCoordinateLineTransformFilter];
//    [parallelCoordinateLineTransformFilter addTarget:nonMaximumSuppressionFilter];
//
//    self.initialFilters = [NSArray arrayWithObjects:thresholdEdgeDetectionFilter, nil];
//    //    self.terminalFilter = colorPackingFilter;
//    self.terminalFilter = nonMaximumSuppressionFilter;
//
//    //    self.edgeThreshold = 0.95;
//    self.lineDetectionThreshold = 0.12;
//
//    return self;
//    }
//
//    - (void)dealloc;
//{
//    free(rawImagePixels);
//    free(linesArray);
//}
//
//#pragma mark -
//#pragma mark Corner extraction
//
//- (void)extractLineParametersFromImageAtFrameTime:(CMTime)frameTime;
//{
//    - (BOOL)wantsMonochromeInput;
//{
//    //    return YES;
//    return NO;
//}
//
//#pragma mark -
//#pragma mark Accessors
//
////- (void)setEdgeThreshold:(CGFloat)newValue;
////{
////    [(GPUImageCannyEdgeDetectionFilter *)thresholdEdgeDetectionFilter setThreshold:newValue];
////}
////
////- (CGFloat)edgeThreshold;
////{
////    return [(GPUImageCannyEdgeDetectionFilter *)thresholdEdgeDetectionFilter threshold];
////}
//
//- (void)setLineDetectionThreshold:(CGFloat)newValue;
//{
//    nonMaximumSuppressionFilter.threshold = newValue;
//    }
//
//    - (CGFloat)lineDetectionThreshold;
//{
//    return nonMaximumSuppressionFilter.threshold;
//}
//
//#ifdef DEBUGLINEDETECTION
//- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
//{
//    //    [thresholdEdgeDetectionFilter useNextFrameForImageCapture];
//    //    [parallelCoordinateLineTransformFilter useNextFrameForImageCapture];
//    [nonMaximumSuppressionFilter useNextFrameForImageCapture];
//    
//    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
//}
//#endif
//
//@end
