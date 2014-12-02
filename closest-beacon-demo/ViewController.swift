//
//  ViewController.swift
//  closest-beacon-demo
//
//  Created by Will Dages on 10/11/14.
//  @willdages on Twitter
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

  let locationManager = CLLocationManager()
  let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "23538C90-4E4C-4183-A32B-381CFD11C465"), identifier: "Nomi")
  var bytes: NSMutableData?

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    locationManager.delegate = self
    if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
      locationManager.requestWhenInUseAuthorization()
    }
    locationManager.startRangingBeaconsInRegion(region)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
    if (knownBeacons.count > 0) {
      let closestBeacon = knownBeacons[0] as CLBeacon

      var message:String = ""

      switch closestBeacon.proximity {
      case CLProximity.Far:
        message = "You are far away from the beacon"
      case CLProximity.Near:
        message = "You are near the beacon"
      case CLProximity.Immediate:
        message = "You're on it. Retrieving JSON state"
        NSLog(message)
        //Retrieve State of Kiosk
        let url = "http://kiosk-service-proto.herokuapp.com/api/kiosks/master/kiosks/23/state"
        let request = NSURLRequest(URL: NSURL(string: url)!)
        let loader = NSURLConnection(request: request, delegate: self, startImmediately: true)
      case CLProximity.Unknown:
        return
      }

    }
  }


  func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
    self.bytes?.appendData(conData)
  }

  func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
    self.bytes = NSMutableData()
  }

  func connectionDidFinishLoading(connection: NSURLConnection!) {

    // we serialize our bytes back to the original JSON structure
    let jsonResult: Dictionary = NSJSONSerialization.JSONObjectWithData(self.bytes!, options: NSJSONReadingOptions.MutableContainers, error: nil) as Dictionary<String, AnyObject>
    let destination:Dictionary = jsonResult["destination"] as Dictionary<String, AnyObject>

    let storeName:String = destination["name"] as String
    let storeDescription:String = destination["description"] as String

    self.titleLabel.text = storeName
    self.descriptionLabel.text = storeDescription

    NSLog("Find and show store: \(storeName), \(storeDescription)")



  }



}

