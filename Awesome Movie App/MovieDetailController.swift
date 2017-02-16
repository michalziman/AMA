//
//  MovieDetailController.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

class MovieDetailController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: MovieEntity? {
        didSet {
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
        }
    }
    
    func updateView() {
        // Update the user interface for the detail item.
        guard let movie = self.movie else {
            return
        }
        
        titleLabel.text = movie.title
        genresLabel.text = movie.genres.joined(separator: ", ")
        yearLabel.text = "\(movie.releaseYear)"
        overviewLabel.text = movie.overview
        
        if let image = movie.image {
            imageView.image = image
        } else if activityIndicator.isHidden {
            // using activityIndicator isHidden proverty to prevent launching multiple downloads
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            // load image
            if movie.posterPath != "" {
                MovieDatabase.sharedInstance.downloadMovieImage(movie.posterPath, withCallback: { (downloadedImage) in
                    DispatchQueue.main.async {
                        if downloadedImage != nil {
                            // if download succeeded, save image for the movie to temp directory
                            movie.image = downloadedImage
                            self.imageView.image = downloadedImage
                        }
                        // stop spinner when image is loaded, successfully or not
                        self.activityIndicator.stopAnimating()
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateView()
    }
}
