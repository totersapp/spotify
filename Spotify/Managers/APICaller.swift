//
//  APICaller.swift
//  Spotify
//
//  Created by Ali Hammoud on 4/30/21.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init(){}
    struct Constans {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    enum APIError: Error{
        case failedToGetData
    }
    public func getCurrentUserProfile(completeion: @escaping (Result<UserProfile,Error>)->()){
        creatRequest(with: URL(string: Constans.baseAPIURL + "/me"),
                     type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest){ data, _, error in
                guard let data = data, error == nil else{
                    completeion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completeion(.success(result))
                }
                catch{
                    completeion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    public func getRecomnadationsGenres(completion: @escaping ((Result<RecommendedGenresResponse,Error>)->()))  {
        creatRequest(with: URL(string: Constans.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { (request) in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse,Error>)->()))  {
        let seeds = genres.joined(separator: ",")
        creatRequest(with: URL(string: Constans.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET) { (request) in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturePlayLists(completion: @escaping ((Result<FeaturedPlaylistsResponse,Error>)->()))  {
        creatRequest(with: URL(string: Constans.baseAPIURL + "/browse/featured-playlists?limit=2"), type: .GET) { (request) in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getNewReleases(completeion: @escaping ((Result<NewReleaseResponse, Error>))->()){
        creatRequest(with: URL(string: Constans.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { (result) in
            let task = URLSession.shared.dataTask(with: result) { (data, _, error) in
                guard let data = data, error == nil else{
                    completeion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(NewReleaseResponse.self, from: data)
                    completeion(.success(result))
                }
                catch{
                    completeion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Private
    private func creatRequest(with url: URL?, type: HTTPMethod, completeion: @escaping (URLRequest)->()){
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else{
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completeion(request)
        }
    }
}
