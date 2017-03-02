//
//  ViewController.swift
//  IBMQRScanner
//
//  Created by David Okun IBM on 3/1/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit
import IDSCameraController
import RealmSwift
import MessageUI

private extension IDSCameraController {
    func postMessage(_ title: String, _ message: String, _ dismissTime: Float) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IDSAlertViewShowNotification"), object: nil, userInfo: ["title":title, "message":message,"dismissTime":dismissTime,"useVoice":false])
    }
}

public enum DataExporterError : Error {
    case EmailNotAvailable
    case NoRecords
}

class ViewController: UITableViewController {
    var records: Results<Record> {
        let realm = try! Realm()
        let records = realm.objects(Record.self)
        return records
    }
    
    fileprivate var isScanning = false // avoids race conditions if we got a record
    
    // MARK: IBActions
    
    @IBAction func addRecordTapped() {
        let camera = IDSCameraController.init()
        camera.delegate = self
        camera.triggerAppearDelay = -1
        present(camera, animated: true) { 
            camera.postMessage("Scan QR Codes", "Hold the phone up to a QR code, and it should scan automatically.", 5)
        }
    }
    
    @IBAction func exportListButtonTapped() {
        do {
            try export()
        } catch DataExporterError.EmailNotAvailable {
            let alert = UIAlertController(title: "Email not configured", message: "In order to export this data, you need to configure the default email client on your phone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        } catch DataExporterError.NoRecords {
            let alert = UIAlertController(title: "No records saved", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        } catch {
            let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    // MARK: UITableViewDataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    // MARK: UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell") as UITableViewCell! else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "subtitleCell")
        }
        let record = records[indexPath.row]
        if let textLabel = cell.textLabel, let detailTextLabel = cell.detailTextLabel {
            textLabel.text = record.name
            detailTextLabel.text = record.email
            return cell
        } else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "subtitleCell")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let record = records[indexPath.row]
        let alert = UIAlertController(title: "Notes", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Notes"
            textField.text = record.notes
        }
        let saveAction = UIAlertAction(title: "Save", style: .destructive) { action in
            guard let field = alert.textFields?.first else {
                return
            }
            let realm = try! Realm()
            try! realm.write {
                record.notes = field.text!
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // DataExporter
    
    func export() throws {
        var emailString = String()
        if records.count == 0 {
            throw DataExporterError.NoRecords
        }
        var counter = 0
        for record in records {
            counter += 1
            emailString.append("(\(counter)) Name: \(record.name)\nEmail: \(record.email)\nNotes: \(record.notes)\n\n")
        }
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setSubject("Event Leads")
            composeVC.setMessageBody(emailString, isHTML: false)
            present(composeVC, animated: true, completion: nil)
        } else {
            throw DataExporterError.EmailNotAvailable
        }
    }
}

extension ViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: IDSCameraCaptureControllerDelegate {
    func captureControllerDidCancel(_ controller: IDSCameraController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func captureControllerShouldOpenHelp(_ controller: IDSCameraController) {
        controller.postMessage("Scan QR Codes", "Hold the phone up to a QR code, and it should scan automatically.", 5)
    }
    
    func capture(_ controller: IDSCameraController, didFailWithError error: Error) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func capture(_ controller: IDSCameraController, didReceiveFrame frame: UIImage) {
        if isScanning == true {
            return
        } else {
            defer {
                isScanning = false
            }
            isScanning = true
            do {
                let record = try Scanner.scan(frame)
                DispatchQueue.main.async {
                    controller.dismiss(animated: true, completion: { 
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(record)
                        }
                        self.tableView.reloadData()
                        self.isScanning = false
                    })
                }
            } catch ScannerError.DuplicateBadge {
                DispatchQueue.main.async {
                    controller.postMessage("Duplicate Badge", "You've already scanned this person.", 5)
                }
            } catch ScannerError.MoreThanOneFeature {
                DispatchQueue.main.async {
                    controller.postMessage("Too Many Badges", "Please only scan one badge at a time.", 5)
                }
            } catch ScannerError.ParsingIssue {
                DispatchQueue.main.async {
                    controller.postMessage("Unrecognizable Format", "Please contact your administrator to update badge parsing logic.", 5)
                }
            } catch {
                print("unsuccessful scan")
            }
        }
    }
}

