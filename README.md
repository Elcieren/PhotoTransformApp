
![Ekran-Kaydı-2024-10-25-18 20 46](https://github.com/user-attachments/assets/53f7b244-7059-489a-85fc-4eb37c295610)
<details>
    <summary><h2>Uygulma Amacı</h2></summary>
  Bu uygulama, kullanıcının fotoğraflarını düzenlemesine ve farklı filtreler uygulamasına olanak tanıyan temel bir fotoğraf düzenleme uygulamasıdır. Uygulama, iOS’un Core Image kütüphanesini kullanarak çeşitli filtreleri fotoğraflara uyguluyor ve sonuçları kaydedip kullanıcıya görsel olarak sunuyor. Şimdi kodun önemli kısımlarını açıklayarak uygulamanın nasıl çalıştığını adım adım inceleyelim
  </details> 
  
  <details>
    <summary><h2>Sınıf ve Değişken Tanımları</h2></summary>
    changeButton: Kullanıcı bir filtre seçtiğinde tetiklenecek düğme.
    intensity: Filtre yoğunluğunu ayarlamak için kullanılan kaydırıcı (slider).
    imageView: Seçilen görselin gösterileceği alan.
    currentImage: Düzenlenecek olan fotoğrafın orijinal halini tutar.
    context: CIContext, Core Image ile görüntü işleme yapılmasını sağlar. İşlemler sonucunda bir görsel oluşturulmasına yardımcı olur.
    currentFilter: Görselde uygulanacak mevcut filtreyi saklar.
    
    ```
    class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var imageView: UIImageView!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    ```
  </details> 

  <details>
    <summary><h2>Görsel Seçme Fonksiyonu</h2></summary>
    UIImagePickerController: Kullanıcının fotoğraf seçmesi veya yeni bir fotoğraf çekmesi için fotoğraf seçme ekranını açar.
    allowsEditing = true: Kullanıcının fotoğrafı seçtikten sonra kırpma gibi düzenleme yapabilmesini sağlar.
    present(picker, animated: true): Fotoğraf seçme ekranını gösterir.

    
    ```
    @objc func imageSelectClicked() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true)
    }


    ```
  </details> 




<details>
    <summary><h2>Fotoğraf Seçildikten Sonra Yapılacak İşlemler (imagePickerController)</h2></summary>
    guard let image = info[.editedImage] as? UIImage: Kullanıcının düzenlediği (kırptığı) görseli UIImage türüne dönüştürerek image değişkenine atar. Eğer görüntü alınamıyorsa, işlem durdurulur.
    dismiss(animated: true): Fotoğraf seçme ekranı kapatılır.
    currentImage = image: Seçilen görsel currentImage değişkenine atanır.
    let beginImage = CIImage(image: currentImage): UIImage türündeki currentImage görseli, Core Image işlemleri için CIImage formatına dönüştürülür.
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey): currentFilter üzerinde, seçilen görüntü filtreye uygulanmak üzere giriş olarak atanır.
    applyProcessing(): Filtrenin uygulanması için applyProcessing fonksiyonu çağrılır.

    
    ```
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.editedImage] as? UIImage else { return }
    dismiss(animated: true)
    currentImage = image
    
    let beginImage = CIImage(image: currentImage)
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    applyProcessing()
    }



    ```
  </details>

  <details>
    <summary><h2>Kaydetme Fonksiyonu (save)</h2></summary>
   guard let image = imageView.image: Eğer düzenlenmiş bir görsel yoksa, kullanıcıya bir uyarı gösterir ve işlemi sonlandırır.
   UIImageWriteToSavedPhotosAlbum: Düzenlenmiş görseli cihazın fotoğraf albümüne kaydeder. Kaydetme işlemi tamamlandığında image(_:didFinishSavingWithError:contextInfo:) fonksiyonu çalışır.

    
    ```
    @IBAction func save(_ sender: Any) {
    guard let image = imageView.image else {
        let alert = UIAlertController(title: "Uyari", message: "Herhangi bir düzenlenmiş resim bulunmamaktadır", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
        return present(alert, animated: true)
    }
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }



    ```
  </details>
  <details>
    <summary><h2>Filtre Değiştirme Fonksiyonu (changeFilter)</h2></summary>
   UIAlertController: Kullanıcıya mevcut filtreler arasından seçim yapması için bir aksiyon menüsü açar.
   ac.addAction: Farklı filtreleri seçme seçenekleri ekler. Her bir filtre seçildiğinde setFilter fonksiyonu çağrılır.
   present(ac, animated: true): Aksiyon menüsünü ekranda gösterir.

    
    ```
    @IBAction func changeFilter(_ sender: UIButton) {
    let ac = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    
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
        popoverController.sourceRect = sender.bounds
    }
    
     present(ac, animated: true)
    }




    ```
  </details>
  <details>
    <summary><h2>Filtre Seçim ve Uygulama Fonksiyonu (setFilter)</h2></summary>
   guard currentImage != nil: Eğer bir görsel yoksa işlem durdurulur.
   currentFilter = CIFilter(name: actionTitle): Kullanıcının seçtiği filtre currentFilter değişkenine atanır.
   applyProcessing(): Seçilen filtreyi ve kaydırıcı ayarlarını uygulamak için applyProcessing fonksiyonu çağrılır.


    
    ```
    func setFilter(action: UIAlertAction) {
    guard currentImage != nil else { return }
    guard let actionTitle = action.title else { return }
    changeButton.setTitle(actionTitle, for: .normal)
    
    currentFilter = CIFilter(name: actionTitle)
    let beginImage = CIImage(image: currentImage)
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    applyProcessing()
     }




    ```
  </details>

  <details>
    <summary><h2>Filtre İşleme Fonksiyonu (applyProcessin)</h2></summary>
   currentFilter.inputKeys: Seçili filtreye uygun ayarlanabilir anahtarları alır.
   Her bir anahtar, filtreye kaydırıcı değerine göre belirli bir değişiklik uygulanmasına olanak tanır:
   kCIInputIntensityKey: Yoğunluk ayarı.
   kCIInputRadiusKey: Bulanıklık yarıçapı ayarı.
   kCIInputScaleKey: Ölçekleme.
   kCIInputCenterKey: Filtrenin merkezi.
   context.createCGImage: İşlenmiş CIImage’i UIImageView’da gösterilebilecek bir UIImage’e dönüştürür.


    
    ```
    func applyProcessing() {
    let inputKeys = currentFilter.inputKeys
    
    if inputKeys.contains(kCIInputIntensityKey) {
        currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
    }
    if inputKeys.contains(kCIInputRadiusKey) {
        currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
    }
    if inputKeys.contains(kCIInputScaleKey) {
        currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
    }
    if inputKeys.contains(kCIInputCenterKey) {
        currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
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





    ```
  </details>
  
  
