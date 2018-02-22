//
//  MembershipTableViewController.swift
//  GameTracker
//
//  Created by Tran Julien on 20/02/2018.
//  Copyright © 2018 Tran Julien. All rights reserved.
//

import UIKit

class MembershipTableViewController: UITableViewController, UISearchBarDelegate {
    
    var listFilters : [String] = []
    var listFiltersFullElementsWithNavigation : [String] = []
    var listFiltersSliceElementsWithNavigation : [String] = []
    
    @IBOutlet weak var searchBarMembership: UISearchBar!
    @IBOutlet var tableMembership: UITableView!
    
    
    // MARK: Properties
    
    var currentSearchText = ""
    var gamesMember = [GameMember]()
    var currentGamesMemberArray = [GameMember]()
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
        
        //Trick for UITabBar will hide the last cell of the UITableView
        tableMembership.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        
        let image = UIImage(named: "Logo")
        navigationItem.titleView = UIImageView(image: image)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved gamesMember, otherwise load sample data.
        if let savedGamesMember = loadGamesMember() {
            gamesMember += savedGamesMember
            currentGamesMemberArray = gamesMember.sorted()
            printGamesMember() // Debug
            tableMembership.reloadData()
        }
        DispatchQueue.main.async {
            self.checkUpdateGamesList()
        }
        setUpSearchBar()
    }
    
    private func setUpSearchBar(){
        
        listFilters = []
        listFiltersFullElementsWithNavigation = []
        listFiltersSliceElementsWithNavigation = []
        
        for gameMember in gamesMember {
            if (!listFilters.contains(gameMember.platform) && gameMember.platform != "" ) {
                listFilters.append(gameMember.platform)
            }
        }
        
        listFilters = listFilters.sorted{$0.localizedCompare($1) == .orderedAscending}
        listFilters.insert("All", at: 0)
        
        if listFilters.count == 1 {
            self.searchBarMembership.isHidden = true
            self.searchBarMembership.showsScopeBar = false
        } else {
            self.searchBarMembership.isHidden = false
            self.searchBarMembership.showsScopeBar = true
        }
        
        searchBarMembership.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-Medium", size: 10.0)!], for: .normal)
        
        searchBarMembership.delegate = self
        self.searchBarMembership.isTranslucent = false
        self.searchBarMembership.backgroundImage = UIImage()
        
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
        self.searchBarMembership.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [type(of: self.searchBarMembership)]).tintColor = .darkGray
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
        
        self.searchBarMembership.scopeButtonTitles = listFiltersSliceElementsWithNavigation
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        guard !searchText.isEmpty else {
            currentGamesMemberArray = gamesMember.sorted()
            loadFirstScope()
            searchBarMembership.selectedScopeButtonIndex = 0
            selectedScopeVar = 0
            currentSearchText = ""
            tableMembership.reloadData()
            return
        }
        currentGamesMemberArray = gamesMember.sorted()
        if(searchBarMembership.selectedScopeButtonIndex == 0) {
            if (selectedScopeVar != 0) {
                //<
                selectedScopeVar -= 5
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedIndex = (selectedIndex * 3)
                currentGamesMemberArray = currentGamesMemberArray.filter({ gameMember -> Bool in gameMember.platform == listFilters[selectedIndex] })
            }
        } else {
            if(searchBarMembership.selectedScopeButtonIndex == 4) {
                //>
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedScopeVar += 5
                
                selectedIndex = (selectedIndex * 3) + 1
                currentGamesMemberArray = currentGamesMemberArray.filter({ gameMember -> Bool in gameMember.platform == listFilters[selectedIndex] })
                
            } else {
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                selectedIndex = (selectedIndex * 3) + searchBarMembership.selectedScopeButtonIndex
                currentGamesMemberArray = currentGamesMemberArray.filter({ gameMember -> Bool in gameMember.platform == listFilters[selectedIndex] })
            }
        }
        
        currentGamesMemberArray = filterGamesMember(gamesMemberForFilter: currentGamesMemberArray, searchTextForFilter: searchText)
        currentSearchText = searchText
        tableMembership.reloadData()
    }
    
    func filterGamesMember(gamesMemberForFilter: [GameMember], searchTextForFilter: String) -> [GameMember] {
        searchBarMembership.prompt = "0 gameMember"
        return gamesMemberForFilter.filter({ gameMember -> Bool in
            (gameMember.name.lowercased().contains(searchTextForFilter.lowercased()) || gameMember.publisher.lowercased().contains(searchTextForFilter.lowercased()))
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        if selectedScope == 0 {
            if(selectedScopeVar == 0) {
                //All
                if !currentSearchText.isEmpty {
                    currentGamesMemberArray = filterGamesMember(gamesMemberForFilter: gamesMember, searchTextForFilter: currentSearchText)
                } else {
                    currentGamesMemberArray = gamesMember.sorted()
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
                
                self.searchBarMembership.scopeButtonTitles = listFiltersSliceElementsWithNavigation
                searchBarMembership.selectedScopeButtonIndex = 3;
                
                if !currentSearchText.isEmpty {
                    currentGamesMemberArray = filterGamesMember(gamesMemberForFilter: gamesMember, searchTextForFilter: currentSearchText)
                } else {
                    currentGamesMemberArray = gamesMember.sorted()
                }
                currentGamesMemberArray = currentGamesMemberArray.filter({ gameMember -> Bool in gameMember.platform == listFilters[selectedIndex]
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
                
                self.searchBarMembership.scopeButtonTitles = listFiltersSliceElementsWithNavigation
                searchBarMembership.selectedScopeButtonIndex = 1;
                
                if !currentSearchText.isEmpty {
                    currentGamesMemberArray = filterGamesMember(gamesMemberForFilter: gamesMember, searchTextForFilter: currentSearchText)
                } else {
                    currentGamesMemberArray = gamesMember.sorted()
                }
                currentGamesMemberArray = currentGamesMemberArray.filter({ gameMember -> Bool in gameMember.platform == listFilters[selectedIndex]
                })
                
                
            } else {
                if !currentSearchText.isEmpty {
                    currentGamesMemberArray = filterGamesMember(gamesMemberForFilter: gamesMember, searchTextForFilter: currentSearchText)
                } else {
                    currentGamesMemberArray = gamesMember.sorted()
                }
                
                var selectedIndex : Int = selectedScopeVar
                while selectedIndex >= 5 {
                    selectedIndex = selectedIndex / 5
                }
                
                selectedIndex = (selectedIndex * 3) + selectedScope
                
                currentGamesMemberArray = currentGamesMemberArray.filter({ gameMember -> Bool in gameMember.platform == listFilters[selectedIndex]
                })
            }
            
        }
        tableMembership.reloadData()
    }
    
    func deleteAllGamesMember() {
        // Delete the row from the data source
        gamesMember = [GameMember]()
        listFilters = []
        setUpSearchBar()
        loadFirstScope()
        searchBarMembership.selectedScopeButtonIndex = 0;
        selectedScopeVar = 0
        searchBarMembership.text = ""
        currentSearchText = ""
        currentGamesMemberArray = gamesMember.sorted()
        saveGamesMember()
        tableMembership.reloadData()
    }
    
    func printGamesMember() {
        var i = 0
        for gameMember in currentGamesMemberArray {
            print("gameMember: [\(i)] '\(gameMember.name)'") // Debug
            i += 1
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentGamesMemberArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GameMemberTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GameMemberTableViewCell
        
        // Fetches the appropriate gameMember for the data source layout.
        let gameMember = currentGamesMemberArray[indexPath.row]
        cell.nameLabel.text = gameMember.name
        cell.photoImageView.image = gameMember.photo
        cell.releasedateLabel.text = gameMember.releasedate
        cell.platformLabel.text = gameMember.platform
        cell.publisherLabel.text = gameMember.publisher
        cell.idgamememberLabel.text = gameMember.idgamemember
        
        searchBarMembership.prompt = currentGamesMemberArray.count < 2  ? String(currentGamesMemberArray.count) + " game" : String(currentGamesMemberArray.count) + " games"
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("at: \(indexPath.row)") // Debug
        if editingStyle == .delete {
            searchBarMembership.prompt = "0 gameMember"
            // Delete the row from the data source
            deleteGameMember(gameMember: currentGamesMemberArray[indexPath.row])
            
        } else if editingStyle == .insert {
            setUpSearchBar()
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        print("from: \(fromIndexPath.row), to: \(toIndexPath.row)") // Debug
        let gameMember = currentGamesMemberArray.remove(at: fromIndexPath.row)
        currentGamesMemberArray.insert(gameMember, at: toIndexPath.row)
        saveGamesMember()
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation
    
    func deleteGameMember(gameMember :GameMember) {
        var j = 0
        for i in 0..<gamesMember.count { // N'oubliez pas que l'indice d'un tableau débute à 0
            if( gamesMember[i].idgamemember == gameMember.idgamemember ){
                j = i
            }
        }
        let gamesMemberPath = IndexPath(row: j, section: 0)
        
        let selectedScopeButtonName = listFilters[((selectedScopeVar / 5) * 3 ) + searchBarMembership.selectedScopeButtonIndex]
        
        gamesMember.remove(at: gamesMemberPath.row)
        listFilters = []
        setUpSearchBar()
        loadFirstScope()
        searchBarMembership.selectedScopeButtonIndex = 0;
        selectedScopeVar = 0
        searchBarMembership.text = ""
        currentSearchText = ""
        currentGamesMemberArray = gamesMember.sorted()
        saveGamesMember()
        loadContextAfterDelete(selectedScopeButtonName: selectedScopeButtonName)
        tableMembership.reloadData()
    }
    
    
    // MARK: NSCoding
    
    func loadContextAfterDelete(selectedScopeButtonName : String) {
        if(listFiltersFullElementsWithNavigation.index(of: selectedScopeButtonName) != nil && selectedScopeButtonName != "All") {
            let index : Int = listFiltersFullElementsWithNavigation.index(of: selectedScopeButtonName)!
            
            selectedScopeVar = (index/5)*5
            searchBarMembership.selectedScopeButtonIndex = index - (index/5)*5
            
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
            
            
            self.searchBarMembership.scopeButtonTitles = listFiltersSliceElementsWithNavigation
            
            if !currentSearchText.isEmpty {
                currentGamesMemberArray = filterGamesMember(gamesMemberForFilter: gamesMember, searchTextForFilter: currentSearchText)
            } else {
                currentGamesMemberArray = gamesMember.sorted()
            }
            currentGamesMemberArray = currentGamesMemberArray.filter({ game -> Bool in game.platform == selectedScopeButtonName
            })
            
            tableMembership.reloadData()
        }
        
    }
    
    func loadContextAfterAdd() {
        
        let tbc = self.parent?.parent as! TabBarController
        if(tbc.selectedScopeButtonName != "All" && tbc.selectedScopeButtonName != ""){
            let index : Int = listFiltersFullElementsWithNavigation.index(of: tbc.selectedScopeButtonName)!
            
            selectedScopeVar = (index/5)*5
            searchBarMembership.selectedScopeButtonIndex = index - (index/5)*5
            
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
            
            
            self.searchBarMembership.scopeButtonTitles = listFiltersSliceElementsWithNavigation
            
            if !currentSearchText.isEmpty {
                currentGamesMemberArray = filterGamesMember(gamesMemberForFilter: gamesMember, searchTextForFilter: currentSearchText)
            } else {
                currentGamesMemberArray = gamesMember.sorted()
            }
            currentGamesMemberArray = currentGamesMemberArray.filter({ gameMember -> Bool in gameMember.platform == tbc.selectedScopeButtonName
            })
            
            tableMembership.reloadData()
        }
        
    }
    
    func saveGamesMember() {
        setUpSearchBar()
        do {
            let data = try PropertyListEncoder().encode(currentGamesMemberArray)
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: GameMember.ArchiveURL.path)
            print(success ? "Successful save" : "Save Failed")
            printGamesMember() // Debug
        } catch {
            print("Save Failed")
        }
    }
    
    func checkUpdateGamesList() {
        let itemListBaseURL = URL(string: "https://www.playstation.com/fr-fr/explore/playstation-plus/this-month-on-ps-plus/")!
        let itemListBaseHTML = try! String(contentsOf: itemListBaseURL, encoding: .utf8)
        let urls = itemListBaseHTML.slices(from: "<a href=\"", to: "\" target=")
        var urlGames = ""
        for url in urls {
            if (String(url).contains("PLUSINSTANTGAME")) {
                urlGames = String(String(url).slices(from: "STORE-", to: "-PLUSINSTANTGAME")[0])
            }
        }
        if (urlGames != "") {
            let itemListURL = URL(string: "https://store.playstation.com/fr-fr/grid/STORE-" + urlGames + "-PLUSINSTANTGAME/1")!
            let itemListHTML = try! String(contentsOf: itemListURL, encoding: .utf8)
            print(itemListURL)
            let titles = itemListHTML.slices(from: "<div class=\"grid-cell__title \">", to: "</div>")
            let photos = itemListHTML.slices(from: "<img src=\"", to: "\" srcset=\"")
            let platforms = itemListHTML.slices(from: "<span class=\"grid-cell__platforms\">", to: "</span>")
            
            var i = 0
            var newOne = true
            for result in photos {
                if(!(titles[i].lowercased().contains("playstation"))){
                    newOne = true
                    let url = URL(string: String(result))
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    var photo: UIImage? = UIImage(named: "Cover")!
                    if (data != nil) {
                        photo = UIImage(data: data!)
                    }
                    
                    
                    for currentGame in currentGamesMemberArray {
                        if(currentGame.name == String(titles[i]).replacingHTMLEntities!  && currentGame.platform == String(platforms[i])) {
                            newOne = false
                        }
                    }
                    
                    if(newOne) {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        
                        let gameMember1 = GameMember(idgamemember: UUID().uuidString, name: String(titles[i]).replacingHTMLEntities!, photo: photo, platform: String(platforms[i]), publisher: "", releasedate: dateFormatter.string(from: Date()))
                        gamesMember += [gameMember1]
                        
                        currentGamesMemberArray = gamesMember.sorted()
                        saveGamesMember()
                        tableMembership.reloadData()
                        printGamesMember()
                    }
                    
                }
                i += 1
            }
            
        }
        
    }
    
    func loadGamesMember() -> [GameMember]? {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: GameMember.ArchiveURL.path) as? Data else { return nil }
        do {
            let gamesMember = try PropertyListDecoder().decode([GameMember].self, from: data)
            return gamesMember
        } catch {
            print("Retrieve Failed")
            return nil
        }
    }
}

extension String {
    var replacingHTMLEntities: String? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil).string
        } catch {
            return nil
        }
    }
}











