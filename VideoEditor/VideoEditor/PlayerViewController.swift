//
//  PlayerViewController.swift
//  VideoEditor
//
//  Created by Tushar Kalra on 10/06/21.
//

import UIKit
import AVKit
import Photos

class PlayerViewController: UIViewController {
    
    var videoURL: URL!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(saveVideo), for: .touchUpInside)
        return button
    }()
    
    let playerView: UIView = {
        let playerView = UIView()
        return playerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Save"
        
        
        
        view.addSubview(playerView)
        view.addSubview(button)

        
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)
        player.play()

    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      
        let size = view.width
        let height = view.height
        playerView.frame = CGRect(x: view.left + 16, y: view.top + 50, width: size - 32, height: height - 150)
        button.frame = CGRect(x: view.left + 16, y: playerView.bottom + 10, width: size - 32, height: 50)
       playerLayer.frame = playerView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc func saveVideo(){
        print("saved")
        PHPhotoLibrary.requestAuthorization { [weak self] status in
          switch status {
          case .authorized:
            self?.saveVideoToPhotos()
          default:
            print("Photos permissions not granted.")
            return
          }
        }
    }
    
    private func saveVideoToPhotos() {
      PHPhotoLibrary.shared().performChanges( {
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
      }) { [weak self] (isSaved, error) in
        if isSaved {
          print("Video saved.")
        } else {
          print("Cannot save video.")
          print(error ?? "unknown error")
        }
        DispatchQueue.main.async {
          self?.navigationController?.popViewController(animated: true)
        }
      }
    }

}
