//
//  ViewController.swift
//  hello-opencv
//
//  Created by hyonsoo han on 8/3/24.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var ivTop: UIImageView!
    @IBOutlet weak var ivBottom: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var lbSigmaColor: UILabel!
    @IBOutlet weak var lbSigmaSpace: UILabel!
    @IBOutlet weak var sliderColor: UISlider!
    @IBOutlet weak var sliderSpace: UISlider!
    
    private var blurring = false
    private var sigmaColor: Float = 20.0
    private var sigmaSpace: Float = 20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.isHidden = true
        lbVersion.text = "\(OpenCVWrapper.getOpenCVVersion())"
        
        sliderColor.maximumValue = 50
        sliderSpace.maximumValue = 50
        sliderColor.value = sigmaColor
        sliderSpace.value = sigmaSpace
    }
    
    @IBAction func clickPick() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.any(of: [.images])
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func changedSigmaColor(sender: UISlider) {
        lbSigmaColor.text = "SigmaColor \(sender.value)"
        sigmaColor = sender.value
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(applyBlur), object: nil)
        self.perform(#selector(self.applyBlur), with: nil, afterDelay: 1.0)
    }
    
    @IBAction func changedSigmaSpace(sender: UISlider) {
        lbSigmaSpace.text = "SigmaSpace \(sender.value)"
        sigmaSpace = sender.value
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(applyBlur), object: nil)
        self.perform(#selector(self.applyBlur), with: nil, afterDelay: 1.0)
    }
    
    @objc
    func applyBlur() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(applyBlur), object: nil)
        
        guard let image = ivTop.image, !blurring else {
            return
        }
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        DispatchQueue.global().async {
            let blurred = OpenCVWrapper.bilateralBlur(image, Double(self.sigmaColor), Double(self.sigmaSpace))
            DispatchQueue.main.async {
                self.activityView.isHidden = true
                self.ivBottom.image = blurred
                self.blurring = false
            }
        }
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let result = results.first {
            DispatchQueue.main.async {
                picker.dismiss(animated: true)
                self.activityView.isHidden = false
                self.activityView.startAnimating()
            }
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    
                    let ratio = image.size.height / image.size.width
                    let tw = 1200
                    let th = 1200 * ratio
                    let resized = OpenCVWrapper.resizeImg(image, Int32(tw), Int32(th))
                    
                    DispatchQueue.main.async {
                        self.ivTop.image = resized
                        self.applyBlur()
                    }
                }
            }
        }
    }
    
    
}

