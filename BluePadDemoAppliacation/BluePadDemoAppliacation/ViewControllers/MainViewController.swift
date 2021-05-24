

//
//  MainViewController.swift
//  BluePad
//
//  Created by Вова Ващеня on 24.05.2021.
//
import UIKit
//import xcframework
import BluePad50v2
@available(iOS 13.0, *)
class MainViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTableView = 0
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        scheduledTimerWithTimeInterval()
        print("BluePad ->\(bluePad)")
    }
    //values
    var timer = Timer()
    var bluePad = BluePad.init()
    //UI
    @IBOutlet weak var segmentControllOutlet: UISegmentedControl!
    var currentTableView : Int!
    @IBOutlet weak var tableView: UITableView!
    
    //TableViewData
    var sections = ["TRANSACTIONS","REPORTS","Date&Time"]
    var rows = [
        //Transactions
        ["TestConnection","Purchase","PurchaseCashBack","VoidPurchase","PuchaseReturn","UniversalReversal","UniversalReversalAdvice","Autorization","AutorizationConfirm","KeyChange","BalanceInquiry","EndOfDay"],
        //Reports
        ["Receipt tags","Last tag","Last tags","Report info","Report tags","Report by stan","Last error code","Last error msg","Pin pad info","Ping","Version"],
        //Date&Time
        ["Get Date&Time","Set Date&Time","SetTimeOut"]]
    //IBActions
    @IBAction func segmentControll(_ sender: UISegmentedControl) {
        currentTableView = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    //Connect to device
    @IBAction func connect(_ sender: Any) {
        navigationController?.view.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
        showSpinner()
        DispatchQueue.init(label: "openPort").async { [self] in
            let open = bluePad.openPort()
            DispatchQueue.main.sync { [self] in
                if open {
                    var modelname = ""
                    var serialNumber = ""
                    var terminalID = ""
                    var softVer = ""
                    var menutype : UInt8 = 0
                    bluePad.getPinpadInfo(&modelname, &serialNumber, &softVer, &terminalID, &menutype)
                    showMessage(title: "Connected", message: "ModelName<\(modelname)>\nSerialNumber<\(serialNumber)>\nTerminalID<\(terminalID)>")
                    
                }else{
                    showMessage(title: "Failed", message: "")
                    
                    removeSpinner()
                }
                removeSpinner()
                self.view.isUserInteractionEnabled = true
                navigationController?.view.isUserInteractionEnabled = true
            }
        }
    }
    
    
    //Disconnect
    @IBAction func disconnect(_ sender: Any) {
        if bluePad.portOpened{
            bluePad.closePort()
            if !bluePad.portOpened{
                showMessage(title: "Disconnected", message: "")
            }
        }else{
            showMessage(title: "Device not connected", message: "")
        }
    }
}
@available(iOS 13.0, *)
//Updating connecting state to device
extension MainViewController{
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    @objc func updateCounting(){
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async { [self] in
                if bluePad.portOpened{
                    segmentControllOutlet.selectedSegmentTintColor = .green
                }else{
                    segmentControllOutlet.selectedSegmentTintColor = .red
                }
            }
        }
    }
}



