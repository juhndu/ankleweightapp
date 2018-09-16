//
//  SessionViewController.swift
//  AnkleApp
//
//  Created by John Du on 31/10/17.
//  Copyright © 2017 John Du. All rights reserved.
//

import Cocoa

class SessionViewController: NSViewController {

    let aggRatio = 10
    var cushState = 0; var accState = 0;
    var userState = 0 //0 relax. 1 sit. 2 exer
    let maxSeconds = 600
    var aggregateSeconds: Int = 0 {
        didSet {
            let d = (aggregateSeconds > maxSeconds ? Double(maxSeconds) : Double(aggregateSeconds))
            progBar.doubleValue = d * 100 / 600
            updateStatusIcon()
        }
    }
    var statusItem : NSStatusItem?
    @IBOutlet var progBar: NSProgressIndicator!
    @IBOutlet var sitLabel: NSTextField!
    @IBOutlet var exerLabel: NSTextField!
    var currentSitSeconds: Int = 0 {
        didSet {
            sitLabel.stringValue = String(describing: formatTime(time: TimeInterval(currentSitSeconds)))
        }
    }
    var currentExerSeconds: Int = 0 {
        didSet {
            exerLabel.stringValue = String(describing: formatTime(time: TimeInterval(currentExerSeconds)))
        }
    }
    var timer = Timer()
    var alreadyTimer = false
    let cushionUrl = NSURL(string: "http://spark-au.australiasoutheast.cloudapp.azure.com:8080/spark/lastCushionState/");
    let accelUrlR = NSURL(string: "http://spark-au.australiasoutheast.cloudapp.azure.com:8080/spark/lastAccelerometerState/57bdb0358f77c7427e1a50a7b5af2d1c")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        runTimer()
    }
    
    func runTimer() {
        if (!alreadyTimer) {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SessionViewController.updateTimer)), userInfo: nil, repeats: true)
            alreadyTimer = true
        }
    }
    
    @objc
    func updateTimer() {
        let cushRequest = NSMutableURLRequest(url:cushionUrl! as URL);
        let accRequestR = NSMutableURLRequest(url:accelUrlR! as URL);
        cushRequest.httpMethod = "GET"
        accRequestR.httpMethod = "GET"
        
        let accRequestTaskR = URLSession.shared.dataTask(with: accRequestR as URLRequest) {
            data, response, error in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let accelR = convertedJsonIntoDict["value"] as? Int {
                        print(String(Date().timeIntervalSinceReferenceDate)+" accR: \(accelR)")
                        DispatchQueue.main.async() {
                            if (accelR == 1) { self.accState = 1} else {self.accState = 0}
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        accRequestTaskR.resume()
        let cushRequestTask = URLSession.shared.dataTask(with: cushRequest as URLRequest) {
            data, response, error in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("responseString = \(String(describing: responseString))")
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    //print(convertedJsonIntoDict)
                    if let cushion = convertedJsonIntoDict["value"] as? Int {
                        print(String(Date().timeIntervalSinceReferenceDate)+" cushion: \(cushion)")
                        DispatchQueue.main.async() {
                            self.cushState = cushion
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        cushRequestTask.resume()
        
        
        print(String(Date().timeIntervalSinceReferenceDate)+" accState: \(accState)"+" cushState: \(cushState)")
        
        if(accState==1) { userState = 2 } else if (cushState == 1) { userState = 1 } else { userState = 0 }
        userState = 1
        if (self.userState == 1) {
            currentSitSeconds += 1
            aggregateSeconds += (1*aggRatio)
        } else if (self.userState == 2) {
            currentExerSeconds += 1
            if(aggregateSeconds < (2*aggRatio)) { aggregateSeconds = 0} else { aggregateSeconds -= (2*aggRatio) }
        } else {
            if(aggregateSeconds~=0) { aggregateSeconds -= 1 }
        }
    }

    
    func updateStatusIcon() {
        if(aggregateSeconds>50*aggRatio){
            statusItem?.button?.image = NSImage(named:NSImage.Name("StatusBarImage4"))
        } else if(aggregateSeconds>(40*aggRatio)){
            if(aggregateSeconds==45*aggRatio) { showNotification(body: "Your idle bar is over 75% full. You should do some exercise!") }
            statusItem?.button?.image = NSImage(named:NSImage.Name("StatusBarImage3"))
        } else if(aggregateSeconds>(30*aggRatio)){
            statusItem?.button?.image = NSImage(named:NSImage.Name("StatusBarImage2"))
        } else if(aggregateSeconds>(15*aggRatio)) {
            statusItem?.button?.image = NSImage(named:NSImage.Name("StatusBarImage1"))
        } else {
            statusItem?.button?.image = NSImage(named:NSImage.Name("StatusBarImage0"))
        }
    }
    
    func formatTime(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func showNotification(body : String) -> Void {
        sendIFTTT()
        let notification = NSUserNotification()
        notification.title = "SmartAnkle"
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if segue.identifier!.rawValue == "pastSegue" {
            if let toViewController = segue.destinationController as? HistoricViewController {
                toViewController.todaySitTime = currentSitSeconds
                toViewController.todayExerTime = currentExerSeconds
            }
        }
    }
    
    func sendIFTTT(){
        let iftUrl = NSURL(string:"https://maker.ifttt.com/trigger/exercise/with/key/cKPkmrNsQNVqdwWom1Fp33")
        let iftRequest = NSMutableURLRequest(url:iftUrl! as URL);
        iftRequest.httpMethod = "GET"
        let iftTask = URLSession.shared.dataTask(with: iftRequest as URLRequest) {
            data, response, error in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("responseString = \(String(describing: responseString))")
            do {
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        iftTask.resume()
    }
    
}

extension SessionViewController {
    // MARK: Storyboard instantiation
    static func freshController(statIt : NSStatusItem) -> SessionViewController {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "SessionViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? SessionViewController else {
            fatalError("Why cant I find SessionViewController? - Check Main.storyboard")
        }
        viewcontroller.statusItem = statIt
        return viewcontroller
    }
}

extension SessionViewController {
    //MARK: Actions
    @IBAction func viewPast(_ sender: NSButton) {
    }
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared.terminate(sender)
    }
    @IBAction func toggleSituation(_ sender:NSButton) {
        if (sender.title == "Sit") {
            userState = 1
        } else if (sender.title == "Exer") {
            userState = 2
        } else {
            userState = 0
        }
    }
}

