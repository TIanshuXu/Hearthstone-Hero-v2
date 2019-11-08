//
//  HeroTableViewController.swift
//  HearthStone Hero2.0
//
//  Created by Tianshu Xu on 01/04/2019.
//  Copyright © 2019 Tianshu Xu. All rights reserved.
//

import UIKit
import CoreData

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var cellNameLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
}

class HeroTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    @IBAction func resetAction(_ sender: UIBarButtonItem) {
        // make sure no contents are inside searchBar
        searchBar.text = ""
        searchBar(searchBar, textDidChange: "")
        /* if table isn't empty, ask if clear all data in Core data */
        if frc.sections![0].numberOfObjects != 0 {showClearActionSheet()}
        /* if the table is empty, show alert to ask fill table or not */
        if frc.sections![0].numberOfObjects == 0 {showFillTableAlert()}
    }
    @IBOutlet weak var clearOrFillBarItem: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // core data objects context, entity, managedObject and frc (FetchResultsController)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entity : NSEntityDescription! = nil
    var heroManagedObject : Hero!     = nil
    var frc : NSFetchedResultsController<NSFetchRequestResult>! = nil // make a new frc for filter
    var filterFRC : NSFetchedResultsController<NSFetchRequestResult>! = nil
    var heroesData : Heroes!
    var searchBarContent : String! = nil
    
    func makeRequest()->NSFetchRequest<NSFetchRequestResult>{
        // make a request for entity Hero
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Hero")
        // describe how to sort and how to filter it
        let sorter  = NSSortDescriptor(key: "decktype", ascending: true)
        request.sortDescriptors = [sorter]
        /* make a filter with case-insensitivity by ADDing [c] */
        // learnt from https://stackoverflow.com/questions/1473973/nspredicate-case-insensitive-matching-on-to-many-relationship Comment number 86 And https://nshipster.com/nspredicate/
        if searchBarOnChanged() {
            let namePredicate  = NSPredicate(format: "%K CONTAINS[c] %@", "name", searchBarContent)
            let classPredicate = NSPredicate(format: "%K CONTAINS[c] %@", "classname", searchBarContent)
            let orPredicate    = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate, classPredicate])
            request.predicate = orPredicate
        } else {
            request.predicate = nil
        }
        return request
    }
    
    func fromXMLToCoreData() {
        // XMLParse with init of Heroes and this is an array of Heroes
        heroesData = Heroes(fromContentOfXML: "heroes.xml")
        // traverse the array of Heroes
        for i in 0..<heroesData.count() {
            // make a new managed object
            heroManagedObject = Hero(context: context)
            // managedObject fill with data from array
            heroManagedObject.name       = heroesData.heroesData[i].name
            heroManagedObject.classname  = heroesData.heroesData[i].className
            heroManagedObject.heropower  = heroesData.heroesData[i].heroPower
            heroManagedObject.decktype   = heroesData.heroesData[i].deckType
            heroManagedObject.flavortext = heroesData.heroesData[i].flavorText
            heroManagedObject.image      = heroesData.heroesData[i].image
            heroManagedObject.url        = heroesData.heroesData[i].url
            // save to context
            do    {try context.save()}
            catch {print("Core Data DOES NOT SAVE")}
        }
        controllerDidChangeContent(frc) // content changed (force respond)
    }
    
    func resetEntity() {
        /* This is leartn from https://stackoverflow.com/questions/1383598/core-data-quickest-way-to-delete-all-instances-of-an-entity at the comment number 28 */
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Hero")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
            try frc.performFetch()
        } catch {print("Entity CAN'T BE RESET")}
        controllerDidChangeContent(frc) // content changed (force respond)
    }
    
    func showFillTableAlert() {
        /* this snipet of codes can generate a message box, learnt from https://stackoverflow.com/questions/25212913/swift-message-box */
        let alert = UIAlertController(title: "Would you like to fill your table with default data?", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
            self.fromXMLToCoreData() // fetch all data from XML
        }))
        self.present(alert, animated: true)
    }
    
    func showClearActionSheet() {
        /* change the attributes of action sheet, learnt from https://stackoverflow.com/questions/26460706/uialertcontroller-custom-font-size-color at the comment number 27 */
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let font  = [NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 18.0)!]
        let attrString = NSMutableAttributedString(string: "Would you like to clear your data?", attributes: font)
        alert.setValue(attrString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: {action in
            self.resetEntity() // clear all data in Core data
        }))
        self.present(alert, animated: true)
    }

    func getImage(name: String)->UIImage{
        // get file manager
        let fm = FileManager.default
        // find path to Documents
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        // append image name to path
        let path = docPath.appendingPathComponent(name)
        // test if name exists and load it (also consider if image is picked)
        if fm.fileExists(atPath: path) && UIImage(contentsOfFile: path) != nil {
            return UIImage(contentsOfFile: path)!
        } else { // user didn't pick a image, use a default one
            return UIImage(named: "Unnamed/for_avatar.jpg")!
        }
    }
    
    // get content typed in the searchBar, learnt from https://stackoverflow.com/questions/38971807/swift-uisearchcontroller-when-select-item-search-bar-is-still-there comment number 0
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Pass contents typed by user to a global var
        searchBarContent = searchText
        // make a new frc called filterFRC and fetch
        filterFRC = NSFetchedResultsController(fetchRequest: makeRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        /* catch exception, to perform the fetch */
        do    {try filterFRC.performFetch()}
        catch {print("FETCH DOES NOT WORK")}
        tableView.reloadData()
    }
    func searchBarOnChanged()->Bool{return searchBarContent != nil && searchBarContent != ""}

    override func viewDidLoad() {
        super.viewDidLoad()
        // show image directory, will be deleted latter
        print(NSHomeDirectory())
        title = "Hero"
        // setup the searchBar
        searchBar.delegate = self
        // make frc and fetch
        frc = NSFetchedResultsController(fetchRequest: makeRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self // setup the frc for filter aswell
        /* catch exception, to perform the fetch */
        do    {try frc.performFetch()}
        catch {print("FETCH DOES NOT WORK")}
        /* checkEmptyAndParseXML() // old method to populate data if tabel is empty */
        /* new way to check if entity is empty */
        if frc.sections![0].numberOfObjects == 0 {
            clearOrFillBarItem.title = "Clear"
            fromXMLToCoreData() // init while empty
        }
    }
    
    /*
    /* this is the old approach, won't be used anymore */
    func checkEmptyAndParseXML() {
        /* check if the entity is empty */
        //learnt from https://stackoverflow.com/questions/29769826/how-to-check-if-the-core-data-was-empty-swift
        var entityIsEmpty : Bool {
            do {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Hero")
                let count  = try context.count(for: request)
                return count == 0
            } catch {return true}
        } /* populate data from xml if the entity is empty */
        if entityIsEmpty {fromXMLToCoreData()}
    } */
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /* detect any changes, if table is empty, show Fill, or Clear */
        if frc.sections![0].numberOfObjects != 0 {clearOrFillBarItem.title = "Clear"}
        if frc.sections![0].numberOfObjects == 0 {clearOrFillBarItem.title = "Fill"
            showFillTableAlert()}
        tableView.reloadData() // reload once content is changed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // perform fetch and reload table
        do    {try frc.performFetch()}
        catch {print("FETCH DOES NOT WORK")}
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        /* print(section) // this is used to check how many sections there are */
        if searchBarOnChanged() {return filterFRC.sections![section].numberOfObjects}
        else                    {return frc.sections![section].numberOfObjects}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        // get from frc the object at indexPath
        if searchBarOnChanged() {heroManagedObject = (filterFRC.object(at: indexPath) as! Hero)}
        else                    {heroManagedObject = (frc.object(at: indexPath) as! Hero)}
        // Configure the cell...
        cell.cellNameLabel.text  = heroManagedObject.name
        // distinguish if the image is initial
        if heroManagedObject.image!.contains("Heroes_Profile") {
            cell.cellImageView.image     = UIImage(named: heroManagedObject.image!+"/artWork.jpg")
            cell.cellNameLabel.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        } else {
            cell.cellImageView.image     = getImage(name: heroManagedObject.image!)
            // if user didn't pick up a name, change text color
            if heroManagedObject.name == "Unnamed Hero" {
                cell.cellNameLabel.textColor   = UIColor(red: 1, green: 0.08, blue: 0.58, alpha: 1)
            } else { // user customised hero
                cell.cellNameLabel.textColor   = UIColor(red: 0.67, green: 0.49, blue: 1, alpha: 1)
            }
        }
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /* Delete the row from the data source */
            // get the object to remove and delete it
            if searchBarOnChanged() {heroManagedObject = (filterFRC.object(at: indexPath) as! Hero)}
            else                    {heroManagedObject = (frc.object(at: indexPath) as! Hero)}
            context.delete(heroManagedObject)
            // save the context
            do {try context.save()}     catch {print("Core Data DOES NOT SAVE")}
            // perform fetch and reload
            if searchBarOnChanged() {do {try filterFRC.performFetch()} catch {print("FETCH DOES NOT WORK")}}
            else                    {do {try frc.performFetch()}       catch {print("FETCH DOES NOT WORK")}}
            tableView.reloadData() // will also be executed in controllerDidChangeContent
        } // insert option has been removed
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue" {
            // Get the new view controller using segue.destination.
            let destination = segue.destination as! HeroInfoViewController
            // Pass the selected indexPath to the new view controller.
            let cellIndexPath = tableView.indexPath(for: sender as! UITableViewCell)
            // depends on which cell is clicked, assign data to heroManagedObject
            if searchBarOnChanged() {heroManagedObject = (filterFRC.object(at: cellIndexPath!) as! Hero)}
            else                    {heroManagedObject = (frc.object(at: cellIndexPath!) as! Hero)}
            // by using the specific Object, we can get its indexPath in frc
            let frcIndexPath = frc.indexPath(forObject: heroManagedObject)
            // only the frcIndexPath and frc need to be pushed
            destination.indexPath = frcIndexPath!
            destination.frc = frc
            // make sure no contents are inside searchBar
            searchBar.text = ""
            searchBar(searchBar, textDidChange: "")
        } else if segue.identifier == "addSegue" {
            // make sure no contents are inside searchBar
            searchBar.text = ""
            searchBar(searchBar, textDidChange: "")
        }
    }
}
/* get frc indexPath by frc.indexPath(forObject: ) learnt from https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller */
