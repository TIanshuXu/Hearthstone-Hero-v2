//
//  HeroInfoViewController.swift
//  Hearthstone Hero
//
//  Created by Tianshu Xu on 04/03/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import UIKit
import CoreData

class HeroInfoViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // outlets and actions
    @IBOutlet weak var heroLabel: UILabel!
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var heroPowerLabel: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var classImageView: UIImageView!
    @IBOutlet weak var heroPowerImageView: UIImageView!
    @IBOutlet weak var demoLabel: UILabel!
    @IBOutlet weak var frameImageView: UIImageView!
    @IBOutlet weak var blockTopImageView: UIImageView!
    @IBOutlet weak var blockBottomImageView: UIImageView!
    @IBOutlet weak var promptEffectView: UIVisualEffectView!
    @IBAction func moreInfoAction(_ sender: Any) {
        // nothing to do
        //getImage(name: heroData.image!)
    }
    
    var heroData  : Hero!
    var indexPath : IndexPath = []
    var frc : NSFetchedResultsController<NSFetchRequestResult>!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func animateAvatar() {
        // make image array and name array
        var framesNames = [String]()
        var frames      = [UIImage]()
        // traverse and fill name and image array
        for i in 0..<30{
            if i<10{
                framesNames.append("frame_0" + String(i) + ".png")
            } else {
                framesNames.append("frame_" + String(i) + ".png")
            }
            frames.append(UIImage(named: heroData.image!+"/"+framesNames[i])!)
        }
        // set animation
        heroImageView.animationImages   = frames
        heroImageView.animationDuration = 4
        heroImageView.startAnimating()
    }
    
    func getImage(name: String) {
        // get file manager
        let fm = FileManager.default
        // find path to Documents
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        // append image name to path
        let path = docPath.appendingPathComponent(name)
        // test if name exists and load it
        if fm.fileExists(atPath: path) {
            heroImageView.image       = UIImage(contentsOfFile: path)
            promptEffectView.isHidden = true     // user has an image
            assistantImagesIsHidden(bool: false) // contributes to artistic style
        } else { // user didn't pick a image, use a default one
            heroImageView.image       = UIImage(named: "Unnamed/Unnamed.jpg")
            promptEffectView.isHidden = false // prompt user to pickup an image
        }
    }
    
    func fetchFromContext() {
        // setup frc and fetch
        frc.delegate = self
        /* catch exception, to perform the fetch */
        do    {try frc.performFetch()}
        catch {print("FETCH DOES NOT WORK")}
        // assign the object in frc to heroData
        heroData = (frc.object(at: indexPath) as! Hero)
    }
    
    func assistantImagesIsHidden(bool: Bool) {
        frameImageView.isHidden       = bool
        blockBottomImageView.isHidden = bool
        blockTopImageView.isHidden    = bool
    }
    
    func showContent() {
        //populate outlets with data
        heroLabel.text           = heroData.name
        classNameLabel.text      = heroData.classname
        heroPowerLabel.text      = heroData.heropower
        classImageView.image     = UIImage(named: "Classes_Icon/" + heroData.classname!)
        heroPowerImageView.image = UIImage(named: "Hero_Power/" + heroData.heropower!)
        // make sure heroData.image is initialed from xml
        if heroData.image!.contains("Heroes_Profile") {
            heroImageView.image = UIImage(named: heroData.image! + "/frame_00.png")
            assistantImagesIsHidden(bool: true) // show profile only
            animateAvatar()
        } else {
            heroImageView.stopAnimating()
            getImage(name: heroData.image!)
        }
        // match classes color
        switch heroData.classname{
            case "Undefined" : classNameLabel.textColor = UIColor(red: 1, green: 0.08, blue: 0.58, alpha: 1)
            case "Mage"      : classNameLabel.textColor = UIColor.cyan
            case "Paladin"   : classNameLabel.textColor = UIColor(red: 1, green: 0.65, blue: 0.98, alpha: 1)
            case "Rogue"     : classNameLabel.textColor = UIColor.yellow
            case "Warrior"   : classNameLabel.textColor = UIColor(red: 1, green: 0.85, blue: 0.55, alpha: 1)
            case "Warlock"   : classNameLabel.textColor = UIColor(red: 0.7, green: 0.25, blue: 1, alpha: 1)
            case "Shaman"    : classNameLabel.textColor = UIColor(red: 0.35, green: 0.5, blue: 1, alpha: 1)
            case "Priest"    : classNameLabel.textColor = UIColor.white
            case "Hunter"    : classNameLabel.textColor = UIColor.green
            case "Druid"     : classNameLabel.textColor = UIColor.orange
            default          : break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // reload once content is changed
        self.viewDidLoad()
        self.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /* reload content when something's been changed */
        fetchFromContext()
        /* present the data */
        showContent()
        // change the title
        self.title = heroData.name
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editSegue" {
            // Get the new view controller using segue.destination.
            let destination      = segue.destination as! AddViewController
            // Pass data to the new view controller.
            destination.heroManagedObject = heroData
        } else {
            let destination      = segue.destination as! HeroDetailsViewController
            destination.heroData = heroData
        }
    }
}
