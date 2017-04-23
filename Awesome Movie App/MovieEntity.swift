//
//  MovieEntity.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit

class MovieEntity: NSObject {
    let movieId: NSNumber
    let title: String?
    let posterPath: String?
    let releaseYear: Int
    var genres: [String]
    var overview: String?
    var trailerYoutubeId: String?
    
    private static let dateFormatter = DateFormatter()
    
    // Downloaded image is saved to temp directory (lasts cca 2 days there) as a cache
    // Both methods should be used on background thread
    var imageURL: URL {
        return URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(movieId).png")
    }
    var image: UIImage? {
        get {
            
            guard let data = try? Data(contentsOf: imageURL) else {
                return nil
            }
            return UIImage(data: data)
        }
        set {
            if let image = newValue {
                if let data = UIImagePNGRepresentation(image) {
                    try? data.write(to: imageURL)
                }
            }
        }
    }
    
    init(withDictionary dictionary:[String:Any]) {
        movieId = (dictionary["id"] as? NSNumber) ?? 0
        title = (dictionary["title"] as? String)
        posterPath = (dictionary["backdrop_path"] as? String)// backdrop_path seems more fitting than poster_path
        
        MovieEntity.dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = (dictionary["release_date"] as? String) ?? ""
        if let date = MovieEntity.dateFormatter.date(from: dateString) {
            releaseYear = Calendar.current.component(.year, from:date)
        } else {
            releaseYear = 0
            // will not be showed because is less than min 1890 in filter
            // it is ok, with unknown year it cannot be filtered anyway
        }
        
        genres = [] // genres described in words are not present in movie list, only detailed info
        overview = (dictionary["overview"] as? String)
    }
    
    func parseGenres(fromDictionary dictionary:[String:Any]) {
        let genresDictionaries = dictionary["genres"] as? [[String:Any]] ?? []
        var movieGenres = [String]()
        for genreDict in genresDictionaries {
            if let genreName = genreDict["name"] as? String {
                movieGenres.append(genreName)
            }
        }
        self.genres = movieGenres
    }
    
    override var description: String {
        return "\nMovieEntity: \n\tid: \(movieId), \n\tTitle: \"\(title ?? "nil")\", \n\tPoster Path: \"\(posterPath ?? "nil")\", \n\tRelease Year: \(releaseYear), \n\tGenres: \(genres), \n\tOverview: \"\(overview ?? "nil")\"\n"
    }
}
