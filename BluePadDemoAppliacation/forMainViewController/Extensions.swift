//
//  Extensions.swift
//  BluePadDemoAppliacation
//
//  Created by Вова Ващеня on 24.05.2021.
//

import Foundation
import UIKit
fileprivate var aView : UIView?
@available(iOS 13.0, *)
//Table view delegate&datasourse methods
extension MainViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[currentTableView].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = rows[currentTableView][indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentTableView == 0{
            makeTransaction(indexPath: indexPath)
        }
        if currentTableView == 1{
            makeReports(indexPath: indexPath)
        }
        if currentTableView == 2{
            makeDateTime(indexPath: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[currentTableView]
    }
}
//Spinner
extension UIViewController{
    @available(iOS 13.0, *)
    func showSpinner(){
        aView = UIView.init(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        let ai = UIActivityIndicatorView(style: .large)
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
        
    }
    func removeSpinner(){
        aView?.removeFromSuperview()
        aView = nil
    }
}
@available(iOS 13.0, *)
extension MainViewController{
    func makeReports(indexPath:IndexPath){
        switch indexPath.row{
        case 0:
            self.showSpinner()
            DispatchQueue.main.async {[self] in
                if bluePad.portOpened{
                    let res = bluePad.getReceiptTags()
                    if res != nil{
                        showMessage(title: "Response", message: res ?? "")
                    }else{
                        showMessage(title:"GET RECEIPT TAGS FAILED", message: res ?? "")
                    }
                }else{
                    showMessage(title:"GET RECEIPT TAGS FAILED", message: "Device not connected")
                    self.removeSpinner()
                }
                self.removeSpinner()
            }
            break
        case 1:
            var valueStr = "No data"
            self.showSpinner()
            DispatchQueue.main.async {[self] in
            if bluePad.portOpened{
                let tag : UInt16 = 0x9f41
                let res = bluePad.getLastTag(tag: tag, valueStr: &valueStr)
                if res {
                    showMessage(title: "Last tag \(tag)", message: valueStr)
                }else{
                    showMessage(title: "Last tag.Failed", message: valueStr)
                }
            }else{
                showMessage(title: "Last tag .Failed", message: "Device not connected")
                self.removeSpinner()
            }
                self.removeSpinner()
            }
            break
        case 2:
            self.showSpinner()
            var tags: String = ""
            DispatchQueue.main.async {[self] in
            if bluePad.portOpened{
                let res = bluePad.getLastTags(tagCodes: &tags)
                if res{
                    showMessage(title: "Last tags", message: tags)
                }else{
                    showMessage(title: "Last tags failed", message: "")
                }
            }else{
                showMessage(title: "Last tags failed", message: "Device not connected")
                self.removeSpinner()
            }
                self.removeSpinner()
            }
            
            break
        case 3:
            var result : UInt16 = 0
            self.showSpinner()
            DispatchQueue.main.async {[self] in
            if bluePad.portOpened{
                let res =  bluePad.getReportInfo(recordCount: &result)
                if res != nil{
                    showMessage(title: "Report info", message: "\(String(describing: result))")
                }else{
                    showMessage(title: "Repot info failed", message: "")
                }
            }else{
                self.removeSpinner()
                showMessage(title: "Report info failed", message: "Device not connected")
            }
                self.removeSpinner()
            }
            break
        case 4:
            if bluePad.portOpened{
                let allertController = UIAlertController.init(title: "Record type", message: "1 first report\n2 next report\n3 last report\n4 prev report", preferredStyle: .alert)
                allertController.addTextField { (textField) in
                    textField.placeholder = "1,2,3 or 4"
                    textField.keyboardType = .decimalPad
                }
                let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
                }
                let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
                    self.showSpinner()
                    let type = allertController.textFields?[0].text ?? "0"
                    if type == "1" || type == "2" || type == "3" || type == "4"{
                    }else{
                        showMessage(title: "Error type", message: "")
                        self.removeSpinner()
                        return
                    }
                    DispatchQueue.init(label: "GetReportTags").async { [self] in
                        let result = bluePad.getReportTags(recordType: UInt8(type) ?? 0)
                        DispatchQueue.main.sync {
                            self.removeSpinner()
                            if (result != nil){
                                showMessage(title: "Report tags", message: "\(result ?? "")")
                            }else{
                                showMessage(title: "Report tags failed", message: "")
                            }
                        }
                    }
                }
                allertController.addAction(action)
                allertController.addAction(actionCancel)
                self.present(allertController, animated: true, completion:nil)
            }else{
                showMessage(title: "Report tags failed", message: "Device disconnected")
            }
        case 5:
            let allertController = UIAlertController.init(title: "Record by stan", message: "", preferredStyle: .alert)
                allertController.addTextField { (textField) in
                textField.placeholder = "number report"
                textField.keyboardType = .decimalPad
            }
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
            }
            let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
                self.showSpinner()
                let number = allertController.textFields?[0].text ?? "0"
                DispatchQueue.init(label: "GetReportbyStan").async { [self] in
                    let result = bluePad.getReportTagsByStan(TransNumber: Int(number) ?? -1)
                    DispatchQueue.main.sync {
                        self.removeSpinner()
                        if (result != nil){
                            showMessage(title: "Report by stan", message: "\(result ?? "")")
                        }else{
                            showMessage(title: "Report by stan failed", message: "")
                        }
                    }
                }
            }
            allertController.addAction(action)
            allertController.addAction(actionCancel)
            self.present(allertController, animated: true, completion:nil)
            break
        case 6:
            self.showSpinner()
            DispatchQueue.main.async {[self] in
                if bluePad.portOpened{
                    let res = bluePad.lastErrorCode()
                    if res != nil{
                        showMessage(title: "Last error code", message: "\(res ?? 0)")
                    }else{
                        showMessage(title: "Last error code", message: "")
                    }
                }else{
                    showMessage(title: "Last error code failed", message: "Device not connected")
                    self.removeSpinner()
                }
                self.removeSpinner()
            }
            break
        case 7:
            self.showSpinner()
            DispatchQueue.main.async {[self] in
                if bluePad.portOpened{
                    let res = bluePad.lastErrorMsg()
                    if res != nil{
                        showMessage(title: "Last error msg", message: res ?? "")
                    }else{
                        showMessage(title: "Last error msg failed", message: "")
                    }
                }else{
                    showMessage(title: "Last error msg failed", message: "Device not connected")
                    self.removeSpinner()
                }
                self.removeSpinner()
            }
            break
        case 8:
            var molelName = ""
            var serialNumber = ""
            var softVer = ""
            var terminalId = ""
            var menuType : UInt8 = 0
            
            self.showSpinner()
            DispatchQueue.main.async {[self] in
            if bluePad.portOpened{
                bluePad.getPinpadInfo(&molelName,&serialNumber,&softVer, &terminalId,&menuType)
                let info = """
                Model name { \(molelName) }
                Serial number { \(serialNumber) }
                Soft version { \(softVer) }
                Terninal ID { \(terminalId) }
                Menu type { \(menuType) }
                """
                showMessage(title: "Pin pad info", message: info)
            }else{
                showMessage(title: "Pin pad info failed", message: "Device not connected")
                self.removeSpinner()
            }
                self.removeSpinner()
            }
        case 9:
            self.showSpinner()
            DispatchQueue.main.async {[self] in
                let res = bluePad.ping()
                showMessage(title: "Ping \(res) ", message: "")
                self.removeSpinner()
            }
            break
        case 10:
            self.showSpinner()
            DispatchQueue.main.async {[self] in
                let res = bluePad.version
                showMessage(title: "Version < \(res) >", message: "")
                self.removeSpinner()
            }
            break
        default:
            break
        }
    }
    func makeTransaction(indexPath:IndexPath){
        switch indexPath.row {
        case 0:
            if bluePad.portOpened{
                testConnection()
            }else{
                showMessage(title: "Test connection failed", message: "Device not connected")
            }
            break
        case 1:
            if bluePad.portOpened{
                purchase()
            }else{
                showMessage(title: "Purchase failed", message: "Device not connected")
            }
            break
        case 2:
            if bluePad.portOpened{
                purchaseCashBack()
            }else{
                showMessage(title: "Purchase cashback failed", message: "Device not connected")
            }
            break
        case 3:
            if bluePad.portOpened{
                voidPurchase()
            }else{
                showMessage(title: "Void purchase failed", message: "Device not connected")
            }
            break
        case 4:
            if bluePad.portOpened{
                purchaseReturn()
            }else{
                showMessage(title: "Purchase return failed", message: "Device not connected")
            }
            break
        case 5:
            if bluePad.portOpened{
                universalReversal()
            }else{
                showMessage(title: "Universal reversal  failed", message: "Device not connected")
            }
            break
        case 6:
            if bluePad.portOpened{
                universalReversalAdvice()
            }else{
                showMessage(title: "Universal reversal advise  failed", message: "Device not connected")
            }
            break
        case 7:
            if bluePad.portOpened{
                autorization()
            }else{
                showMessage(title: "Autorization  failed", message: "Device not connected")
            }
            break
        case 8:
            if bluePad.portOpened{
                autorizationConfirm()
            }else{
                showMessage(title: "Autorization confirm failed", message: "Device not connected")
            }
            break
        case 9:
            if bluePad.portOpened{
                keyChange()
            }else{
                showMessage(title: "Key change failed", message: "Device not connected")
            }
            break
        case 10:
            if bluePad.portOpened{
                balanceInquiry()
            }else{
                showMessage(title: "Balance inquiry failed", message: "Device not connected")
            }
            break
        case 11:
            if bluePad.portOpened{
                endOfDay()
            }else{
                showMessage(title: "End of day failed", message: "Device not connected")
            }
            break
        default:
            print("unknown transaction")
        }
    }
}
@available(iOS 13.0, *)
extension MainViewController{
    func testConnection(){
        let res = bluePad.testConnection()
        if res{
            showMessage(title: "Test connection started", message: "Look on display BluePad-50")
        }else{
            showMessage(title: "Test connection failed", message: "")
        }
    }
    func purchase(){
        var outStr = ""
        let allertController = UIAlertController.init(title: "PURCHASE", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            textField.keyboardType = .decimalPad
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            let amount = allertController.textFields?[0].text ?? "0"
            DispatchQueue.init(label: "Purchase").async { [self] in
                let result = bluePad.purchase(amount: Int(amount) ?? 0,outValues: &outStr)
                DispatchQueue.main.sync {
                    self.removeSpinner()
                    if result{
                        showMessage(title: "Aproved", message: "\(outStr)")
                    }else{
                        showMessage(title: "Purchase Failed", message: "\(outStr)")
                    }
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    func purchaseCashBack(){
        var outVal = ""
        let allertController = UIAlertController.init(title: "PURCHASE+CASHBACK", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            textField.keyboardType = .numberPad
        }
        allertController.addTextField { (textField) in
            textField.placeholder = "Cashback "
            textField.keyboardType = .numberPad
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            let amount = allertController.textFields?[0].text ?? "1"
            let cashback = allertController.textFields?[1].text ?? "1"
            if ((allertController.textFields?.isEmpty) != nil) {
            }else{
                return
            }
            DispatchQueue.init(label: "PurchaseCashback").async { [self] in
                let result = bluePad.purchaseCashback(amount: Int(amount) ?? 0, cashback: Int(cashback) ?? 0, outValues: &outVal)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "PurchaseCashback Aproved", message: "\(outVal)")
                    }else{
                        showMessage(title: " PurchaseCashback Failed", message: "\(outVal)")
                    }
                    
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    func voidPurchase(){
        let allertController = UIAlertController.init(title: "VOID_PURCHASE", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            textField.keyboardType = .numberPad
        }
        allertController.addTextField { (textField) in
            textField.placeholder = "RRN"
            textField.keyboardType = .numberPad
        }
        allertController.addTextField { (textField) in
            textField.placeholder = "AutorizationID"
            textField.keyboardType = .numberPad
            
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            let amount = allertController.textFields?[0].text ?? "0"
            let rrn = allertController.textFields?[1].text ?? "0"
            let autId = allertController.textFields?[2].text ?? "0"
            var outValues = ""
            DispatchQueue.init(label: "VoidPurchase").async { [self] in
                let result = bluePad.voidOfPurchase(amount: Int(amount) ?? 0, constRRN: rrn, constAuthID: autId, outValues: &outValues)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "VOID_PURCHASE Aproved", message: "\(outValues)")
                    }else{
                        showMessage(title: "VOID_PURCHASE Failed", message: "\(outValues)")
                    }
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    func autorization(){
        var outValues = ""
        let allertController = UIAlertController.init(title: "AUTHORIZATION", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            
            textField.keyboardType = .numberPad
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            let amount = allertController.textFields?[0].text ?? "0"
            DispatchQueue.init(label: "Authorization").async { [self] in
                let result = bluePad.authorization(amount: Int(amount) ?? 0, outValues: &outValues)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "Aproved", message: "\(outValues)")
                    }else{
                        showMessage(title: "Failed", message: "\(outValues)")
                    }
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    func purchaseReturn(){
        var outValues : String = ""
        let allertController = UIAlertController.init(title: "PURCHASE_RETURN", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            
            textField.keyboardType = .numberPad
        }
        allertController.addTextField { (textField) in
            textField.placeholder = "RN"
            
            textField.keyboardType = .numberPad
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            let amount = allertController.textFields?[0].text ?? "0"
            let rn = allertController.textFields?[1].text ?? ""
            DispatchQueue.init(label: "PURCHASE_RETURN").async { [self] in
                let result = bluePad.purchaseReturn(amount: Int(amount) ?? 0, rn: rn, outValues: &outValues)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "Aproved", message: "\(outValues)")
                    }else{
                        showMessage(title: "Failed", message: "\(outValues)")
                    }
                    
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    
    func universalReversal(){
        var outValues : String = ""
        let allertController = UIAlertController.init(title: "UNIVERSAL_REVERSAL", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "amount"
            
            textField.keyboardType = .numberPad
        }
        allertController.addTextField { (textField) in
            textField.placeholder = "numberCheck"
            
            textField.keyboardType = .numberPad
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            
            let amount = allertController.textFields?[0].text ?? "0"
            let nCheck = allertController.textFields?[1].text ?? ""
            DispatchQueue.init(label: "UniversalReversal").async { [self] in
                let result = bluePad.universalReversal(amount: Int(amount) ?? 0, numCheck: Int(nCheck) ?? 0, outValues: &outValues)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "Aproved", message: "\(outValues)")
                    }else{
                        showMessage(title: "Failed", message: "\(outValues)")
                    }
                    
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    
    func universalReversalAdvice(){
        var outValues : String = ""
        let allertController = UIAlertController.init(title: "UNIVERSAL_REVERSAL_ADVICE", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            
            textField.keyboardType = .numberPad
        }
        allertController.addTextField { (textField) in
            textField.placeholder = "NumberCheck"
            
            textField.keyboardType = .numberPad
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            let amount = allertController.textFields?[0].text ?? "0"
            let nCheck = allertController.textFields?[1].text ?? ""
            
            DispatchQueue.init(label: "UniversalReversalAdvice").async { [self] in
                let result = bluePad.universalReversalAdvice(amount: Int(amount) ?? 0, numCheck: Int(nCheck) ?? 0, outValues: &outValues)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "Aproved", message: "\(outValues)")
                    }else{
                        showMessage(title: "Failed", message: "\(outValues)")
                    }
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
        
    }
    func autorizationConfirm(){
        var outValues : String = ""
        let allertController = UIAlertController.init(title: "AUTORIZATION_CONFIRM", message: "", preferredStyle: .alert)
        allertController.addTextField { (textField) in
            textField.placeholder = "Amount"
            textField.keyboardType = .numberPad
        }
        allertController.addTextField { (textField) in
            textField.placeholder = "RRN"
            
            textField.keyboardType = .numberPad
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            let amount = allertController.textFields?[0].text ?? "0"
            let rrn = allertController.textFields?[1].text ?? ""
            
            DispatchQueue.init(label: "AUTORIZATION_CONFIRM").async { [self] in
                let result = bluePad.authorizationConfirm(amount: Int(amount) ?? 0, constRRN: rrn, outValues: &outValues)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "Aproverd", message: "\(outValues)")
                    }else{
                        showMessage(title: "Failed", message: "\(outValues)")
                    }
                    
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    func keyChange(){
        var outValues = ""
        self.showSpinner()
        DispatchQueue.init(label: "KEY_CHANGE").async { [self] in
            let result = bluePad.keyChange(outValues: &outValues)
            DispatchQueue.main.sync{ [self] in
                if result{
                    self.removeSpinner()
                    showMessage(title: "Aproved", message: "\(outValues)")
                }else{
                    showMessage(title: "Failed", message: "\(outValues)")
                }
                
            }
        }
    }
    func balanceInquiry(){
        self.showSpinner()
        var outValues = ""
        DispatchQueue.init(label: "BALANCE_INQUIRY").async { [self] in
            let result = bluePad.balanceInquiry(outValues: &outValues)
            DispatchQueue.main.sync{ [self] in
                if result{
                    self.removeSpinner()
                    showMessage(title: "Sucsses", message: "")
                }else{
                    showMessage(title: "Failed", message: "")
                }
                
            }
        }
    }
    func endOfDay(){
        let allertController = UIAlertController.init(title: "Confirm End_Of_Day?", message: "", preferredStyle: .alert);
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
        }
        let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
            self.showSpinner()
            var outValues = ""
            DispatchQueue.init(label: "EndOfDay").async { [self] in
                let result = bluePad.endOfDay(outValues: &outValues)
                DispatchQueue.main.sync{ [self] in
                    self.removeSpinner()
                    if result{
                        showMessage(title: "Sucsses", message: "\(outValues)")
                    }else{
                        showMessage(title: "Failed", message: "\(outValues)")
                    }
                    
                }
            }
        }
        allertController.addAction(action)
        allertController.addAction(actionCancel)
        self.present(allertController, animated: true, completion:nil)
    }
    func showMessage(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
@IBDesignable extension UITableView {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
@available(iOS 13.0, *)
extension MainViewController{
    func makeDateTime(indexPath:IndexPath){
        switch indexPath.row {
        case 0:
            if bluePad.portOpened{
                DispatchQueue.init(label: "getDate").async { [self] in
                    var date:String? = ""
                    let res = bluePad.getDateTime(DT: &date)
                    if res{
                        DispatchQueue.main.sync {
                            showMessage(title: "Date&time", message: date ?? "no date")
                        }
                    }else{
                        DispatchQueue.main.sync {
                            showMessage(title: " Get Date&Time", message: "failed")
                        }
                    }
                }
            }else{
                    showMessage(title: "Device not connected", message: "")
            }
            
        case 1:
            if bluePad.portOpened{
                DispatchQueue.init(label: "setDate").async { [self] in
                    let res = bluePad.setDateTime(Year: 2021, Month: 5, Day: 17, Hour: 12, Minute: 0, Sec: 0)
                    if res{
                        DispatchQueue.main.async {
                            showMessage(title: "Set Date&Time ", message: "successfully")
                        }
                    }else{
                    showMessage(title: " Set Date&Time", message: "failed")
                    }
                }
            }else{
            showMessage(title: "Device not connected", message: "")
            }
        case 2:
            let allertController = UIAlertController.init(title: "SetTimeOut", message: "", preferredStyle: .alert)
            allertController.addTextField { (textField) in
                textField.placeholder = "ms"
                textField.keyboardType = .numberPad
            }
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) {  (UIAlertAction) in
            }
            let action = UIAlertAction.init(title: "Confirm", style: .default) { [self] (UIAlertAction) in
                self.showSpinner()
                let seconds = allertController.textFields?[0].text ?? "0"
                
                DispatchQueue.init(label: "setTimeOuts").async { [self] in
                    let result = bluePad.setTimeOut(timeoutTransaction: Int(seconds) ?? 40)
                    DispatchQueue.main.sync{ [self] in
                        self.removeSpinner()
                        if result{
                            showMessage(title: "Set timeouts", message: "successfully")
                        }else{
                            showMessage(title: "Set timeouts ", message: "failed")
                        }
                    }
                }
            }
            allertController.addAction(action)
            allertController.addAction(actionCancel)
            self.present(allertController, animated: true, completion:nil)
        default:
            return
        }
    }
}
