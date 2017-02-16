//
//  MovieDatabaseTests.swift
//  Awesome Movie App
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import XCTest
@testable import Awesome_Movie_App

class MovieDatabaseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatImageURLIsFormedCorrectly() {
        // given
        let posterPath = "/6I2tPx6KIiBB4TWFiWwNUzrbxUn.jpg"
        
        // when
        let resultURL = MovieDatabase.APICalls.imageURLForPosterPath(posterPath)
        
        // then
        let expectedResult = "https://image.tmdb.org/t/p/w342/6I2tPx6KIiBB4TWFiWwNUzrbxUn.jpg"
        XCTAssert(resultURL == expectedResult, "The result \"\(resultURL)\"is different than expected.")
    }
    
    func testThatMovieDetailURLIsFormedCorrectly() {
        // given
        let movieID = NSNumber.init(value:328111)
        
        // when
        let resultURL = MovieDatabase.APICalls.movieDetailURLForId(movieID)
        
        // then
        let expectedResult = "https://api.themoviedb.org/3/movie/328111?api_key=44d748443604f06fc59b4ce6d9201418"
        XCTAssert(resultURL == expectedResult, "The result \"\(resultURL)\" is different than expected.")
    }
    
    func testThatPopularMoviesURLForPageIsFormedCorrectly() {
        // given
        let pageNumber = 56
        
        // when
        let resultURL = MovieDatabase.APICalls.popularMoviesURLForPage(pageNumber)
        
        // then
        let expectedResult = "https://api.themoviedb.org/3/movie/popular?api_key=44d748443604f06fc59b4ce6d9201418&page=56"
        XCTAssert(resultURL == expectedResult, "The result \"\(resultURL)\" is different than expected.")
    }
    
    // MARK: - Checks of results from API calls
    // Demonstrates the power of unit tests not only to test units of own code, but also to check for possible changes and discrepancies in API
    // Or gain insight into partial results before UI is complete
    
    func testCheckResultForPopularMoviesQuery() {
        // given
        let queryExpectation = expectation(description: "API request")
        
        // when
        MovieDatabase.sharedInstance.getPopularMovies { (movies) in
            if movies.count > 0 {
                print("Popular movies query received: \(movies)")
            } else {
                XCTAssert(false, "Popular movies query did not get movies.")
            }
            queryExpectation.fulfill()
        }
        
        // then
        self.waitForExpectations(timeout: 3) { (error) in
            XCTAssertNil(error, "Popular movies query took too long.")
        }
    }
    
    func testCheckResultForPopularMoviesPageQuery() {
        // given
        let queryExpectation = expectation(description: "API request")
        
        // when
        MovieDatabase.sharedInstance.getPopularMovies(onPage: 3, withCallback: { (movies) in
            if movies.count > 0 {
                print("Popular movies query received: \(movies)")
            } else {
                XCTAssert(false, "Popular movies page query did not get movies.")
            }
            queryExpectation.fulfill()
        })
        
        // then
        self.waitForExpectations(timeout: 3) { (error) in
            XCTAssertNil(error, "Popular movies page query took too long.")
        }
    }
    
    func testCheckImageResultForDownloadingMovieImage() {
        // given
        let queryExpectation = expectation(description: "API request")
        let jurassicWorldImagePath = "/dkMD5qlogeRMiEixC4YNPUvax2T.jpg"
        
        // when
        MovieDatabase.sharedInstance.downloadMovieImage(jurassicWorldImagePath, withCallback: { (image) in
            if image != nil {
                print("Image was downloaded")
            } else {
                XCTAssert(false, "Image was not downloaded or is corrupted.")
            }
            queryExpectation.fulfill()
        })
        
        // then
        self.waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "Download movie image query took too long.")
        }
    }
    
    func testCheckResultForMovieDetailsQuery() {
        // given
        let queryExpectation = expectation(description: "API request")
        let jurassicWorldMovie = MovieEntity(withDictionary: ["id":135397, ])
        
        // when
        MovieDatabase.sharedInstance.getDetailsForMovie(jurassicWorldMovie) { (dictionary) in
            if dictionary.count > 0 {
                print("Details for movie fetched: \(dictionary)")
            } else {
                XCTAssert(false, "Details were not fetched correctly.")
            }
            queryExpectation.fulfill()
        }
        
        // then
        self.waitForExpectations(timeout: 3) { (error) in
            XCTAssertNil(error, "Popular movies page query took too long.")
        }
    }
}
