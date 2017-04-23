//
//  MovieDetailController.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class MovieDetailController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet var playTrailerButton: UIBarButtonItem!
    
    var trailerView:YTPlayerView? = nil
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(stopTrailer), name: .UIWindowDidBecomeHidden, object: nil)
        updateView()
    }
    
    @IBAction func playTrailer(_ sender: Any) {
        navigationItem.rightBarButtonItem = nil
//        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        delegate.desiredOrientation = UIInterfaceOrientationMask.landscape
//        let value = UIInterfaceOrientation.landscapeRight.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
        
        navigationItem.hidesBackButton = true
        
        let playerView = YTPlayerView(frame: view.frame)
        trailerView = playerView
//        playerView.isHidden = true
        view.addSubview(playerView)
        playerView.delegate = self
        playerView.load(withVideoId: "Ud8j5GaqH3c", playerVars: ["playsinline" : 0]) //Vogou6DN97w, Ud8j5GaqH3c
    }
    
    func stopTrailer() {
        trailerView?.stopVideo()
        trailerView?.removeFromSuperview()
        trailerView = nil
        
        navigationItem.hidesBackButton = false
        
//        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        delegate.desiredOrientation = UIInterfaceOrientationMask.portrait
//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")

        navigationItem.rightBarButtonItem = playTrailerButton
    }
}

extension MovieDetailController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .unstarted {
            // TODO show message
            stopTrailer()
            return
        }
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        // TODO display simple error message
        stopTrailer()
    }
}
