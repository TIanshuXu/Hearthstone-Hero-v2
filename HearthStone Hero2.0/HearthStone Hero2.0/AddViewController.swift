//
//  AddViewController.swift
//  HearthStone Hero2.0
//
//  Created by Tianshu Xu on 01/04/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // outlets and actions
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var classNamePicker: UIPickerView!
    @IBOutlet weak var deckTypeTextField: UITextField!
    @IBOutlet weak var flavorTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var classImageView: UIImageView!
    @IBOutlet weak var heroPowerImageVIew: UIImageView!
    @IBOutlet weak var heroPowerPickerView: UIPickerView!
    @IBOutlet weak var frameImageView: UIImageView!
    @IBOutlet weak var blockTopImageView: UIImageView!
    @IBOutlet weak var blockBottomImageView: UIImageView!
    @IBOutlet weak var promptEffectView: UIVisualEffectView!
    @IBAction func pickImageAction(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            // setup the picker
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            // present the picker
            present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func addUpdateAction(_ sender: Any) {
        // distinguish if the managedObject is empty or not
        if heroManagedObject != nil {
            update()
        } else {
            save()
        }
        /* force navigation back to the Previous Controller */
        navigationController?.popViewController(animated: true)
    }
    
    // core data objects context, entity and managedObjects
    let context                       = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entity : NSEntityDescription! = nil
    var heroManagedObject : Hero!     = nil
    
    /* create a name with Timestamp for pickedImage */
    // learnt from https://stackoverflow.com/questions/24070450/how-to-get-the-current-time-as-datetime     Answer 20
    func timestamp()->String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd_HH_mm_ss" // year-mon-day_h_m_sec
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    // save a new managed object
    func save() {
        // make a new managed object
        heroManagedObject = Hero(context: context)
        // fill with data from textfield
        heroManagedObject.name       = nameTextField.text
        heroManagedObject.classname  = className
        heroManagedObject.heropower  = heroPower
        heroManagedObject.flavortext = flavorTextField.text
        heroManagedObject.url        = urlTextField.text
        heroManagedObject.decktype   = deckTypeTextField.text
        /* avoid the case that image from xml is renamed by clicking add/update button */
        if heroManagedObject.image == nil || !(heroManagedObject.image!.contains("Heroes_Profile")) {
            heroManagedObject.image  = timestamp() // when pick image button has't been pressed
        }
        // set default values
        if nameTextField.text!.isEmpty   {heroManagedObject.name = "Unnamed Hero"}
        if flavorTextField.text!.isEmpty {
            heroManagedObject.flavortext = "Surprisingly, this Hero did nothing!!"
        }
        if urlTextField.text!.isEmpty    {heroManagedObject.url = "google.com"}
        if deckTypeTextField.text!.isEmpty    {
            heroManagedObject.decktype = "Invincible" + timestamp()}
        //saveImage (if imageView have something to save)
        if pickedImageView.image != nil {
            saveImage(name: heroManagedObject.image!)
        }
        // save
        do    {try context.save()}
        catch {print("Core Data DOES NOT SAVE")}
    }
    // save heroManagedObject
    func update() {
        // fill with data from textfield
        heroManagedObject.name       = nameTextField.text
        heroManagedObject.classname  = className
        heroManagedObject.heropower  = heroPower
        heroManagedObject.flavortext = flavorTextField.text
        heroManagedObject.url        = urlTextField.text
        heroManagedObject.decktype   = deckTypeTextField.text
        /* avoid the case that image from xml is renamed by clicking add/update button */
        if heroManagedObject.image == nil || !(heroManagedObject.image!.contains("Heroes_Profile")) {
            heroManagedObject.image  = timestamp() // when pick image button has't been pressed
        }
        // set default values
        if nameTextField.text!.isEmpty   {heroManagedObject.name = "Unnamed Hero"}
        if flavorTextField.text!.isEmpty {
            heroManagedObject.flavortext = "Surprisingly, this Hero did nothing!!"
        }
        if urlTextField.text!.isEmpty    {heroManagedObject.url = "google.com"}
        if deckTypeTextField.text!.isEmpty    {
            heroManagedObject.decktype = "!nvincible" + timestamp()}
        //saveImage (if imageView have something to save)
        if pickedImageView.image != nil {
            saveImage(name: heroManagedObject.image!)
        }
        // save
        do    {try context.save()}
        catch {print("Core Data DOES NOT SAVE")}
    }
    
    // code to pickup an image from gallery
    let imagePicker = UIImagePickerController()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get the image from the picker
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        // place the image to imageview (and name it here)
        pickedImageView.image = image
        assistantImagesIsHidden(bool: false) // add a frame for picked images
        promptEffectView.isHidden = true // show that user has picked an image
        if heroManagedObject != nil && heroManagedObject.image!.contains("Heroes_Profile") {
            heroManagedObject.image = timestamp() // when pick image button has been pressed
        }
        // dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // save image data to file manager
    func saveImage(name: String) {
        // get file manager
        let fm = FileManager.default
        // find path to Documents
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        // append image name to path
        let path = docPath.appendingPathComponent(name)
        // grab image data
        let data = pickedImageView.image!.pngData()
        // file manager save data
        fm.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    // load image data from file manager
    func getImage(name: String) {
        // get file manager
        let fm = FileManager.default
        // find path to Documents
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        // append image name to path
        let path = docPath.appendingPathComponent(name)
        // test if name exists and load it
        if fm.fileExists(atPath: path) {pickedImageView.image = UIImage(contentsOfFile: path)}
        else                           {promptEffectView.isHidden = false}
    }
    
    func assistantImagesIsHidden(bool: Bool) {
        frameImageView.isHidden       = bool
        blockBottomImageView.isHidden = bool
        blockTopImageView.isHidden    = bool
        promptEffectView.isHidden     = bool
    }
    
    func showContent() {
        if heroManagedObject != nil {
            nameTextField.text      = heroManagedObject.name
            // save users' last changing by className and heroPower
            className               = heroManagedObject.classname!
            heroPower               = heroManagedObject.heropower!
            flavorTextField.text    = heroManagedObject.flavortext
            urlTextField.text       = heroManagedObject.url
            deckTypeTextField.text  = heroManagedObject.decktype
            // distinguish if the image is initial
            if heroManagedObject.image!.contains("Heroes_Profile") {
                pickedImageView.image = UIImage(named: heroManagedObject.image! + "/frame_00.png")
                assistantImagesIsHidden(bool: true) // only shows the profile
            } else {getImage(name: heroManagedObject.image!)}
            // select specific row in pickerView based on heropower and classname
            switch heroManagedObject.heropower {
                case "Unknown"        : heroPowerPickerView.selectRow(0, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[0])
                case "Fireblast"      : heroPowerPickerView.selectRow(1, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[1])
                case "Reinforce"      : heroPowerPickerView.selectRow(2, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[2])
                case "Dagger Mastery" : heroPowerPickerView.selectRow(3, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[3])
                case "Armor Up!"      : heroPowerPickerView.selectRow(4, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[4])
                case "Life Tap"       : heroPowerPickerView.selectRow(5, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[5])
                case "Totemic Call"   : heroPowerPickerView.selectRow(6, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[6])
                case "Lesser Heal"    : heroPowerPickerView.selectRow(7, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[7])
                case "Steady Shot"    : heroPowerPickerView.selectRow(8, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[8])
                case "Shapeshift"     : heroPowerPickerView.selectRow(9, inComponent: 0, animated: true)
                heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[9])
                default : break
            }
            switch heroManagedObject.classname {
                case "Undefined"    : classNamePicker.selectRow(0, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[0])
                case "Mage"         : classNamePicker.selectRow(1, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[1])
                case "Paladin"      : classNamePicker.selectRow(2, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[2])
                case "Rogue"        : classNamePicker.selectRow(3, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[3])
                case "Warrior"      : classNamePicker.selectRow(4, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[4])
                case "Warlock"      : classNamePicker.selectRow(5, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[5])
                case "Shaman"       : classNamePicker.selectRow(6, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[6])
                case "Priest"       : classNamePicker.selectRow(7, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[7])
                case "Hunter"       : classNamePicker.selectRow(8, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[8])
                case "Druid"        : classNamePicker.selectRow(9, inComponent: 0, animated: true)
                classImageView.image = UIImage(named: "Classes_Icon/" + classNames[9])
                default : break
            }
        } else { // heroManagedObject == nil, which means it's adding a new object
            /* pre-select a default option */
            heroPowerPickerView.selectRow(0, inComponent: 0, animated: true)
            classNamePicker.selectRow(0, inComponent: 0, animated: true)
            pickerView(heroPowerPickerView, didSelectRow: 0, inComponent: 0)
            pickerView(classNamePicker, didSelectRow: 0, inComponent: 0)
            heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[0])
            classImageView.image = UIImage(named: "Classes_Icon/" + classNames[0])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Add or Update"
        // setup the heroPowerPickerView and classNamePicker
        heroPowerPickerView.delegate   = self
        heroPowerPickerView.dataSource = self
        classNamePicker.delegate       = self
        classNamePicker.dataSource     = self
        // present the data of heromanagedObject
        showContent()
        // use these textFields as a storage, play a trick
        urlTextField.isHidden        = true
        flavorTextField.isHidden     = true
        deckTypeTextField.isHidden   = true
    }
    
    let heroPowers = ["Unknown", "Fireblast", "Reinforce", "Dagger Mastery", "Armor Up!", "Life Tap", "Totemic Call", "Lesser Heal", "Steady Shot", "Shapeshift"]
    let classNames = ["Undefined", "Mage", "Paladin", "Rogue", "Warrior", "Warlock", "Shaman", "Priest", "Hunter", "Druid"]
    var heroPower : String = "" // used for storing heroPower
    var className : String = "" // used for storing className
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == heroPowerPickerView {return heroPowers.count}
        else                                 {return classNames.count}
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == heroPowerPickerView {
            let pickerLabel = (view as? UILabel) ?? UILabel() // if nil assign UILabel()
            pickerLabel.font          = UIFont(name: "MarkerFelt-Wide", size: 20.0)
            pickerLabel.text          = heroPowers[row]
            pickerLabel.textColor     = UIColor(red: 1, green: 0.96, blue: 0.76, alpha: 1)
            pickerLabel.textAlignment = NSTextAlignment.left
            return pickerLabel
        } else {
            let pickerLabel = (view as? UILabel) ?? UILabel() // if nil assign UILabel()
            pickerLabel.font          = UIFont(name: "Helvetica-Bold", size: 25.0)
            pickerLabel.text          = classNames[row]
            pickerLabel.textAlignment = NSTextAlignment.left
            switch row {
                case 0 : pickerLabel.textColor = UIColor(red: 1, green: 0.08, blue: 0.58, alpha: 1)
                case 1 : pickerLabel.textColor = .cyan
                case 2 : pickerLabel.textColor = UIColor(red: 1, green: 0.65, blue: 0.98, alpha: 1)
                case 3 : pickerLabel.textColor = .yellow
                case 4 : pickerLabel.textColor = UIColor(red: 1, green: 0.85, blue: 0.55, alpha: 1)
                case 5 : pickerLabel.textColor = UIColor(red: 0.7, green: 0.25, blue: 1, alpha: 1)
                case 6 : pickerLabel.textColor = UIColor(red: 0.35, green: 0.5, blue: 1, alpha: 1)
                case 7 : pickerLabel.textColor = .white
                case 8 : pickerLabel.textColor = .green
                case 9 : pickerLabel.textColor = .orange
                default : break
            }
            return pickerLabel
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == heroPowerPickerView {
            heroPower                = heroPowers[row] // save heroPower to Core Data
            heroPowerImageVIew.image = UIImage(named: "Hero_Power/" + heroPowers[row])
        } else {
            className            = classNames[row] // save heroPower to Core Data
            classImageView.image = UIImage(named: "Classes_Icon/" + classNames[row])
        }
        
    }
    /* Change font and size by viewForRow learnt from https://stackoverflow.com/questions/33655015/changing-font-and-its-size-of-a-picker-in-swift/40900561 comment number 22 */
    /* Change font family learnt from https://stackoverflow.com/questions/9907100/issues-with-setting-some-different-font-for-uilabel comment number 36 */
    /* Select Row from viewDidLoad learnt from https://stackoverflow.com/questions/35708300/showing-uipickerview-with-selected-row */
    /* Change text color by attributedTitleForRow learnt from https://stackoverflow.com/questions/25900632/how-do-i-change-the-text-color-of-uipickerview-with-multiple-components-in-swift */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
