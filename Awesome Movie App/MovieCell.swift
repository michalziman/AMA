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
    
    var movie:MovieEntity? {
        didSet {
            // after setting movie show title, clear image view and start loading image (which may be fast if it is already cached in temp folder)
            titleLabel.text = movie?.title
            self.posterImageView.image = nil
            if movie != nil {
                // Image loading is done in background to avoid tiny freezes while scrolling
                DispatchQueue.global(qos: .background).async {
                    self.loadImageForMovie(self.movie!)
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
        if movie.posterPath != "" {
            MovieDatabase.sharedInstance.downloadMovieImage(movie.posterPath, withCallback: { (downloadedImage) in
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
        }
    }

}
