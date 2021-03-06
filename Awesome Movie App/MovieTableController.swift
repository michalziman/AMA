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
    var pagesLoaded = 0
    
    var filterMinimum = MovieFilterController.minimumProductionYear
    var filterMaximum = Calendar.current.component(.year, from: Date()) // now
    
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
                    self.refreshControl?.endRefreshing()
                    self.pagesLoaded = 1
                    self.filterMovies()
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
    
    func filterMovies() {
        let lastFilteredMoviesCount = filteredMovies.count
        let yearNow = Calendar.current.component(.year, from: Date())
        if filterMinimum == MovieFilterController.minimumProductionYear && filterMaximum == yearNow {
            // if range is maximum, do not filter, neither show range
            filteredMovies = allMovies
            self.navigationItem.prompt = nil
        } else {
            // filter movies
            filteredMovies = allMovies.filter({ (movie) -> Bool in
                if movie.releaseYear >= filterMinimum && movie.releaseYear <= filterMaximum {
                    return true
                }
                return false
            })
            // show range
            self.navigationItem.prompt = "\(filterMinimum) – \(filterMaximum)"
        }
        
        if allMovies.count <= MovieDatabase.moviesPerPage {
            self.tableView.reloadData()
            // reloading data will eventuelly cause displaying of last cell again and thus loading next page, if entries are so few, that last cell will be displayed
        } else {
            let newRows = filteredMovies.count - lastFilteredMoviesCount
            self.tableView.beginUpdates()
            var indexes:[IndexPath] = []
            for i in 0..<newRows {
                indexes.append(IndexPath(row: lastFilteredMoviesCount + i, section: 0))
            }
            self.tableView.reloadRows(at: [IndexPath(row: lastFilteredMoviesCount, section: 0)], with: .fade)
            self.tableView.insertRows(at: indexes, with: .middle)
            self.tableView.endUpdates()
            
            // when there is nothing to be inserted, only refresh, for some reason, the reload is not done, thus it is necessary to load next page from here
            if indexes.count == 0 {
                loadNextPage()
            }
        }
        
        
        
        // if there is nothing after filtering, load next page
        if filteredMovies.count < 1  {
            loadNextPage()
        }
    }
    
    func loadNextPage() {
        let loadedPage = pagesLoaded + 1
        MovieDatabase.sharedInstance.getPopularMovies(onPage: loadedPage, withCallback: { (movies) in
            if movies.count > 0 {
                // if there are some, display them and stop refresh controller UI feedback
                DispatchQueue.main.async {
                    if self.pagesLoaded + 1 != loadedPage {
                        // the async response arrived after reloading, would shuffle results, so just ignore it
                        return
                    }
                    // append movies from next page
                    self.allMovies.append(contentsOf: movies)
                    self.pagesLoaded += 1
                    // filter
                    self.filterMovies()
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
        if segue.identifier == "ShowDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // set movie to display in detail based on selected row
                let controller = segue.destination as! MovieDetailController
                controller.movie = filteredMovies[indexPath.row]
            }
        } else if segue.identifier == "ShowFilter" {
            // set border years and self as delegate
            let controller = segue.destination as! MovieFilterController
            controller.minYear = filterMinimum
            controller.maxYear = filterMaximum
            controller.delegate = self
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count + 1 // plus one to show loading indicator on bottom
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

extension MovieTableController: MovieFilterDelegate {
    func movieFilter(_ movieFilter: MovieFilterController, didSelectMinYear minYear: Int, maxYear: Int) {
        // remember borders
        filterMinimum = minYear
        filterMaximum = maxYear
        
        // and refresh
        self.refreshControl?.beginRefreshing()
        handleRefresh()
    }
}
