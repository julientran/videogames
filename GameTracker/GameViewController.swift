//
//  GameViewController.swift
//  GameTracker
//
//

import UIKit
import BarcodeScanner

class GameViewController: UIViewController, /* protocols */ UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let platforms = ["", "PS4", "Switch"]
    // MARK: Properties
    
    @IBOutlet weak var platformTextField: UITextField!
    @IBOutlet weak var idgameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var DiscOrDigital: UISegmentedControl!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var publisherTextField: UITextField!
    
    var scanValueName : String!
    var scanValuePlatform : String!
    
    
    
    //@IBOutlet weak var pushScannerButton: UIBarButtonItem!
    //@IBOutlet var presentScannerButton: UIButton!
    @IBOutlet var pushScannerButton: UIButton!
    
    @IBAction func handleScannerPresent(_ sender: Any, forEvent event: UIEvent) {
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func handleScannerPush(_ sender: Any, forEvent event: UIEvent) {
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        return viewController
    }
    
    /*
     This value is either passed by `GameTableViewController` in `prepareForSegue(_:sender:)`
     @IBOutlet weak var idgameLabel: UILabel!
     or constructed as part of adding a new game.
     */
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.nameTextField.delegate = self
        self.platformTextField.delegate = self
        self.publisherTextField.delegate = self
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.89, green:0.09, blue:0.14, alpha:1.0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.photoImageView.clipsToBounds = true
        self.photoImageView.layer.cornerRadius = 50
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        platformTextField.inputView = pickerView
        
        // Set up views if editing an existing Game.
        if let game = game {
            navigationItem.title = game.name
            platformTextField.text = game.platform
            nameTextField.text   = game.name
            publisherTextField.text   = game.publisher
            photoImageView.image = game.photo
            DiscOrDigital.selectedSegmentIndex = game.dord
            doneSwitch.isOn = game.done
            idgameLabel.text = game.idgame
        }
        
        // Enable the Save button only if the text field has a valid Game name.
        checkValidGameName()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func checkValidGameName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return platforms.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return platforms[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        platformTextField.text = platforms[row]
        //close pickerView after editing
        self.view.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(nameTextField: UITextField!) -> Bool {
        nameTextField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidGameName()
        navigationItem.title = textField.text
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddGameMode = presentingViewController is UINavigationController
        
        if isPresentingInAddGameMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = sender as? UIBarButtonItem { // M.Ban Swift 2 --> Swift 3
            if saveButton === s {
                let idgame = idgameLabel.text == "" ? UUID().uuidString : idgameLabel.text
                let name = nameTextField.text ?? ""
                let photo = photoImageView.image
                let dord = DiscOrDigital.selectedSegmentIndex
                let done = doneSwitch.isOn
                let publisher = publisherTextField.text ?? ""
                let platform = platformTextField.text ?? ""
                //let rating = ratingControl.rating
                
                // Set the game to be passed to GameTableViewController after the unwind segue.
                game = Game(idgame: idgame!, name: name, photo: photo, dord: dord, platform: platform, done: done, publisher: publisher)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard (just in case).
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    /*
     @IBAction func setDefaultLabelText(sender: UIButton) {
     gameNameLabel.text = "Default Text"
     }
     */
    
}

extension String {
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func slices(from: String, to: String) -> [Substring] {
        let pattern = "(?<=" + from + ").*?(?=" + to + ")"
        return ranges(of: pattern, options: .regularExpression)
            .map{ self[$0] }
    }
}

// MARK: - BarcodeScannerCodeDelegate

extension GameViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        print("Symbology Type: \(type)")
        var bcode = code
        if(bcode.count == 12){
            bcode = "0" + bcode
        }
        let itemListURL = URL(string: "https://www.consollection.com/comparateur-jeu-video/\(bcode).php")!
        let itemListHTML = try! String(contentsOf: itemListURL, encoding: .utf8)
        let result = itemListHTML.slices(from: "<h1>", to: "</h1>")
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if(result[0] == "Comparez les prix des jeux vid&eacute;o") {
                
                controller.resetWithError()
                
            } else {
                
                let scanPublisher = itemListHTML.slices(from: "Distributeur du jeu : <strong>", to: "</strong>")
                let url = URL(string: String(itemListHTML.slices(from: " src=\"", to: "\" style=\"width:100%;")[0]))
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                let scanPhoto: UIImage? = UIImage(data: data!)
                self.scanValueName = String(result[0])
                //scanValueName = String(String(result[0]).slices(from: "", to: "PS4")[0])
                
                if(self.scanValueName.contains("PS4")){
                    self.scanValuePlatform = "PS4"
                    self.scanValueName = String(self.scanValueName.slices(from: "", to: "PS4")[0])
                }
                
                if(self.scanValueName.contains("Nintendo Switch")){
                    self.scanValuePlatform = "Switch"
                    self.scanValueName = String(self.scanValueName.slices(from: "", to: "Nintendo Switch")[0])
                }
                
                controller.dismiss(animated: true, completion: { () in self.nameTextField.text = self.scanValueName;
                    self.platformTextField.text = self.scanValuePlatform;
                    self.publisherTextField.text = String(scanPublisher[0]);
                    self.photoImageView.image = scanPhoto;
                    self.checkValidGameName() })
                
            }
        }
        
    }
}

// MARK: - BarcodeScannerErrorDelegate

extension GameViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

// MARK: - BarcodeScannerDismissalDelegate

extension GameViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

private extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

@IBDesignable class MaskView: UIView {
    let startAngle: CGFloat = 180
    let endAngle: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // The multiplier determine how big the circle is
        let multiplier: CGFloat = 3.0
        let radius: CGFloat = frame.size.width * multiplier
        let maskLayer = CAShapeLayer()
        let arcCenter = CGPoint(x: frame.size.width / 2, y: radius)
        maskLayer.path = UIBezierPath(arcCenter: arcCenter,
                                      radius: radius,
                                      startAngle: startAngle.degreesToRadians,
                                      endAngle: endAngle.degreesToRadians,
                                      clockwise: true).cgPath
        layer.mask = maskLayer
    }
}



