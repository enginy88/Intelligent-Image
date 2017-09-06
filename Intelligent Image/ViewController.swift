//
//  ViewController.swift
//  Intelligent Image
//
//  Created by Engin Yüce on 6.09.2017.
//  Copyright © 2017 Engin Yüce. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var modelSelector: UISegmentedControl!

	var chosenImage = CIImage()
	var hasChosenImage = false

	override func viewDidLoad() {
		super.viewDidLoad()
		
	}


	@IBAction func chooseButtonTapped(_ sender: Any) {

		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true
		picker.sourceType = .photoLibrary
		self.present(picker, animated: true, completion: nil)

	}


	@IBAction func modelSelectorChanged(_ sender: Any) {

		if hasChosenImage {
			recognizeImage(image: chosenImage)
		}

	}


	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

		imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
		self.dismiss(animated: true, completion: nil)

		if let ciImage = CIImage(image: imageView.image!) {
			chosenImage = ciImage
		}

		hasChosenImage = true
		recognizeImage(image: chosenImage)
		
	}


	func recognizeImage(image: CIImage) {

		resultLabel.text = "Finding..."

		var selectedModel = MLModel()

		if modelSelector.selectedSegmentIndex == 0 { // GoogleNet
			selectedModel = GoogLeNetPlaces().model
		}
		else if modelSelector.selectedSegmentIndex == 1 { // MobileNet
			selectedModel = MobileNet().model
		}
		else if modelSelector.selectedSegmentIndex == 2 { // SqueezeNet
			selectedModel = SqueezeNet().model
		}

		if let model = try? VNCoreMLModel(for: selectedModel) {
			let request = VNCoreMLRequest(model: model, completionHandler: { (vnrequest, error) in
				if let results = vnrequest.results as? [VNClassificationObservation] {
					let topResult = results.first

					DispatchQueue.main.async {
						let confLevel = (topResult?.confidence)! * 100
						let roundedConfLevel = Int(confLevel * 100) / 100
						self.resultLabel.text = "Result: " + String(topResult!.identifier).uppercased() + " (" + String(roundedConfLevel) + "%)"
					}
				}
			})
			let handler = VNImageRequestHandler(ciImage: chosenImage)
			DispatchQueue.global(qos: .userInteractive).async {
				do {
					try handler.perform([request])
				}
				catch {
					print("Error!")
				}
			}
		}

	}


}

