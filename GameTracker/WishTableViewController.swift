//
//  WishTableViewController.swift
//  WishTracker
//
//

import UIKit

class WishTableViewController: UITableViewController, UISearchBarDelegate{
    
    var listFilters : [String] = []
    
    @IBOutlet var tableWish: UITableView!
    @IBOutlet weak var searchBarWish: UISearchBar!
    
    
    // MARK: Properties
    
    var currentSearchText = ""
    var wishes = [Wish]()
    var currentWishesArray = [Wish]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The next line is the crucial part
        // The action is where Swift 3 varies from previous versions
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.89, green:0.09, blue:0.14, alpha:1.0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let image = UIImage(named: "Logo")
        navigationItem.titleView = UIImageView(image: image)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved wishes, otherwise load sample data.
        if let savedWishes = loadWishes() {
            wishes += savedWishes
            currentWishesArray = wishes
            printWishes() // Debug
        }
        else {
            // Load the sample data.
            loadSampleWishes()
        }
        setUpSearchBar()
    }
    
    private func setUpSearchBar(){

        listFilters = []
        listFilters.append("All")

        for wish in wishes {
            if (!listFilters.contains(wish.platform) && wish.platform != "" ) {
                if(listFilters.count < 5) {
                    listFilters.append(wish.platform)
                }
            }
        }
        
        searchBarWish.delegate = self
        self.searchBarWish.isTranslucent = false
        self.searchBarWish.backgroundImage = UIImage()
        self.searchBarWish.scopeButtonTitles = listFilters
        self.searchBarWish.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [type(of: self.searchBarWish)]).tintColor = .darkGray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func loadSampleWishes() {
        let photo1 = UIImage(named: "Sample")!
        let wish1 = Wish(idwish: "idnil", name: "Rayman Legends", photo: photo1, platform: "PS4", buy: false, publisher: "Ubisoft", releasedate: "")
        wishes += [wish1]
        currentWishesArray = wishes
        saveWishes()
        tableWish.reloadData()
        printWishes() // Debug
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        guard !searchText.isEmpty else {
            currentWishesArray = wishes;
            searchBarWish.selectedScopeButtonIndex = 0;
            currentSearchText = ""
            tableWish.reloadData()
            return
        }
        if(searchBarWish.selectedScopeButtonIndex == 0) {
            currentWishesArray = wishes;
        }
        if(searchBarWish.selectedScopeButtonIndex == 1) {
            currentWishesArray = wishes;
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[1]
            })
        }
        if(searchBarWish.selectedScopeButtonIndex == 2) {
            currentWishesArray = wishes;
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[2]
            })
        }
        if(searchBarWish.selectedScopeButtonIndex == 3) {
            currentWishesArray = wishes;
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[3]
            })
        }
        if(searchBarWish.selectedScopeButtonIndex == 4) {
            currentWishesArray = wishes;
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[4]
            })
        }
        if(searchBarWish.selectedScopeButtonIndex == 5) {
            currentWishesArray = wishes;
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[5]
            })
        }
        currentWishesArray = filterWishes(wishesForFilter: currentWishesArray, searchTextForFilter: searchText)
        currentSearchText = searchText
        tableWish.reloadData()
    }
    
    func filterWishes(wishesForFilter: [Wish], searchTextForFilter: String) -> [Wish] {
        searchBarWish.prompt = "0 wish"
        return wishesForFilter.filter({ wish -> Bool in
            (wish.name.lowercased().contains(searchTextForFilter.lowercased()) || wish.publisher.lowercased().contains(searchTextForFilter.lowercased()))
        })
    }
    
    func searchBarWish(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        switch selectedScope {
        case 0:
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes
            }
        case 1:
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes
            }
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[1]
            })
        case 2:
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes
            }
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[2]
            })
        case 3:
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes
            }
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[3]
            })
        case 4:
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes
            }
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[4]
            })
        case 5:
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes
            }
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[5]
            })
        default:
            break
        }
        tableWish.reloadData()
    }
    
    func printWishes() {
        var i = 0
        for wish in currentWishesArray {
            print("wish: [\(i)] '\(wish.name)'") // Debug
            i += 1
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWishesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "WishTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WishTableViewCell
        
        // Fetches the appropriate wish for the data source layout.
        let wish = currentWishesArray[indexPath.row]
        cell.nameLabel.text = wish.name
        cell.photoImageView.image = wish.photo
        cell.releasedateLabel.text = wish.releasedate
        cell.platformLabel.text = wish.platform
        cell.publisherLabel.text = wish.publisher
        cell.idwishLabel.text = wish.idwish
        
        searchBarWish.prompt = currentWishesArray.count < 2  ? String(currentWishesArray.count) + " wish" : String(currentWishesArray.count) + " wishes"
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("at: \(indexPath.row)") // Debug
        if editingStyle == .delete {
            searchBarWish.prompt = "0 wish"
            // Delete the row from the data source
            deleteWish(wish: currentWishesArray[indexPath.row])
            
        } else if editingStyle == .insert {
            setUpSearchBar()
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        print("from: \(fromIndexPath.row), to: \(toIndexPath.row)") // Debug
        let wish = currentWishesArray.remove(at: fromIndexPath.row)
        currentWishesArray.insert(wish, at: toIndexPath.row)
        saveWishes()
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailWish" {
            let wishDetailViewController = segue.destination as! WishViewController // If the cast is unsuccessful, the app should crash at runtime.
            wishDetailViewController.listFilters = self.listFilters
            // Get the cell that generated this segue.
            if let selectedWishCell = sender as? WishTableViewCell {
                let indexPath = tableView.indexPath(for: selectedWishCell)!
                let selectedWish = currentWishesArray[indexPath.row]
                wishDetailViewController.wish = selectedWish
            }
        }
        else if segue.identifier == "AddWish" {

            let navVC = segue.destination as? UINavigationController
            let formVC = navVC?.viewControllers.first as! WishViewController
            formVC.listFilters = self.listFilters
            
            searchBarWish.selectedScopeButtonIndex = 0;
            searchBarWish.text = ""
            currentWishesArray = wishes
            tableWish.reloadData()
            print("Adding new wish.")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    
    func deleteWish(wish :Wish) {
        var j = 0
        for i in 0..<wishes.count { // N'oubliez pas que l'indice d'un tableau débute à 0
            if( wishes[i].idwish == wish.idwish ){
                j = i
            }
        }
        let wishesPath = IndexPath(row: j, section: 0)
        
        wishes.remove(at: wishesPath.row)
        listFilters = []
        setUpSearchBar()
        searchBarWish.selectedScopeButtonIndex = 0;
        searchBarWish.text = ""
        currentWishesArray = wishes
        saveWishes()
        tableWish.reloadData()
    }
    
    // MARK: Actions
    @IBAction func unwindToWishList(_ sender: UIStoryboardSegue) {
        if((sender.source as? WishViewController)?.wish?.buy)!{
            
            let wish : Wish = ((sender.source as? WishViewController)?.wish)!
            //let vc = GameTableViewController(nibName: "GameTableViewController", bundle: nil)
            //vc.changeToBuy(wish: wish)

            let tbc = self.parent?.parent as! TabBarController
            print(tbc.statut)
            
            let gvc : GameTableViewController  = tbc.childViewControllers[0].childViewControllers[0] as! GameTableViewController
            print (gvc.changeToBuy(wish: wish))
            
            //Delete
            deleteWish(wish: wish)
    
            
        } else {
            var j = 0
            if let sourceViewController = sender.source as? WishViewController, let wish = sourceViewController.wish {
                if tableView.indexPathForSelectedRow != nil {
                    // Update an existing wish.
                    
                    for i in 0..<wishes.count { // N'oubliez pas que l'indice d'un tableau débute à 0
                        if( wishes[i].idwish == wish.idwish ){
                            j = i
                        }
                    }
                    let wishesPath = IndexPath(row: j, section: 0)
                    wishes[wishesPath.row] = wish
                    searchBarWish.selectedScopeButtonIndex = 0;
                    searchBarWish.text = ""
                    currentWishesArray = wishes
                    tableWish.reloadData()

                    tableView.reloadRows(at: [wishesPath], with: .none)
                }
                else {
                    // Add a new wish.
                    let newIndexPath = IndexPath(row: wishes.count, section: 0)
                    wishes.append(wish)
                    currentWishesArray = wishes
                    tableView.insertRows(at: [newIndexPath], with: .bottom)
                }
                // Save the wishes.
                saveWishes()
            }
        }
    }
    
    // MARK: NSCoding
    
    func saveWishes() {
        setUpSearchBar()
        do {
            let data = try PropertyListEncoder().encode(currentWishesArray)
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: Wish.ArchiveURL.path)
            print(success ? "Successful save" : "Save Failed")
            printWishes() // Debug
        } catch {
            print("Save Failed")
        }
    }
    
    func loadWishes() -> [Wish]? {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: Wish.ArchiveURL.path) as? Data else { return nil }
        do {
            let wishes = try PropertyListDecoder().decode([Wish].self, from: data)
            return wishes
        } catch {
            print("Retrieve Failed")
            return nil
        }
    }
}
