//
//  VideoEditor.swift
//  VideoEditor
//
//  Created by Tushar Kalra on 10/06/21.
//

import UIKit
import AVFoundation

class VideoEditor {
    
    func editVideo(fromVideoAt videoURL: URL, forText text: String, onComplete: @escaping (URL?) -> Void) {
        
      print(videoURL)
      let asset = AVURLAsset(url: videoURL)
      let composition = AVMutableComposition() // create avmutablecomposition
      
      guard
        let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
        let assetTrack = asset.tracks(withMediaType: .video).first
        else {
          print("Something is wrong with the asset.")
          onComplete(nil)
          return
      }
      
      do {
        let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
        
        if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
          let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid) {
          try compositionAudioTrack.insertTimeRange(
            timeRange,
            of: audioAssetTrack,
            at: .zero)
        }
      } catch {
        print(error)
        onComplete(nil)
        return
      }
      
      compositionTrack.preferredTransform = assetTrack.preferredTransform
      
      let videoSize: CGSize
      videoSize = assetTrack.naturalSize
      
      
      let videoLayer = CALayer()
      videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        
      let overlayLayer = CALayer()
      overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
      
      
      
      add(text: text, to: overlayLayer, videoSize: videoSize)
      
      let outputLayer = CALayer()
      outputLayer.frame = CGRect(origin: .zero, size: videoSize)
      outputLayer.addSublayer(videoLayer)
      outputLayer.addSublayer(overlayLayer)
      
      let videoComposition = AVMutableVideoComposition()
      videoComposition.renderSize = videoSize
      videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
      videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
        postProcessingAsVideoLayer: videoLayer,
        in: outputLayer)
      
      let instruction = AVMutableVideoCompositionInstruction()
      instruction.timeRange = CMTimeRange(
        start: .zero,
        duration: composition.duration)
      videoComposition.instructions = [instruction]
      let layerInstruction = compositionLayerInstruction(
        for: compositionTrack,
        assetTrack: assetTrack)
      instruction.layerInstructions = [layerInstruction]
      
      guard let export = AVAssetExportSession(
        asset: composition,
        presetName: AVAssetExportPresetHighestQuality)
        else {
          print("Cannot create export session.")
          onComplete(nil)
          return
      }
      
      let videoName = UUID().uuidString
      let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(videoName)
        .appendingPathExtension("mov")
      
      export.videoComposition = videoComposition
      export.outputFileType = .mov
      export.outputURL = exportURL
      
      export.exportAsynchronously {
        DispatchQueue.main.async {
          switch export.status {
          case .completed:
            onComplete(exportURL)
          default:
            print("Something went wrong during export.")
            print(export.error ?? "unknown error")
            onComplete(nil)
            break
          }
        }
      }
    }
    
    private func add(text: String, to layer: CALayer, videoSize: CGSize) {
        //var textLayers = [CALayer]()
       // let words = text.split(separator: " ")
       // for word in words{
      let attributedText = NSAttributedString(
        string: text,
        attributes: [
          .font: UIFont(name: "ArialRoundedMTBold", size: 60) as Any,
          .foregroundColor: UIColor.systemPink,
          .strokeColor: UIColor.white,
          .strokeWidth: -3])
      
      let textLayer = CATextLayer()
      textLayer.string = attributedText
      textLayer.shouldRasterize = true
      textLayer.rasterizationScale = UIScreen.main.scale
      textLayer.backgroundColor = UIColor.clear.cgColor
      textLayer.alignmentMode = .center
        textLayer.isWrapped = true
        textLayer.truncationMode = .none
      
      textLayer.frame = CGRect(
        x: 0,
        y: videoSize.height * 0.66,
        width: videoSize.width,
        height: 150)
      textLayer.displayIfNeeded()
      
      let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
      scaleAnimation.fromValue = 0.8
      scaleAnimation.toValue = 1.5
      scaleAnimation.duration = 1
      scaleAnimation.repeatCount = 2
      scaleAnimation.autoreverses = true
      scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      
      scaleAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
      scaleAnimation.isRemovedOnCompletion = false
      textLayer.add(scaleAnimation, forKey: "scale")
      
    
        layer.addSublayer(textLayer)
    }
    
    private func addLayers(to layer: CALayer, from textLayers: [CALayer]){
        layer.addSublayer(textLayers[0])
        
        for num in 1..<textLayers.count{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                layer.replaceSublayer(textLayers[num - 1], with: textLayers[num])
            }
        }
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
      let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
      let transform = assetTrack.preferredTransform
      
      instruction.setTransform(transform, at: .zero)
      
      return instruction
    }

}
