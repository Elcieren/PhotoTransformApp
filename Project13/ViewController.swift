//
//  ViewController.swift
//  Project13
//
//  Created by Eren Elçi on 23.10.2024.
//

import UIKit
import CoreImage

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    @IBOutlet var changeButton: UIButton!
    
    @IBOutlet var intensity: UISlider!
    @IBOutlet var imageView: UIImageView!
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instafilter"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(imageSelectClicked))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        
    }
    //Image Secme
    @objc func imageSelectClicked(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    //Image Secildikden sonra sonra ne yapilcak
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

     //Slider Fonksiyonu
    @IBAction func insensityChanged(_ sender: Any) {
        applyProcessing()
    }
    //Kaydetme Fonksiyonu
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            let alert = UIAlertController(title: "Uyari", message: "Herhang bir duzenlemis oldugunuz resim bulunmamaktadir", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
            return present(alert, animated: true)
            
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    //Filtre Degistirme Fonksiyonu
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPhotoEffectChrome", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITemperatureAndTint", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect =  sender.bounds
        }
        
        present(ac, animated: true)


    }
    
    func setFilter(action: UIAlertAction) {
        guard  currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
        changeButton.setTitle(actionTitle, for: .normal)
        
        currentFilter = CIFilter(name: actionTitle)
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200 , forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10 , forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey){
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2 , y: currentImage.size.height / 2 ), forKey: kCIInputCenterKey)
        }
        if inputKeys.contains("inputNeutral") {
                currentFilter.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            }
            if inputKeys.contains("inputTargetNeutral") {
                let targetNeutral = intensity.value * 1000 + 5000
                currentFilter.setValue(CIVector(x: CGFloat(targetNeutral), y: 0), forKey: "inputTargetNeutral")
            }
        
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    @objc func image(_ image: UIImage , didFinishSavingWithError error: Error? , contextInfo: UnsafeRawPointer) {
        if let error = error {
                // we got back an error!
                let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            } else {
                let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
    }
    
}

