//
//  GameTableViewController.swift
//  GameTracker
//
//  Created by Tran Julien on 11/02/2018.
//  Copyright © 2018 Julien Tran. All rights reserved.
//

import UIKit

struct FailableDecodable<Base : Decodable> : Decodable {
    
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

class GameTableViewController: UITableViewController, UISearchBarDelegate{
    
    var listFilters : [String] = []
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Properties
    
    var currentSearchText = ""
    var games = [Game]()
    var currentGamesArray = [Game]()
    
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
        
        // Load any saved games, otherwise load sample data.
        if let savedGames = loadGames() {
            games += savedGames
            currentGamesArray = games
            printGames() // Debug
        }
        else {
            // Load the sample data.
            loadSampleGames()
        }
        setUpSearchBar()
    }
    
    func changeToBuy(wish : Wish){
        
        let game1 = Game(idgame: UUID().uuidString, name: wish.name, photo: wish.photo, dord: 1, platform: wish.platform, done: false, publisher: wish.publisher)
        games += [game1]
        currentGamesArray = games
        saveGames()
        table.reloadData()
        printGames() // Debug
        
    }
    
    func getJson() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(games)
            print(String(data: data, encoding: .utf8)!)
            return String(data: data, encoding: .utf8)!
        } catch {
            return "Retrieve Failed"
        }
    }
    
    func loadJson(text: String) {
        let json = text.data(using: .utf8)! // our data in native (JSON) format
        do {
            let gamesFromJson = try JSONDecoder()
                .decode([FailableDecodable<Game>].self, from: json)
                .flatMap { $0.base }
            print(gamesFromJson)
            
            for game in gamesFromJson {
                // Add a new game.
                let newIndexPath = IndexPath(row: games.count, section: 0)
                games.append(game)
                currentGamesArray = games
                tableView.insertRows(at: [newIndexPath], with: .bottom)
                // Save the games.
                saveGames()
            }
        } catch {
            //handle error
            print(error)
        }
    }
    
    public func shareGames(_ sender: Any) {
        var arrayOfGames = [[String]]()
        for game in games {
            let imageData:NSData = UIImagePNGRepresentation(game.photo!)! as NSData
            let strBase64 = imageData.base64EncodedString()
            arrayOfGames.append([game.idgame, game.name, strBase64, game.publisher, game.platform, String(game.dord), String(game.done)])
        }
        
        //Retrieve Wishes
        
        var arrayOfWhises = [[String]]()
        let tbc = self.parent?.parent as! TabBarController
        print(tbc.statut)
        
        //load WishTableViewController with simulate click on tab
        tbc.selectedIndex = 1
        tbc.selectedIndex = 0
        
        let wvc : WishTableViewController  = tbc.childViewControllers[1].childViewControllers[0] as! WishTableViewController
        
        for wish in wvc.wishes {
            let imageData:NSData = UIImagePNGRepresentation(wish.photo!)! as NSData
            let strBase64 = imageData.base64EncodedString()
            arrayOfWhises.append([wish.idwish, wish.name, strBase64, wish.publisher, wish.platform, wish.releasedate, String(wish.buy)])
        }
        
        var backupArray = [[[String]]]()
        backupArray.append(arrayOfGames)
        backupArray.append(arrayOfWhises)
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date())
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd-MMM-yyyy"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        
        let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first
        let name = "backup-" + myStringafd
        let saveFileURL = path?.appendingPathComponent("/\(name).gtkr")
        (backupArray as NSArray).write(to: saveFileURL!, atomically: true)
        let activityViewController = UIActivityViewController(
            activityItems: ["Check out this games list.", saveFileURL!],
            applicationActivities: nil)
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func setUpSearchBar(){
        
        listFilters = []
        listFilters.append("All")
        
        for game in games {
            if (!listFilters.contains(game.platform) && game.platform != "" ) {
                if(listFilters.count < 5) {
                    listFilters.append(game.platform)
                }
            }
        }
        
        if listFilters.count == 1 {
            self.searchBar.isHidden = true
            self.searchBar.showsScopeBar = false
        } else {
            self.searchBar.isHidden = false
            self.searchBar.showsScopeBar = true
        }
        
        searchBar.delegate = self
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.scopeButtonTitles = listFilters
        self.searchBar.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [type(of: self.searchBar)]).tintColor = .darkGray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func loadSampleGames() {
        let photo1 = UIImage(named: "Sample")!
        let game1 = Game(idgame: "idnil", name: "Rayman Legends", photo: photo1, dord: 1, platform: "PS4", done: false, publisher: "Ubisoft")
        games += [game1]
        currentGamesArray = games
        saveGames()
        table.reloadData()
        printGames() // Debug
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        guard !searchText.isEmpty else {
            currentGamesArray = games;
            searchBar.selectedScopeButtonIndex = 0;
            currentSearchText = ""
            table.reloadData()
            return
        }
        if(searchBar.selectedScopeButtonIndex == 0) {
            currentGamesArray = games;
        }
        if(searchBar.selectedScopeButtonIndex == 1) {
            currentGamesArray = games;
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[1]
            })
        }
        if(searchBar.selectedScopeButtonIndex == 2) {
            currentGamesArray = games;
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[2]
            })
        }
        if(searchBar.selectedScopeButtonIndex == 3) {
            currentGamesArray = games;
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[3]
            })
        }
        if(searchBar.selectedScopeButtonIndex == 4) {
            currentGamesArray = games;
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[4]
            })
        }
        if(searchBar.selectedScopeButtonIndex == 5) {
            currentGamesArray = games;
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[5]
            })
        }
        currentGamesArray = filterGames(gamesForFilter: currentGamesArray, searchTextForFilter: searchText)
        currentSearchText = searchText
        table.reloadData()
    }
    
    func filterGames(gamesForFilter: [Game], searchTextForFilter: String) -> [Game] {
        searchBar.prompt = "0 game"
        return gamesForFilter.filter({ game -> Bool in
            (game.name.lowercased().contains(searchTextForFilter.lowercased()) || game.publisher.lowercased().contains(searchTextForFilter.lowercased()))
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        switch selectedScope {
        case 0:
            if !currentSearchText.isEmpty {
                currentGamesArray = filterGames(gamesForFilter: games, searchTextForFilter: currentSearchText)
            } else {
                currentGamesArray = games
            }
        case 1:
            if !currentSearchText.isEmpty {
                currentGamesArray = filterGames(gamesForFilter: games, searchTextForFilter: currentSearchText)
            } else {
                currentGamesArray = games
            }
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[1]
            })
        case 2:
            if !currentSearchText.isEmpty {
                currentGamesArray = filterGames(gamesForFilter: games, searchTextForFilter: currentSearchText)
            } else {
                currentGamesArray = games
            }
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[2]
            })
        case 3:
            if !currentSearchText.isEmpty {
                currentGamesArray = filterGames(gamesForFilter: games, searchTextForFilter: currentSearchText)
            } else {
                currentGamesArray = games
            }
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[3]
            })
        case 4:
            if !currentSearchText.isEmpty {
                currentGamesArray = filterGames(gamesForFilter: games, searchTextForFilter: currentSearchText)
            } else {
                currentGamesArray = games
            }
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[4]
            })
        case 5:
            if !currentSearchText.isEmpty {
                currentGamesArray = filterGames(gamesForFilter: games, searchTextForFilter: currentSearchText)
            } else {
                currentGamesArray = games
            }
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == listFilters[5]
            })
        default:
            break
        }
        table.reloadData()
    }
    
    func printGames() {
        var i = 0
        for game in currentGamesArray {
            print("game: [\(i)] '\(game.name)'") // Debug
            i += 1
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentGamesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GameTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GameTableViewCell
        
        // Fetches the appropriate game for the data source layout.
        let game = currentGamesArray[indexPath.row]
        cell.nameLabel.text = game.name
        cell.photoImageView.image = game.photo
        cell.doneLabel.text = game.done == true ? "🏁" : ""
        cell.dordLabel.text = game.dord < 1 ? "Disc" : "Digital"
        cell.platformLabel.text = game.platform
        cell.publisherLabel.text = game.publisher
        cell.idgameLabel.text = game.idgame
        
        searchBar.prompt = currentGamesArray.count < 2  ? String(currentGamesArray.count) + " game" : String(currentGamesArray.count) + " games"
        
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
            searchBar.prompt = "0 game"
            // Delete the row from the data source
            var j = 0
            for i in 0..<games.count { // N'oubliez pas que l'indice d'un tableau débute à 0
                if( games[i].idgame == currentGamesArray[indexPath.row].idgame ){
                    j = i
                }
            }
            let gamesPath = IndexPath(row: j, section: 0)
            
            games.remove(at: gamesPath.row)
            listFilters = []
            setUpSearchBar()
            searchBar.selectedScopeButtonIndex = 0;
            searchBar.text = ""
            currentGamesArray = games
            saveGames()
            table.reloadData()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        print("from: \(fromIndexPath.row), to: \(toIndexPath.row)") // Debug
        let game = currentGamesArray.remove(at: fromIndexPath.row)
        currentGamesArray.insert(game, at: toIndexPath.row)
        saveGames()
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let gameDetailViewController = segue.destination as! GameViewController // If the cast is unsuccessful, the app should crash at runtime.
            gameDetailViewController.listFilters = self.listFilters
            // Get the cell that generated this segue.
            if let selectedGameCell = sender as? GameTableViewCell {
                let indexPath = tableView.indexPath(for: selectedGameCell)!
                let selectedGame = currentGamesArray[indexPath.row]
                gameDetailViewController.game = selectedGame
            }
        }
        else if segue.identifier == "AddItem" {
            
            let navVC = segue.destination as? UINavigationController
            let formVC = navVC?.viewControllers.first as! GameViewController
            formVC.listFilters = self.listFilters
            
            searchBar.selectedScopeButtonIndex = 0;
            searchBar.text = ""
            currentGamesArray = games
            table.reloadData()
            print("Adding new game.")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: Actions
    
    @IBAction func unwindToGameList(_ sender: UIStoryboardSegue) {
        
        var j = 0
        if let sourceViewController = sender.source as? GameViewController, let game = sourceViewController.game {
            if tableView.indexPathForSelectedRow != nil {
                // Update an existing game.
                
                for i in 0..<games.count { // N'oubliez pas que l'indice d'un tableau débute à 0
                    if( games[i].idgame == game.idgame ){
                        j = i
                    }
                }
                let gamesPath = IndexPath(row: j, section: 0)
                games[gamesPath.row] = game
                searchBar.selectedScopeButtonIndex = 0;
                searchBar.text = ""
                currentGamesArray = games
                table.reloadData()
                
                tableView.reloadRows(at: [gamesPath], with: .none)
            }
            else {
                // Add a new game.
                let newIndexPath = IndexPath(row: games.count, section: 0)
                games.append(game)
                currentGamesArray = games
                tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
            // Save the games.
            saveGames()
        }
    }
    
    // MARK: NSCoding
    
    func saveGames() {
        setUpSearchBar()
        do {
            let data = try PropertyListEncoder().encode(currentGamesArray)
            let success = NSKeyedArchiver.archiveRootObject(data, toFile: Game.ArchiveURL.path)
            print(success ? "Successful save" : "Save Failed")
            printGames() // Debug
        } catch {
            print("Save Failed")
        }
    }
    
    func loadGames() -> [Game]? {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: Game.ArchiveURL.path) as? Data else { return nil }
        do {
            let games = try PropertyListDecoder().decode([Game].self, from: data)
            return games
        } catch {
            print("Retrieve Failed")
            return nil
        }
    }
}
