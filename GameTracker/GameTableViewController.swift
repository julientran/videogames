//
//  GameTableViewController.swift
//  GameTracker
//
//

import UIKit

class GameTableViewController: UITableViewController, UISearchBarDelegate{
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
  // MARK: Properties

  var currentSearchText = ""
  var games = [Game]()
  var currentGamesArray = [Game]()

    
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSearchBar()

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
  }
    
    private func setUpSearchBar(){
        searchBar.delegate = self
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.

  }

  func loadSampleGames() {
    let photo1 = UIImage(named: "Cover")!
    let game1 = Game(idgame: "test", name: "Rayman", photo: photo1, dord: 1, platform: "PS4", done: false, publisher: "ubisoft")!

    games += [game1]
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
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == "PS4"
            })
        case 2:
            if !currentSearchText.isEmpty {
                currentGamesArray = filterGames(gamesForFilter: games, searchTextForFilter: currentSearchText)
            } else {
                currentGamesArray = games
            }
            currentGamesArray = currentGamesArray.filter({ game -> Bool in game.platform == "Switch"
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
      // Delete the row from the data source
      var j = 0
        for i in 0..<games.count { // N'oubliez pas que l'indice d'un tableau débute à 0
            if( games[i].idgame == currentGamesArray[indexPath.row].idgame ){
                j = i
            }
      }
      let gamesPath = IndexPath(row: j, section: 0)
        
      games.remove(at: gamesPath.row)
      saveGames()
      searchBar.selectedScopeButtonIndex = 0;
      searchBar.text = ""
      currentGamesArray = games
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

      // Get the cell that generated this segue.
      if let selectedGameCell = sender as? GameTableViewCell {
        let indexPath = tableView.indexPath(for: selectedGameCell)!
        let selectedGame = currentGamesArray[indexPath.row]
        gameDetailViewController.game = selectedGame
      }
    }
    else if segue.identifier == "AddItem" {
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
    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(currentGamesArray, toFile: Game.ArchiveURL.path)
    if !isSuccessfulSave {
      print("Failed to save games...")
    }
    printGames() // Debug
  }

  func loadGames() -> [Game]? {
    return NSKeyedUnarchiver.unarchiveObject(withFile: Game.ArchiveURL.path) as? [Game]
  }

}
