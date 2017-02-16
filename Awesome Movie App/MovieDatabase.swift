//
//  MovieDatabase.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDatabase: NSObject {
    struct APICalls {
        private static let apiKeySuffix = "?api_key=44d748443604f06fc59b4ce6d9201418"
        private static let imageURLPrefix = "https://image.tmdb.org/t/p/w342"
        private static let movieDetailURLPrefix = "https://api.themoviedb.org/3/movie/"
        private static let pageSuffix = "&page="
        
        static let popularMoviesURL = "https://api.themoviedb.org/3/movie/popular?api_key=44d748443604f06fc59b4ce6d9201418"
        
        static func imageURLForPosterPath(_ posterPath:String) -> String {
            return "\(APICalls.imageURLPrefix)\(posterPath.removingPercentEncoding ?? "")"
        }
        
        static func movieDetailURLForId(_ movieId:NSNumber) -> String {
            return "\(APICalls.movieDetailURLPrefix)\(movieId.stringValue)\(apiKeySuffix)"
        }
        
        static func popularMoviesURLForPage(_ page:Int) -> String {
            return "\(popularMoviesURL)\(pageSuffix)\(page)"
        }
    }
    
    static let sharedInstance = MovieDatabase()
    
    func getPopularMovies(withCallback callback:@escaping ([MovieEntity]) -> ()) {
        getPopularMovies(onPage: 1, withCallback: callback)
    }
    
    func getPopularMovies(onPage page:Int, withCallback callback:@escaping ([MovieEntity]) -> ()) { // on error, callback is with empty array
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.get(MovieDatabase.APICalls.popularMoviesURLForPage(page), parameters: nil, progress: nil, success: { (task, response) in
            //            print("JSON response: \(response ?? "NO RESPONSE")")
            // as parsing response, check for integrity. If there is something wrong, callback empty (error)
            guard let enclosingDict = response as? [String:Any] else {
                callback([])
                return
            }
            guard let resultArray = enclosingDict["results"] as? [[String:Any]] else {
                callback([])
                return
            }
            // parse loaded movies and call callback
            var movies = [MovieEntity]()
            for dictionary in resultArray {
                movies.append(MovieEntity(withDictionary: dictionary))
            }
            callback(movies)
            
        }) { (task, error) in
            // callback empty on error
            print("Error: \(error)")
            callback([])
        }
    }
    
    func downloadMovieImage(_ path:String, withCallback callback:@escaping (UIImage?) -> ()) {
        // just download image using afnetworking and return it, or return nil
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFImageResponseSerializer()
        manager.get(APICalls.imageURLForPosterPath(path), parameters: nil, progress: nil, success: { (task, response) in
            callback(response as? UIImage)
        }) { (task, error) in
            print("Error: \(error)")
            callback(nil)
        }
    }
    
    func getDetailsForMovie(_ movie:MovieEntity, withCallback callback:@escaping ([String:Any]) -> ()) {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.get(MovieDatabase.APICalls.movieDetailURLForId(movie.movieId), parameters: nil, progress: nil, success: { (task, response) in
            //            print("JSON response: \(response ?? "NO RESPONSE")")
            // as parsing response, check for integrity. If there is something wrong, callback empty dictionary
            guard let resultDict = response as? [String:Any] else {
                callback([:])
                return
            }
            // otherwise callback with dictionary
            callback(resultDict)
            
        }) { (task, error) in
            // callback empty on error
            print("Error: \(error)")
            callback([:])
        }
    }
}
