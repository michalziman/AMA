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
    @IBOutlet var playTrailerButton: UIBarButtonItem!
    @IBOutlet weak var noImageLabel: UILabel!
    
    var movie: MovieEntity? {
        didSet {
            updateView()
            
            // Get missing information from movie database, if it is not loaded
            if movie!.genres.count <= 0 {
                MovieDatabase.sharedInstance.getDetailsForMovie(movie!) { (movieDict) in
                    DispatchQueue.main.async {
                        // set genres
                        self.movie?.parseGenres(fromDictionary: movieDict)
                        self.updateView()
                    }
                }
            }
            if movie!.trailerYoutubeId == nil {
                MovieDatabase.sharedInstance.getYoutubeVideoForMovie(movie!) { (youtubeVideoId) in
                    DispatchQueue.main.async {
                        // set trailer id
                        self.movie?.trailerYoutubeId = youtubeVideoId
                        self.updateView()
                    }
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
        titleLabel.text = movie.title ?? "No title"
        genresLabel.text = movie.genres.joined(separator: ", ")
        yearLabel.text = "\(movie.releaseYear)"
        overviewLabel.text = movie.overview ?? "No overview"
        
        // check if image is already downloaded
        if let image = movie.image {
            imageView.image = image
        } else if activityIndicator.isHidden {
            // using activityIndicator isHidden property to prevent launching multiple downloads
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            // load image
            if let posterPath = movie.posterPath {
                MovieDatabase.sharedInstance.downloadMovieImage(posterPath, withCallback: { (downloadedImage) in
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
            } else {
                // stop spinner if there is no image and show no image label
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.noImageLabel.isHidden = false
                }
            }
        }
        
        if movie.trailerYoutubeId == nil {
            // this removes play button
            navigationItem.rightBarButtonItem = nil
        } else {
            // this adds it back
            navigationItem.rightBarButtonItem = playTrailerButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTrailer" {
            let controller = segue.destination as! TrailerController
            controller.youtubeVideoId = movie?.trailerYoutubeId
        }
    }
}
