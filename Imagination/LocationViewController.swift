//
//  LocationViewController.swift
//  Imagination
//
//  Created by Star on 16/8/27.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
let reusableIdentifier = "MapTableViewCell"
class LocationViewController: UIViewController,CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    var locManager:CLLocationManager!
    var placeInfo:[(name:String,coor:CLLocationCoordinate2D)] = []
    var placeSelected:((_ place:(name:String,coor:CLLocationCoordinate2D))->Void)?
    let coder = CLGeocoder()
    var animation:UIActivityIndicatorView!
    var placeToShow:CLLocationCoordinate2D? //外面传进来
    var onceBool:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.distanceFilter = 1000.0
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        
        
        //self.mapView.userTrackingMode = .Follow
        self.mapView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        animation = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        animation.frame = CGRect(x:self.view.frame.width/2-50,y:self.view.frame.height/2-50,width:100, height:100)
        self.view .addSubview(animation)
        
        if self.placeToShow != nil {
            let cor = reverseTransformCoordinate(cor: self.placeToShow!)
            self.addAnnotationWithCoordinate(CLLocation(latitude: cor.latitude,longitude: cor.longitude))
        }else{
            locManager.startUpdatingLocation()
        }
    }

    func addAnnotationWithCoordinate(_ loc:CLLocation) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        animation.startAnimating()
        coder.reverseGeocodeLocation(loc, completionHandler: {
            pls,error in
            self.animation.stopAnimating()
            if error == nil {
                
                if let place = pls?.first {
                    let region = MKCoordinateRegionMakeWithDistance(place.location!.coordinate, 1500, 1500)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(Annotation(coor: place.location!.coordinate,pMark: place))
                }
                
            }else{
                Dlog(error!.localizedDescription);
            }
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: -Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locManager.stopUpdatingLocation()
        if let newLocation = locations.last {
            if !onceBool {
                onceBool = true
                GaodeMapApi.getNearByLocations(cor: newLocation.coordinate){
                    rst in
                    self.placeInfo = rst
                    DispatchQueue.main.async {
                        self.addAnnotationWithCoordinate(CLLocation(latitude: self.placeInfo.first!.coor.latitude, longitude: self.placeInfo.first!.coor.longitude))
                        self.tableView.reloadData()
                        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                    }
                }
            }
            
        }
    }

    //MARK: -Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placeInfo.count
    }
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier, for: indexPath as IndexPath)
        cell.selectionStyle = .gray
        cell.textLabel?.text = self.placeInfo[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.placeSelected != nil {
            let place = self.placeInfo[indexPath.row]
            self.placeSelected!(place)
            addAnnotationWithCoordinate(CLLocation(latitude: place.coor.latitude, longitude: place.coor.longitude))
        }
    }
    
    //MARK: MapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annoView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableIdentifier) {
            annoView.annotation = annotation
            return annoView
        }else{
            let annoVIew = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: reusableIdentifier)
            annoVIew.canShowCallout = true
            annoVIew.pinTintColor = MKPinAnnotationView.redPinColor()
            annoVIew.isHighlighted = true
            annoVIew.isDraggable = true
            return annoVIew
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        let cor = reverseTransformCoordinate(cor: view.annotation!.coordinate)
        if newState == .ending {
            animation.startAnimating()
            let loc = CLLocation(latitude: cor.latitude, longitude: cor.longitude)
            self.coder.reverseGeocodeLocation(loc, completionHandler: {
                pls,error in
                self.animation.stopAnimating()
                if error == nil {
                    if let place = pls?.first {
                        self.mapView.removeAnnotation(view.annotation!)
                        self.mapView.addAnnotation(Annotation(coor: place.location!.coordinate, pMark: place))
                        self.placeInfo.insert((place.name!,place.location!.coordinate), at: 0)
                        self.tableView.reloadData()
                        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                    }
                }else{
                    Dlog(error!.localizedDescription);
                }
            })
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        Dlog(error.localizedDescription)
    }
    

    //地址有偏移 code的结果在location的右下角
    //第一个前提是 系统自我定位时候 获取的location不正确 而coder后的是正确的
    //第二个前提是 annotationview 拖拽后拿到的location是正确的 经过coder后不正确了 所以这里在didchangeDrageState里使用reverseTranslate修正
    //具体原因有待搜寻 iOS10.0后不再存在
    
    func transformCoordinate(cor:CLLocationCoordinate2D)->CLLocationCoordinate2D{
        let version = UIDevice.current.systemVersion
        switch version.compare("10.0.0", options: .numeric, range: nil, locale: nil) {
        case.orderedAscending:
            let newx = cor.latitude*(30.501500482611835/30.503810239337618)
            let newy = cor.longitude*(114.42497398363371/114.41945126570926)
            return CLLocationCoordinate2D(latitude: newx,longitude: newy)
        default:
            return cor;
        }
    }
    
    func reverseTransformCoordinate(cor:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let version = UIDevice.current.systemVersion
        switch version.compare("10.0.0", options: .numeric, range: nil, locale: nil) {
        case.orderedAscending:
            let newx = cor.latitude/(30.501500482611835/30.503810239337618)
            let newy = cor.longitude/(114.42497398363371/114.41945126570926)
            return CLLocationCoordinate2D(latitude: newx, longitude: newy)
        default:
            return cor;
        }
    }

}
