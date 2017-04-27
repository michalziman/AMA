//
//  MovieCell.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noImageLabel: UILabel!
    
    var movie:MovieEntity? {
        didSet {
            // after setting movie show title, clear image view and start loading image (which may be fast if it is already cached in temp folder)
            titleLabel.text = movie?.title
            self.posterImageView.image = nil
            // also hide no image label
            self.noImageLabel.isHidden = true
            if movie != nil {
                // Image loading is done in background to avoid tiny freezes while scrolling
                DispatchQueue.global(qos: .background).async {
                    self.loadImageForMovie(self.movie!)
                    // Get missing details before displaying details, so that displaying is smoother. The cost of date is not much for this purpose.
                    MovieDatabase.sharedInstance.getDetailsForMovie(self.movie!) { (movieDict) in
                        DispatchQueue.main.async {
                            // set genres
                            self.movie?.parseGenres(fromDictionary: movieDict)
                        }
                    }
                    MovieDatabase.sharedInstance.getYoutubeVideoForMovie(self.movie!) { (youtubeVideoId) in
                        DispatchQueue.main.async {
                            // set trailer id
                            self.movie?.trailerYoutubeId = youtubeVideoId
                        }
                    }
                }
            }
        }
    }
    
    func loadImageForMovie(_ movie:MovieEntity) {
        if let alreadyLoadedImage = movie.image {
            // if movie already has image saved in temp directory, show it in image view
            DispatchQueue.main.async {
                self.posterImageView.image = alreadyLoadedImage
                self.activityIndicator.stopAnimating()
            }
            return
        }
        
        // show spinner
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        // load image
        if let posterPath = movie.posterPath {
            MovieDatabase.sharedInstance.downloadMovieImage(posterPath, withCallback: { (downloadedImage) in
                DispatchQueue.main.async {
                    // stop spinner when image is loaded, successfully or not
                    self.activityIndicator.stopAnimating()
                    if downloadedImage != nil {
                        // if download succeeded, save image for the movie to temp directory
                        movie.image = downloadedImage
                        if self.movie == movie {
                            // if the same movie is displayed in cell as was downloaded, show image in image view
                            self.posterImageView.image = downloadedImage
                        }
                    }
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

}
