//
//  MovieEntityTests.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import XCTest
@testable import Awesome_Movie_App

class MovieEntityTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatMovieEntityIsInitilizedWithCorrectDictionary() {
        // given
        let movieDictionary = ["id":1, "title":"The Amazing Movie", "backdrop_path":"/image21576.jpg", "release_date":"2017-01-01", "overview":"The best movie ever made."] as [String : Any]
        
        // when
        let movie = MovieEntity(withDictionary: movieDictionary)
        
        // then
        XCTAssert(movie.movieId == 1, "Wrong movie id was set.")
        XCTAssert(movie.title == "The Amazing Movie", "Wrong title was set.")
        XCTAssert(movie.posterPath == "/image21576.jpg", "Wrong poster path was set.")
        XCTAssert(movie.releaseYear == 2017, "Wrong release year was set.")
        XCTAssert(movie.overview == "The best movie ever made.", "Wrong overview was set.")
        XCTAssert(movie.genres == [], "Genres should not be set.")
        XCTAssert(movie.image == nil, "Image should not be set.")
    }
    
    func testThatWrongDateFormatFallbacksToZero() {
        // given
        let movieDictionary = ["id":1, "title":"The Amazing Movie", "backdrop_path":"/image21576.jpg", "release_date":"01-01-2017", "overview":"The best movie ever made."] as [String : Any]
        
        // when
        let movie = MovieEntity(withDictionary: movieDictionary)
        
        // then
        XCTAssert(movie.releaseYear == 0, "Release year should have fallback to zero.")
    }
    
    func testThatEmptyDictionaryCausesValuesToFallback() {
        // given
        let movieDictionary = [String : Any]()
        
        // when
        let movie = MovieEntity(withDictionary: movieDictionary)
        
        // then
        XCTAssert(movie.movieId == 0, "Movie id should fallback to zero")
        XCTAssert(movie.title == "No Title", "Title should fallback to \"No Title\"")
        XCTAssert(movie.posterPath == "", "Poster path should fallback to empty string.")
        XCTAssert(movie.releaseYear == 0, "Release year should fallback to zero.")
        XCTAssert(movie.overview == "", "Overview should fallback to empty string.")
        XCTAssert(movie.genres == [], "Genres should not be set.")
        XCTAssert(movie.image == nil, "Image should not be set.")
    }
    
    func testThatWrongDictionaryCausesValuesToFallback() {
        // given
        let movieDictionary = ["id":"uniqueId", "title":1, "backdrop_path":["path1":"/something.jpg"], "release_date":"5thApril", "overview":["word1","word2","word3"]] as [String : Any]
        
        // when
        let movie = MovieEntity(withDictionary: movieDictionary)
        
        // then
        XCTAssert(movie.movieId == 0, "Movie id should fallback to zero")
        XCTAssert(movie.title == "No Title", "Title should fallback to \"No Title\"")
        XCTAssert(movie.posterPath == "", "Poster path should fallback to empty string.")
        XCTAssert(movie.releaseYear == 0, "Release year should fallback to zero.")
        XCTAssert(movie.overview == "", "Overview should fallback to empty string.")
        XCTAssert(movie.genres == [], "Genres should not be set.")
        XCTAssert(movie.image == nil, "Image should not be set.")
    }
    
    func testThatImageSetIsImageGot() {
        // given 
        let imageSet = UIImage(data:UIImagePNGRepresentation(#imageLiteral(resourceName: "icon"))!)! // this construct removes scale factor which would change when saving
        let movieDictionary = ["id":1, "title":"The Amazing Movie", "backdrop_path":"/image21576.jpg", "release_date":"2017-01-01", "overview":"The best movie ever made."] as [String : Any]
        let movie = MovieEntity(withDictionary: movieDictionary)
        
        // when
        movie.image = imageSet
        let imageGot = movie.image!
        
        // then
        let data1 = UIImagePNGRepresentation(imageSet)!
        let data2 = UIImagePNGRepresentation(imageGot)!
        XCTAssert(data1 == data2, "Image data should be same for set and got images.")
    }
}
