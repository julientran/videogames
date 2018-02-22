//
//  WishTableViewController.swift
//  WishTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Julien Tran. All rights reserved.
//

import UIKit

class WishTableViewController: UITableViewController, UISearchBarDelegate{
    
    var listFilters : [String] = []
    var listFiltersFullElementsWithNavigation : [String] = []
    var listFiltersSliceElementsWithNavigation : [String] = []
    
    @IBOutlet var tableWish: UITableView!
    @IBOutlet weak var searchBarWish: UISearchBar!
    
    
    // MARK: Properties
    
    var currentSearchText = ""
    var wishes = [Wish]()
    var currentWishesArray = [Wish]()
    var selectedScopeVar = 0
    
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
            currentWishesArray = wishes.sorted()
            printWishes() // Debug
            tableWish.reloadData()
        }
        else {
            // Load the sample data.
            loadSampleWishes()
        }
        setUpSearchBar()
    }
    
    private func setUpSearchBar(){
        
        listFilters = []
        listFiltersFullElementsWithNavigation = []
        listFiltersSliceElementsWithNavigation = []
        
        for wish in wishes {
            if (!listFilters.contains(wish.platform) && wish.platform != "" ) {
                listFilters.append(wish.platform)
            }
        }
        
        listFilters = listFilters.sorted{$0.localizedCompare($1) == .orderedAscending}
        listFilters.insert("All", at: 0)
        
        if listFilters.count == 1 {
            self.searchBarWish.isHidden = true
            self.searchBarWish.showsScopeBar = false
        } else {
            self.searchBarWish.isHidden = false
            self.searchBarWish.showsScopeBar = true
        }
        
        searchBarWish.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-Medium", size: 10.0)!], for: .normal)
        
        searchBarWish.delegate = self
        self.searchBarWish.isTranslucent = false
        self.searchBarWish.backgroundImage = UIImage()
        
        var count = 0
        for filter in listFilters {
            if(count == 4){
                listFiltersFullElementsWithNavigation.append(">")
                listFiltersFullElementsWithNavigation.append("<")
                listFiltersFullElementsWithNavigation.append(filter)
                count = 2
            } else {
                listFiltersFullElementsWithNavigation.append(filter)
                count += 1
            }
        }
        
        if (listFiltersFullElementsWithNavigation[listFiltersFullElementsWithNavigation.count - 1] == "<") {
            listFiltersFullElementsWithNavigation.remove(at: listFiltersFullElementsWithNavigation.count - 1 )
            listFiltersFullElementsWithNavigation.remove(at: listFiltersFullElementsWithNavigation.count - 1)
        } else {
            if(listFiltersFullElementsWithNavigation.count > 1) {
                if (listFiltersFullElementsWithNavigation[listFiltersFullElementsWithNavigation.count - 2] == "<") {
                    listFiltersFullElementsWithNavigation.remove(at: listFiltersFullElementsWithNavigation.count - 2 )
                    listFiltersFullElementsWithNavigation.remove(at: listFiltersFullElementsWithNavigation.count - 2)
                }
            }
        }
        
        loadFirstScope()
        self.searchBarWish.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [type(of: self.searchBarWish)]).tintColor = .darkGray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func loadFirstScope() {
        listFiltersSliceElementsWithNavigation = []
        var i = 0
        var j = i + 5
        if (j >  listFiltersFullElementsWithNavigation.count) {
            j = listFiltersFullElementsWithNavigation.count
        }
        while i < j {
            listFiltersSliceElementsWithNavigation.append(listFiltersFullElementsWithNavigation[i])
            i = i + 1
        }
        
        self.searchBarWish.scopeButtonTitles = listFiltersSliceElementsWithNavigation
    }
    
    func loadSampleWishes() {
        let photo1 = UIImage(named: "Sample")!
        let wish1 = Wish(idwish: "idnil", name: "Rayman Legends", photo: photo1, platform: "PS4", buy: false, publisher: "Ubisoft", releasedate: "")
        wishes += [wish1]
        currentWishesArray = wishes.sorted()
        saveWishes()
        tableWish.reloadData()
        printWishes() // Debug
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        guard !searchText.isEmpty else {
            currentWishesArray = wishes.sorted()
            loadFirstScope()
            searchBarWish.selectedScopeButtonIndex = 0
            selectedScopeVar = 0
            currentSearchText = ""
            tableWish.reloadData()
            return
        }
        currentWishesArray = wishes.sorted()
        if(searchBarWish.selectedScopeButtonIndex == 0) {
            if (selectedScopeVar != 0) {
                //<
                selectedScopeVar -= 5
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedIndex = (selectedIndex * 3)
                currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[selectedIndex] })
            }
        } else {
            if(searchBarWish.selectedScopeButtonIndex == 4) {
                //>
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedScopeVar += 5
                
                selectedIndex = (selectedIndex * 3) + 1
                currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[selectedIndex] })
                
            } else {
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                selectedIndex = (selectedIndex * 3) + searchBarWish.selectedScopeButtonIndex
                currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[selectedIndex] })
            }
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
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        if selectedScope == 0 {
            if(selectedScopeVar == 0) {
                //All
                if !currentSearchText.isEmpty {
                    currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
                } else {
                    currentWishesArray = wishes.sorted()
                }
            } else {
                //<
                listFiltersSliceElementsWithNavigation = []
                
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedIndex = selectedIndex * 3
                
                selectedScopeVar -= 5
                var i = selectedScopeVar
                let j = i + 5
                while i < j {
                    listFiltersSliceElementsWithNavigation.append(listFiltersFullElementsWithNavigation[i])
                    i = i + 1
                }
                
                self.searchBarWish.scopeButtonTitles = listFiltersSliceElementsWithNavigation
                searchBarWish.selectedScopeButtonIndex = 3;
                
                if !currentSearchText.isEmpty {
                    currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
                } else {
                    currentWishesArray = wishes.sorted()
                }
                currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[selectedIndex]
                })
            }
        } else {
            if selectedScope == 4 {
                //>
                listFiltersSliceElementsWithNavigation = []
                selectedScopeVar += 5
                
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedIndex = (selectedIndex * 3) + 1
                
                var i = selectedScopeVar
                var j = i + 5
                if (j > listFiltersFullElementsWithNavigation.count) {
                    j = listFiltersFullElementsWithNavigation.count
                }
                while i < j {
                    listFiltersSliceElementsWithNavigation.append(listFiltersFullElementsWithNavigation[i])
                    i = i + 1
                }
                
                self.searchBarWish.scopeButtonTitles = listFiltersSliceElementsWithNavigation
                searchBarWish.selectedScopeButtonIndex = 1;
                
                if !currentSearchText.isEmpty {
                    currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
                } else {
                    currentWishesArray = wishes.sorted()
                }
                currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[selectedIndex]
                })
                
                
            } else {
                if !currentSearchText.isEmpty {
                    currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
                } else {
                    currentWishesArray = wishes.sorted()
                }
                
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedIndex = (selectedIndex * 3) + selectedScope
                
                currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == listFilters[selectedIndex]
                })
            }
            
        }
        tableWish.reloadData()
    }
    
    func deleteAllWishes() {
        // Delete the row from the data source
        wishes = [Wish]()
        listFilters = []
        setUpSearchBar()
        loadFirstScope()
        searchBarWish.selectedScopeButtonIndex = 0;
        selectedScopeVar = 0
        searchBarWish.text = ""
        currentSearchText = ""
        currentWishesArray = wishes.sorted()
        saveWishes()
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
            
            loadFirstScope()
            searchBarWish.selectedScopeButtonIndex = 0;
            selectedScopeVar = 0
            searchBarWish.text = ""
            currentSearchText = ""
            currentWishesArray = wishes.sorted()
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
        
        let selectedScopeButtonName = listFilters[((selectedScopeVar / 5) * 3 ) + searchBarWish.selectedScopeButtonIndex]
        
        wishes.remove(at: wishesPath.row)
        listFilters = []
        setUpSearchBar()
        loadFirstScope()
        searchBarWish.selectedScopeButtonIndex = 0;
        selectedScopeVar = 0
        searchBarWish.text = ""
        currentSearchText = ""
        currentWishesArray = wishes.sorted()
        saveWishes()
        loadContextAfterDelete(selectedScopeButtonName: selectedScopeButtonName)
        tableWish.reloadData()
    }
    
    // MARK: Actions
    @IBAction func unwindToWishList(_ sender: UIStoryboardSegue) {
        if((sender.source as? WishViewController)?.wish?.buy)!{
            
            let wish : Wish = ((sender.source as? WishViewController)?.wish)!
            
            let tbc = self.parent?.parent as! TabBarController
            print(tbc.statut)
            
            let gvc : GameTableViewController  = tbc.childViewControllers[0].childViewControllers[0] as! GameTableViewController
            
            gvc.changeToBuy(wish: wish)
            
            //Delete
            deleteWish(wish: wish)
            
            
        } else {
            
            let tbc = self.parent?.parent as! TabBarController
            if (tbc.selectedScopeButtonName == ""){
                tbc.selectedScopeButtonName = listFilters[((selectedScopeVar / 5) * 3 ) + searchBarWish.selectedScopeButtonIndex]
            }
            
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
                    loadFirstScope()
                    searchBarWish.selectedScopeButtonIndex = 0;
                    selectedScopeVar = 0
                    searchBarWish.text = ""
                    currentSearchText = ""
                    currentWishesArray = wishes.sorted()
                    tableWish.reloadData()
                    
                    tableView.reloadRows(at: [wishesPath], with: .none)
                }
                else {
                    // Add a new wish.
                    let newIndexPath = IndexPath(row: wishes.count, section: 0)
                    wishes.append(wish)
                    currentWishesArray = wishes.sorted()
                    tableView.insertRows(at: [newIndexPath], with: .bottom)
                }
                // Save the wishes.
                saveWishes()
                loadContextAfterAdd()
                
                //Position scroll on add
                let tbc = self.parent?.parent as! TabBarController
                if(tbc.selectedScopeButtonName == wish.platform || tbc.selectedScopeButtonName == "All" ){
                    for i in 0..<currentWishesArray.count { // N'oubliez pas que l'indice d'un tableau débute à 0
                        if( currentWishesArray[i].idwish == wish.idwish ){
                            j = i
                        }
                    }
                    let wishesPath = IndexPath(row: j, section: 0)
                    
                    DispatchQueue.main.async {
                        self.tableView.scrollToRow(at: wishesPath,at: .middle, animated: true) //here .middle is the scroll position can change it as per your need
                    }
                }
                tbc.selectedScopeButtonName = ""
            }
        }
    }
    
    // MARK: NSCoding
    
    func loadContextAfterDelete(selectedScopeButtonName : String) {
        if(listFiltersFullElementsWithNavigation.index(of: selectedScopeButtonName) != nil && selectedScopeButtonName != "All") {
            let index : Int = listFiltersFullElementsWithNavigation.index(of: selectedScopeButtonName)!
            
            selectedScopeVar = (index/5)*5
            searchBarWish.selectedScopeButtonIndex = index - (index/5)*5
            
            listFiltersSliceElementsWithNavigation = []
            var i = selectedScopeVar
            var j = i + 5
            if (j > listFiltersFullElementsWithNavigation.count) {
                j = listFiltersFullElementsWithNavigation.count
            }
            while i < j {
                listFiltersSliceElementsWithNavigation.append(listFiltersFullElementsWithNavigation[i])
                i = i + 1
            }
            
            
            self.searchBarWish.scopeButtonTitles = listFiltersSliceElementsWithNavigation
            
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes.sorted()
            }
            currentWishesArray = currentWishesArray.filter({ game -> Bool in game.platform == selectedScopeButtonName
            })
            
            tableWish.reloadData()
        }
        
    }
    
    func loadContextAfterAdd() {
        
        let tbc = self.parent?.parent as! TabBarController
        if(tbc.selectedScopeButtonName != "All" && tbc.selectedScopeButtonName != ""){
            let index : Int = listFiltersFullElementsWithNavigation.index(of: tbc.selectedScopeButtonName)!
            
            selectedScopeVar = (index/5)*5
            searchBarWish.selectedScopeButtonIndex = index - (index/5)*5
            
            listFiltersSliceElementsWithNavigation = []
            var i = selectedScopeVar
            var j = i + 5
            if (j > listFiltersFullElementsWithNavigation.count) {
                j = listFiltersFullElementsWithNavigation.count
            }
            while i < j {
                listFiltersSliceElementsWithNavigation.append(listFiltersFullElementsWithNavigation[i])
                i = i + 1
            }
            
            
            self.searchBarWish.scopeButtonTitles = listFiltersSliceElementsWithNavigation
            
            if !currentSearchText.isEmpty {
                currentWishesArray = filterWishes(wishesForFilter: wishes, searchTextForFilter: currentSearchText)
            } else {
                currentWishesArray = wishes.sorted()
            }
            currentWishesArray = currentWishesArray.filter({ wish -> Bool in wish.platform == tbc.selectedScopeButtonName
            })
            
            tableWish.reloadData()
        }
    }
    
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
