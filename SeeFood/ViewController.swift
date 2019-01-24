//
//  ViewController.swift
//  SeeFood
//
//  Created by hesham on 1/24/19.
//  Copyright © 2019 hesham. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var foodImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    let SEARCH_QUERY = "hotdog"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // edit it to .camera to include both
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    // The user has picked a picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Go to info.plist and add dict of camera usage description
        guard let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            imagePicker.dismiss(animated: true, completion: nil)
            return
        }
        foodImageView.image = imagePicked
        // To submit to the model
        guard let ciImage = CIImage(image: imagePicked) else {
            fatalError("Couldn't convert to CIImage")
        }
        detect(image: ciImage)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed...")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, errror) in
            //process request
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first, firstResult.identifier.contains(self.SEARCH_QUERY) {
                self.navigationItem.title = self.SEARCH_QUERY+"!"
            } else {
                self.navigationItem.title = "Not \(self.SEARCH_QUERY)!"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}
