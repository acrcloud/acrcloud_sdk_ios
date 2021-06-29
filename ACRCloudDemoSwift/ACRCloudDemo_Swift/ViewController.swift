//
//  ViewController.swift
//  ACRCloudDemo_Swift
//
//  Created by olym.yin on 3/25/16.
//  Copyright © 2016 olym.yin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var _start = false
    var _client: ACRCloudRecognition?
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var resultView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _start = false;
        
        let config = ACRCloudConfig();
        
        config.accessKey = "<your_project_access_key>";
        config.accessSecret = "<your_project_secret_key>";
        config.host = "<your project host>";
        
        //if you want to identify your offline db, set the recMode to "rec_mode_local"
        config.recMode = rec_mode_remote;
        config.requestTimeout = 10;
        config.protocol = "https";

        /* used for local model */
        if (config.recMode == rec_mode_local || config.recMode == rec_mode_both) {
            config.homedir = Bundle.main.resourcePath!.appending("/acrcloud_local_db");
        }
        
        config.stateBlock = {[weak self] state in
            self?.handleState(state!);
        }
        config.volumeBlock = {[weak self] volume in
            //do some animations with volume
            self?.handleVolume(volume);
        };
        config.resultBlock = {[weak self] result, resType in
            self?.handleResult(result!, resType:resType);
        }
        self._client = ACRCloudRecognition(config: config);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startRecognition(_ sender:AnyObject) {
        if (_start) {
            return;
        }
        self.resultView.text = "";
    
        self._client?.startRecordRec();
        self._start = true;
    }
    
    @IBAction func stopRecognition(_ sender:AnyObject) {
        self._client?.stopRecordRec()
        self._start = false;
    }

    func handleResult(_ result: String, resType: ACRCloudResultType) -> Void
    {

        DispatchQueue.main.async {
            self.resultView.text = result;
            print(result);
            self._client?.stopRecordRec();
            self._start = false;
        }
    }
    
    func handleVolume(_ volume: Float) -> Void {
        DispatchQueue.main.async {
            self.volumeLabel.text = String(format: "Volume: %f", volume)
        }
    }
    
    func handleState(_ state: String) -> Void
    {
        DispatchQueue.main.async {
            self.stateLabel.text = String(format:"State : %@",state)
        }
    }

}

