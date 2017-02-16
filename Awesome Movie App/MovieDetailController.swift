//
//  MovieDetailController.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

class MovieDetailController: UIViewController {

    @IBOutlet weak var contentScrollView: UIScrollView!
    
    var movie: MovieEntity? {
        didSet {
            // Update the view.
            updateView()
            
            // Get missing information from movie database
            MovieDatabase.sharedInstance.getDetailsForMovie(movie!) { (movieDict) in
                DispatchQueue.main.async {
                    // set genres and overview
                    let genresDictionaries = movieDict["genres"] as? [[String:Any]] ?? []
                    var movieGenres = [String]()
                    for genreDict in genresDictionaries {
                        if let genreName = genreDict["name"] as? String {
                            movieGenres.append(genreName)
                        }
                    }
                    self.movie?.genres = movieGenres
                    
                    self.updateView()
                }
            }
            
            // TODO get image if is not present
        }
    }
    
    func updateView() {
        // Update the user interface for the detail item.
        guard let movie = self.movie else {
            return
        }
        
        // show content - all contained in scroll view
        if let scrollView = self.contentScrollView  {
            scrollView.isHidden = false
            // Set UI values TODO
            //            self.detailDescriptionLabel.text = movie.description
        }
        
        // TODO turn on/off constraints
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateView()
    }
}
