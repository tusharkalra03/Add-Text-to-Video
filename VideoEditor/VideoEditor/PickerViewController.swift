//
//  ViewController.swift
//  VideoEditor
//
//  Created by Tushar Kalra on 10/06/21.
//

import UIKit
import MobileCoreServices
import AVKit

class PickerViewController: UIViewController {
    
    private let editor = VideoEditor()
    
    
    private let textlabel: UILabel = {
        let textlabel = UILabel()
        textlabel.text = "Add text to video"
        textlabel.textColor = .black
        textlabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textlabel.numberOfLines = 2
        return textlabel
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Pick Video", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 2
        textField.placeholder = "Enter text"
        textField.setLeftPaddingPoints(8)
        textField.setRightPaddingPoints(8)
        return textField

    }()
    
    private let activityIndicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"

        let navbar = navigationController?.navigationBar
        navbar?.isHidden = true
        
        textField.delegate = self
    
        
        view.addSubview(textlabel)
        view.addSubview(button)
        view.addSubview(textField)
        view.addSubview(activityIndicator)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = view.width
        
        textlabel.frame = CGRect(x: view.left + 16, y: view.top + 100, width: size - 32, height: 100)
        textField.frame = CGRect(x: view.left + 16, y: textlabel.bottom + 20, width: size - 32, height: 50)
        button.frame = CGRect(x: view.left + 16, y: textField.bottom + 20, width: size - 32, height: 50)
        activityIndicator.frame = CGRect(x: view.frame.midX - 16 , y: view.frame.midY, width: 37, height: 37)
        activityIndicator.style = .medium

    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      textField.text = ""
      navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private var pickedURL: URL?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let url = pickedURL,
            let destination = segue.destination as? PlayerViewController
        else {
            return
        }
        
        destination.videoURL = url
    }
    
    
    @objc func buttonAction(){
        pickVideo(from: .savedPhotosAlbum)
    }
    
    private func showInProgress() {
      activityIndicator.startAnimating()
      view.alpha = 0.3
      button.isEnabled = false
    }
    
    private func showCompleted() {
      activityIndicator.stopAnimating()
      view.alpha = 1
      button.isEnabled = true
    }
    
    private func pickVideo(from sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.mediaTypes = ["public.movie"]
        pickerController.videoQuality = .typeIFrame1280x720
        if sourceType == .camera {
            pickerController.cameraDevice = .front
        }
        pickerController.delegate = self
        present(pickerController, animated: true)
    }
    
    
}

extension PickerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let url = info[.mediaURL] as? URL,
            let text = textField.text
        else {
            print("Cannot get video URL")
            return
        }
        
        showInProgress()
        dismiss(animated: true){
            self.editor.editVideo(fromVideoAt: url, forText: text) { exportedURL in
                self.showCompleted()
                guard let exportedURL = exportedURL else {
                    return
                }
                self.pickedURL = exportedURL
                self.performSegue(withIdentifier: "showVideo", sender: nil)

            }
            
        }
    }
    
}
extension PickerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIView {
    
    public var width: CGFloat{
        return self.frame.size.width
    }
    public var height: CGFloat{
        return self.frame.size.height
    }
    public var top: CGFloat{
        return self.frame.origin.y
    }
    public var bottom: CGFloat{
        return self.frame.size.height + self.frame.origin.y
    }
    public var left: CGFloat{
        return self.frame.origin.x
    }

    public var right: CGFloat{
        return self.frame.size.width + self.frame.origin.x
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
