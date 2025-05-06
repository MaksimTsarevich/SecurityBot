//
//  GetLocation.swift
//  VpnSafety
//
//  Created by Воробьев Александр on 10.10.22.
//
import UIKit

class GetLocation {
    
    // - Data
    private var url = "https://wake-shield.com/"
    
    func getLocation(completion: @escaping (_ locations: [LocationModel]?) -> Void) {
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("owmgi7afv", forHTTPHeaderField: "AuthToken")
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let locations = try decoder.decode([LocationModel].self, from: data)
                completion(locations)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }.resume()
    }
    
}
