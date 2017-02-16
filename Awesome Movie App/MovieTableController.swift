//
//  MovieTableController.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

class MovieTableController: UITableViewController {

    var allMovies = [MovieEntity]()
    var filteredMovies = [MovieEntity]()
    var filterQuery = ""
    var pagesLoaded = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Starts refreshing when view is loaded to fill it with recent content
        // UI mirroring of refresh
        self.refreshControl?.beginRefreshing()
        // actual refresh
        self.handleRefresh()
        
        // bind actual logical refresh to UI action of pull on refresh control
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    func handleRefresh() {
        // call movie database connector to get popular movies
        MovieDatabase.sharedInstance.getPopularMovies { (movies) in
            if movies.count > 0 {
                // if there are some, display them and stop refresh controller UI feedback
                DispatchQueue.main.async {
                    self.allMovies = movies
                    self.filterWithQuery(self.filterQuery)
                    self.refreshControl?.endRefreshing()
                    self.pagesLoaded = 1
                }
            } else {
                // if there are no movies (probably error), show alert
                
                let alert = UIAlertController(title: "No results", message: "Awesome Movie App did not manage to get list of popular movies from the server. If you are offline, connect to the internet and try again.", preferredStyle: .alert)
                let tryAgainAction = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                    // one possibility is to try again
                    self.handleRefresh()
                })
                let doneAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                        // another to finish trying, so stop refresh controller UI feedback
                        self.refreshControl?.endRefreshing()
                    }
                })
                alert.addAction(tryAgainAction)
                alert.addAction(doneAction)
                
                // all calls with affect on UI should be dispatched on main thread when called from async block
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func filterWithQuery(_ query:String) {
        filterQuery = query.lowercased()
        
        if query == "" {
            filteredMovies = allMovies
        } else {
            let queryWords = filterQuery.components(separatedBy: CharacterSet(charactersIn: " ,"))
            filteredMovies = allMovies.filter({ (movie) -> Bool in
                for word in queryWords {
                    if movie.title.lowercased().contains(word) {
                        return true
                    }
                }
                return false
            })
        }
        
        self.tableView.reloadData()
    }
    
    func loadNextPage() {
        MovieDatabase.sharedInstance.getPopularMovies(onPage: pagesLoaded+1, withCallback: { (movies) in
            if movies.count > 0 {
                // if there are some, display them and stop refresh controller UI feedback
                DispatchQueue.main.async {
                    // remember number of filtered items
                    let numberOfFiltered = self.filteredMovies.count
                    // append movies from next page
                    self.allMovies.append(contentsOf: movies)
                    // filter
                    self.filterWithQuery(self.filterQuery)
                    self.pagesLoaded += 1
                    // if there is no new filtered items and yet the query is not nonsense, load next page
                    if self.filteredMovies.count <= numberOfFiltered && numberOfFiltered > 0 {
                        self.loadNextPage()
                    }
                }
            } else {
                // if there are no movies (probably error), show alert
                let alert = UIAlertController(title: "Could not load movies", message: "Awesome Movie App did not manage to get list of popular movies from the server. If your filter is set, try resetting it. If you are offline, connect to the internet and try again.", preferredStyle: .alert)
                let tryAgainAction = UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                    // one possibility is to try again
                    self.loadNextPage()
                })
                let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(tryAgainAction)
                alert.addAction(doneAction)
                
                // all calls with affect on UI should be dispatched on main thread when called from async block
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // set movie to display in detail based on selected row
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredMovies.count == 0 {
            return 0
        }
        return filteredMovies.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if wants to display one more cell than actual movies, show loading - for loading new page
        if indexPath.row >= filteredMovies.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        // simply set movie to cell and custom MasterViewCell will handle itself
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.movie = filteredMovies[indexPath.row]
        
        if indexPath.row == filteredMovies.count - 1 {
            // when hitting the last cell, load another page
            loadNextPage()
        }
        return cell
    }
}
