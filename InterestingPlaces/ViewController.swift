import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    var placesViewController: PlaceScrollViewController?
    
    var locationManager: CLLocationManager?
    var previousLocation: CLLocation?
    
    var places: [Place] = []
    var selectedPlace: Place? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let childViewController = children.first as? PlaceScrollViewController {
            placesViewController = childViewController
        }
        
        loadPlaces()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters // default - best accuracy
        
        selectedPlace = places.first
        updateUI()
        
        placesViewController?.addPlaces(places: places)
        placesViewController?.delegate = self
        
    }
    
    func selectPlace() {
        print("place selected")
    }
    
    // check the status of authorization or initiate the request
    @IBAction func startLocationService(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            activateLocationServices()
            
        } else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    private func activateLocationServices() {
        locationManager?.startUpdatingLocation()
    }
    
    func loadPlaces() {
        
        guard let entries = loadPlist() else { fatalError("Unable to load data") }
        
        for property in entries {
            guard let name = property["Name"] as? String,
                let latitude = property["Latitude"] as? NSNumber,
                let longitude = property["Longitude"] as? NSNumber,
                let image = property["Image"] as? String else { fatalError("Error reading data") }
            
            let place = Place(latitude: latitude.doubleValue, longitude: longitude.doubleValue, name: name, imageName: image)
            places.append(place)
        }
    }
    
    private func loadPlist() -> [[String: Any]]? {
        
        guard let plistUrl = Bundle.main.url(forResource: "Places", withExtension: "plist"),
            let plistData = try? Data(contentsOf: plistUrl) else {
            return nil
        }
        
        var placedEntries: [[String: Any]]? = nil
        
        do {
            placedEntries = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [[String: Any]]
        } catch {
            print("error reading list")
        }
        return placedEntries
    }
    
    private func updateUI() {
        placeName.text = selectedPlace?.name
        guard let imageName = selectedPlace?.imageName,
            let image = UIImage(named: imageName) else { return }
        placeImage.image = image
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            activateLocationServices()
        }
    }
    
    // after activation app starts receiving locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if previousLocation == nil {
            previousLocation = locations.first
        } else {
            guard let latest = locations.first else { return }
            let distanceInMeters = previousLocation?.distance(from: latest) ?? 0
            print("distance in meters: \(distanceInMeters)")
            previousLocation = latest
        }
    }
}

extension ViewController: PlaceScrollViewControllerDelegate {
    
    func selectedPlaceViewController(_ controller: PlaceScrollViewController, didSelectPlace place: Place) {
        
        selectedPlace = place
        updateUI()
    }
}
