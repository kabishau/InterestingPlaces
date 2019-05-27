import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var placesViewController: PlaceScrollViewController?
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    var places: [Place] = []
    var selectedPlace: Place? = nil
    
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let childViewController = children.first as? PlaceScrollViewController {
            placesViewController = childViewController
        }
        
        loadPlaces()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters // default - best accuracy
        locationManager?.allowsBackgroundLocationUpdates = true
        
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
            //locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    private func activateLocationServices() {
        //locationManager?.startUpdatingLocation()
        locationManager?.requestLocation() // + delegation method for error handling
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
    
    private func printAddress() {
        guard let selectedPlace = selectedPlace else { return }
        geocoder.reverseGeocodeLocation(selectedPlace.location) { [weak self] (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let placemark = placemarks?.first else { return }
            if let streetNumber = placemark.subThoroughfare,
                let street = placemark.thoroughfare,
                let city = placemark.locality,
                let state = placemark.administrativeArea {
                self?.addressLabel.text = "\(streetNumber) \(street) \(city), \(state)"
                
            }
        }
    }
    
    private func updateUI() {
        placeName.text = selectedPlace?.name
        guard let imageName = selectedPlace?.imageName,
            let image = UIImage(named: imageName) else { return }
        placeImage.image = image
        
        guard let currentLocation = currentLocation,
            let distanceInMeters = selectedPlace?.location.distance(from: currentLocation) else { return }
        let distance = Measurement(value: distanceInMeters, unit: UnitLength.meters)
        let miles = distance.converted(to: UnitLength.miles)
        locationDistance.text = "\(miles) miles"
        
        printAddress()
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
        
        currentLocation = locations.first
        updateUI()
    }
    
    // optinal but required when working with requestLocation method
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension ViewController: PlaceScrollViewControllerDelegate {
    
    func selectedPlaceViewController(_ controller: PlaceScrollViewController, didSelectPlace place: Place) {
        
        selectedPlace = place
        updateUI()
    }
}
