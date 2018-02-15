//
//  WishViewController.swift
//  WishTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Julien Tran. All rights reserved.
//

import UIKit
import BarcodeScanner

class WishViewController: UIViewController, /* protocols */ UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var releaseDateTextField: UITextField!
    @IBOutlet weak var platformTextField: UITextField!
    @IBOutlet weak var idwishLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var saveWishButton: UIBarButtonItem!
    
    @IBOutlet weak var buySwitch: UISwitch!
    @IBOutlet weak var publisherTextField: UITextField!
    
    var scanValueName : String!
    var scanValuePlatform : String!
    
    //var textField = UITextField()
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    
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
     This value is either passed by `WishTableViewController` in `prepareForSegue(_:sender:)`
     @IBOutlet weak var idwishLabel: UILabel!
     or constructed as part of adding a new wish.
     */
    var wish: Wish?
    var listFilters : [String] = []
    
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
        
        createDatePicker()
        createToolBar()
        addTextField()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        platformTextField.inputView = pickerView
        buySwitch.isEnabled = false
        // Set up views if editing an existing Wish.
        if let wish = wish {
            navigationItem.title = wish.name
            platformTextField.text = wish.platform
            nameTextField.text   = wish.name
            publisherTextField.text   = wish.publisher
            photoImageView.image = wish.photo
            releaseDateTextField.text = wish.releasedate
            idwishLabel.text = wish.idwish
            buySwitch.isEnabled = true
        }
        
        // Enable the Save button only if the text field has a valid Wish name.
        checkValidWishName()
    }
    func addTextField() {
        releaseDateTextField.inputView = datePicker
        releaseDateTextField.inputAccessoryView = toolBar
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(datePicker:)), for: .valueChanged)
    }
    
    func createToolBar() {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(todayButtonPressed(sender:)))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        label.text = "Choose your Date"
        let labelButton = UIBarButtonItem(customView:label)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([todayButton,flexibleSpace,labelButton,flexibleSpace,doneButton], animated: true)
    }
    
    @objc func todayButtonPressed(sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        releaseDateTextField.text = dateFormatter.string(from: Date())
        
        releaseDateTextField.resignFirstResponder()
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        releaseDateTextField.resignFirstResponder()
    }
    
    @objc func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        releaseDateTextField.text = dateFormatter.string(from: datePicker.date)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func checkValidWishName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        navigationItem.title = text
        saveWishButton.isEnabled = !text.isEmpty
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listFilters.count
    }
    
    // This function sets the text of the picker view to the content of the "platform" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        listFilters[0] = ""
        if(!listFilters.contains("Other")) {
            listFilters.append("Other")
        }
        return listFilters[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(listFilters[row] == "Other"){
            platformTextField.inputView = nil
            platformTextField.text = ""
            platformTextField.reloadInputViews()
            platformTextField.becomeFirstResponder()
        } else {
            platformTextField.text = listFilters[row]
            //close pickerView after editing
            self.view.endEditing(true)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(nameTextField: UITextField!) -> Bool {
        nameTextField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        //saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidWishName()
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
        let isPresentingInAddWishMode = presentingViewController is UINavigationController
        
        if isPresentingInAddWishMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = sender as? UIBarButtonItem { // M.Ban Swift 2 --> Swift 3
            if saveWishButton === s {
                let idwish = idwishLabel.text == "" ? UUID().uuidString : idwishLabel.text
                let name = nameTextField.text ?? ""
                let photo = photoImageView.image
                let releasedate = releaseDateTextField.text ?? ""
                let buy = buySwitch.isOn
                let publisher = publisherTextField.text ?? ""
                let platform = platformTextField.text ?? ""
                
                // Set the wish to be passed to WishTableViewController after the unwind segue.
                wish = Wish(idwish: idwish!, name: name, photo: photo,platform: platform, buy: buy, publisher: publisher, releasedate: releasedate)
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
}

// MARK: - BarcodeScannerCodeDelegate

extension WishViewController: BarcodeScannerCodeDelegate {
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
                    self.checkValidWishName() })
            }
        }
        
    }
}

// MARK: - BarcodeScannerErrorDelegate

extension WishViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

// MARK: - BarcodeScannerDismissalDelegate

extension WishViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

private extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}





