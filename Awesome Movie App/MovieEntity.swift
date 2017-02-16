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
    let title: String
    let posterPath: String
    let releaseYear: Int
    var genres: [String]
    var overview: String

    // Downloaded image is saved to temp directory (lasts cca 2 days there) as a cache
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
        title = (dictionary["title"] as? String) ?? "No Title"
        posterPath = (dictionary["backdrop_path"] as? String) ?? "" // backdrop_path seems more fitting than poster_path
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = (dictionary["release_date"] as? String) ?? ""
        if let date = dateFormatter.date(from: dateString) {
            releaseYear = Calendar.current.component(.year, from:date)
        } else {
            releaseYear = 0
            // will not be showed because is less than min 1890 in filter
            // it is ok, with unknown year it cannot be filtered anyway
        }
        
        genres = [] // genres described in words are not present in movie list, only detailed info
        overview = (dictionary["overview"] as? String) ?? ""
    }
    
    override var description: String {
        return "\nMovieEntity: \n\tid: \(movieId), \n\tTitle: \"\(title)\", \n\tPoster Path: \"\(posterPath)\", \n\tRelease Year: \(releaseYear), \n\tGenres: \(genres), \n\tOverview: \"\(overview)\"\n"
    }
}
