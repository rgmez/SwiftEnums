//
//  NavigationServices.swift
//  
//
//  Created by Roberto Gomez Muñoz on 14/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public enum NavigationServices {
    case AppleMaps
    case GoogleMaps
    case Waze
    
    private static let allServices: [NavigationServices] = [.AppleMaps, .GoogleMaps, .Waze]
    private static var availableServices: [NavigationServices] { return allServices.filter(availableService) }
    
    private var name: String {
        switch self {
        case .AppleMaps:
            return "Apple Maps"
        case .GoogleMaps:
            return "Google Maps"
        case .Waze:
            return "Waze"
        }
    }
    
    private var baseURL: String {
        switch self {
        case .AppleMaps:
            return "maps.apple.com://"
        case .GoogleMaps:
            return "comgooglemaps://"
        case .Waze:
            return "waze://"
        }
    }
    
    private func serviceUrlString(_ location: CLLocationCoordinate2D) -> String {

        switch self {
        case .AppleMaps:
            return "\(baseURL)?q=\(location.latitude),\(location.longitude)=d&t=h"
        case .GoogleMaps:
            return "\(baseURL)?saddr=&daddr=\(location.latitude),\(location.longitude)&directionsmode=driving"
        case .Waze:
            return "\(baseURL)?ll=\(location.latitude),\(location.longitude)&navigate=yes"
        }
    }
    
    private func serviceUrl(_ location: CLLocationCoordinate2D) -> URL? {
        return URL(string: self.serviceUrlString(location))
    }
    
    private static func availableService(_ service: NavigationServices) -> Bool {
        if service == .AppleMaps { return true }
        
        return URL(string: service.baseURL).flatMap { UIApplication.shared.canOpenURL($0) } ?? false
    }
    
    public func openWith(_ location: CLLocationCoordinate2D, options: [String: AnyObject] = [:], completion: @escaping (Bool) -> ()) {
        if self == .AppleMaps {
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary:nil))
            completion(mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]))
        }
        
        self.serviceUrl(location).flatMap{
            UIApplication.shared.open($0, options: options, completionHandler: completion)
        } ?? completion(false)
    }
    
    public static func alertController(location: CLLocationCoordinate2D, title: String, message: String?, completion: @escaping (Bool) -> ()) -> UIAlertController {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
     
        NavigationServices.availableServices.forEach{ navType in
            alertVC.addAction(UIAlertAction(title: navType.name, style: .default, handler: { action in
                navType.openWith(location, completion: {
                    completion($0)
                })
            }))
        }
    
        alertVC.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: { (action) in
            completion(false)
        }))
        return alertVC
    }
}