<details>
    <summary><h2>Uygulama Görselleri </h2></summary>
    
    
 <table style="width: 100%;">
    <tr>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Kullanuici Arayuz</h4>
            <img src="https://github.com/user-attachments/assets/3e8b49b7-6d0c-40d4-a512-4fce6acd30fc" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Fotograf Albume Erisim</h4>
            <img src="https://github.com/user-attachments/assets/7ebdb9f5-3dea-4809-bac6-03360f102400" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Secilen Gorsel Editleme</h4>
            <img src="https://github.com/user-attachments/assets/9da7c3b6-6e8a-4429-a4d8-8e71dc4e4827" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Secilen gorselin deger kadar  Filtre Uygulanmis hali</h4>
            <img src="https://github.com/user-attachments/assets/837c4f03-6370-4835-97a0-83b76f7bb890" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Secilen gorselin deger kadar Pixell Filtre Uygulanmis hali</h4>
            <img src="https://github.com/user-attachments/assets/367e7913-6536-438a-b6e4-ca8d7738b3fd" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Filtre uygulanan gorselin kaydetme islemi</h4>
            <img src="https://github.com/user-attachments/assets/8b348947-f0b8-4b5a-9d0f-e40a7c811960" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Gorselin Albume Kaydedilmesi </h4>
            <img src="https://github.com/user-attachments/assets/2054eaba-177a-495a-9b41-d17a05393712" style="width: 100%; height: auto;">
        </td>
    </tr>
</table>
  </details> 
