import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    private let context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        let filter = CIFilter.colorControls()
        filter.brightness = 1 // Ranges are determined by the filter / documentation
        //print(filter.attributes)
        
        originalImage = imageView.image
	}
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Filtering
        let filter = CIFilter.colorControls() // May not work for some custom filters (KVC protocol)
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        // CIImage -> CGImage -> UIImage
        guard let outputCIImage = filter.outputImage else { return nil }
        
        //Render image
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func updateViews() {
        guard let originalImage = originalImage else { return }
        imageView.image = filterImage(originalImage)
    }
    
	// MARK: Actions
	
	@IBAction func choosePhotoButtonPressed(_ sender: Any) {
		// TODO: show the photo picker so we can choose on-device photos
		// UIImagePickerController + Delegate
        presentImagePickerController()
	}
	
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
		// TODO: Save to photo library
	}
	

	// MARK: Slider events
	
	@IBAction func brightnessChanged(_ sender: UISlider) {
        updateViews()
	}
	
	@IBAction func contrastChanged(_ sender: Any) {
        updateViews()
	}
	
	@IBAction func saturationChanged(_ sender: Any) {
        updateViews()
	}
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        dismiss(animated: true) {
            DispatchQueue.main.async {
                self.contrastSlider.value = 1
                self.brightnessSlider.value = 0
                self.saturationSlider.value = 1
                self.updateViews()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoFilterViewController: UINavigationControllerDelegate {
    
}
