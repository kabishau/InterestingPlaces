import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var location: CLLocation?

    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func closeMap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .satellite
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appleHQ = CLLocation(latitude: 37.334722, longitude: -122.008889)
        let regionRadius: CLLocationDistance = 1000.0
        let region = MKCoordinateRegion(center: appleHQ.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
    }
}

extension MapViewController: MKMapViewDelegate {
    
}
