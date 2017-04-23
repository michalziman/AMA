//
//  MovieDetailController.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit
import youtube-ios-player-helper

class MovieDetailController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: MovieEntity? {
        didSet {
            updateView()
            
            // Get missing information from movie database, or return if genres are already loaded
            if movie!.genres.count > 0 {
                return
            }
            
            MovieDatabase.sharedInstance.getDetailsForMovie(movie!) { (movieDict) in
                DispatchQueue.main.async {
                    // set genres
                    self.movie?.parseGenres(fromDictionary: movieDict)
                    self.updateView()
                }
            }
        }
    }
    
    func updateView() {
        // check that movie is set and view already loaded
        guard let movie = self.movie else {
            return
        }
        if self.view == nil {
            return
        }
        
        // Update the user interface for the detail item.
        titleLabel.text = movie.title
        genresLabel.text = movie.genres.joined(separator: ", ")
        yearLabel.text = "\(movie.releaseYear)"
        overviewLabel.text = movie.overview
        
        // check if image is already downloaded
        if let image = movie.image {
            imageView.image = image
        } else if activityIndicator.isHidden {
            // using activityIndicator isHidden property to prevent launching multiple downloads
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
        updateView()
    }
}
