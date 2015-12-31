//
//  ViewController.swift
//  WhRWe
//
//  Created by csev on 12/30/15.
//  Copyright © 2015 com.whrwe. All rights reserved.
//

// http://www.johnmullins.co/blog/2014/08/14/location-tracker-with-maps/

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var theMap: MKMapView!
    
    @IBOutlet weak var theLabel: UILabel!
    
    @IBOutlet weak var theButton: UIButton!
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    @IBAction func buttonPress(sender: AnyObject) {
        print("Pushed")
        let url = NSURL(string: "https://www.dr-chuck.net/json.php")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {(data: NSData?, reponse, error) in
            print("Task completed")
            // print(data)
            let theString:NSString = NSString(data: data!, encoding: NSASCIIStringEncoding)!
            print(theString)
            // print(response)
            print(error)
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print(jsonResult)
            } catch let caught as NSError {
                print("Sucks")
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        // manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestAlwaysAuthorization()
        // manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        manager.distanceFilter = 50
        manager.pausesLocationUpdatesAutomatically = true

        
        let location = CLLocationCoordinate2D(
            latitude: 51.50007773,
            longitude: -0.1246402
        )
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        theMap.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Big Ben"
        annotation.subtitle = "London"
        
        theMap.addAnnotation(annotation)

        //Setup our Map View
        theMap.delegate = self
        theMap.showsUserLocation = true
    }
    
    //Location manager delegate function
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        theLabel.text = "\(locations[0])"
        myLocations.append(locations[0] as CLLocation)
        
        let spanX = 0.007
        let spanY = 0.007
        let newRegion = MKCoordinateRegion(center: theMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        theMap.setRegion(newRegion, animated: true)
        
        if(UIApplication.sharedApplication().applicationState == .Background){
            print("background call")
        }else{
            print("foreground call")
        }
        
        print(locations[0])
        if (myLocations.count > 1){
            let sourceIndex = myLocations.count - 1
            let destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            let polyline = MKPolyline(coordinates: &a, count: a.count)
            theMap.addOverlay(polyline)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

