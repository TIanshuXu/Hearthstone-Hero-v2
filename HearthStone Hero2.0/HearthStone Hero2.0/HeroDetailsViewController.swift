//
//  HeroDetailsViewController.swift
//  Hearthstone Hero
//
//  Created by Tianshu Xu on 04/03/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import UIKit

class HeroDetailsViewController: UIViewController {

    // outlets and actions
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var heroPowerLabel: UILabel!
    @IBOutlet weak var deckTypeLabel: UILabel!
    @IBOutlet weak var flavorTextLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var flavorLabel: UILabel!
    @IBAction func webInfoAction(_ sender: Any) {
        // nothing to do
    }
    
    var heroData : Hero!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = heroData.name
        
        // heroData is pushed from last Screen
        
        // populate outlets with data
        nameLabel.text       = heroData.name
        classNameLabel.text  = heroData.classname
        heroPowerLabel.text  = heroData.heropower
        deckTypeLabel.text   = heroData.decktype
        flavorTextLabel.text = heroData.flavortext
        // make user defined decktype Invincible
        if deckTypeLabel.text!.contains("Invincible") {deckTypeLabel.text = "Invincible"}
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
    
    // Add Animation!!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameLabel.center.x       += view.bounds.width
        classNameLabel.center.x  += view.bounds.width
        heroPowerLabel.center.x  += view.bounds.width
        deckTypeLabel.center.x   += view.bounds.width
        flavorTextLabel.alpha    -= 1
        classLabel.alpha         -= 1
        powerLabel.alpha         -= 1
        typeLabel.alpha          -= 1
        flavorLabel.alpha        -= 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                       animations: {
                        self.nameLabel.center.x -= self.view.bounds.width
                       }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseIn],
                       animations: {
                        self.classNameLabel.center.x -= self.view.bounds.width
                       }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: [.curveEaseIn],
                       animations: {
                        self.heroPowerLabel.center.x -= self.view.bounds.width
                       }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.6, options: [.curveEaseIn],
                       animations: {
                        self.deckTypeLabel.center.x -= self.view.bounds.width
                       }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 1.2, options: [],
                       animations: {
                        self.flavorTextLabel.alpha  = 1
                       }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [],
                       animations: {
                        self.classLabel.alpha       = 1
                       }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: [],
                       animations: {
                        self.powerLabel.alpha       = 1
                       }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.6, options: [],
                       animations: {
                        self.typeLabel.alpha        = 1
                       }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.9, options: [],
                       animations: {
                        self.flavorLabel.alpha      = 1
                       }, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destination = segue.destination as! HeroWebViewController
        
        // Pass the selected object to the new view controller.
        destination.urlData = heroData.url
    }
}
