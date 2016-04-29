//
//  MainTableViewController.swift
//  HealthKitRND
//
//  Created by Luiz Bildzinkas on 4/12/16.
//  Copyright © 2016 Luiz Bildzinkas. All rights reserved.
//

import UIKit
import HealthKit
class MainTableViewController: UITableViewController {
    
    var healthKitManager: HealthKitManager!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var imc: UITextField!
    @IBOutlet weak var biologicalSex: UILabel!
    @IBOutlet weak var bloodType: UILabel!
    @IBOutlet weak var heightLabel: UITextField!
    @IBOutlet weak var weightLabel: UITextField!
    @IBOutlet weak var heightUnit: UILabel!
    @IBOutlet weak var weightUnit: UILabel!
    
    var heightSample, weightSample: HKQuantitySample?
    
    var height: Double = 0{
        didSet{
            heightLabel.text = String(height)
            self.updateBMI()
        }
    }
    
    var weight: Double = 0{
        didSet{
            weightLabel.text = String(weight)
            self.updateBMI()
        }
    }
    
    var bmi: Double = 0
    
    
    override func viewDidAppear(animated: Bool) {
        loadData()
    }
    
    func loadData(){
        let profileData = healthKitManager.GetProfileData()
        age.text = String(profileData.age!) ?? ""
        bloodType.text = profileData.bloodType?.bloodType.description
        biologicalSex.text = profileData.biologicalSex?.biologicalSex.description
        updateHeight()
        updateWeight()
    }
    
    @IBAction func weightEditingBegin(sender: UITextField) {
        
    }
        
    func updateHeight()
    {
        healthKitManager?.readMostRecentSample(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!){ (sample, error) -> Void in
            if(error != nil){
                print("\(error)")
                return;
            }
            
            var heightLocalizedString: Double = 0
            var stringUnit = ""
            self.heightSample = (sample as? HKQuantitySample)!
            if let meters = self.heightSample?.quantity.doubleValueForUnit(HKUnit.meterUnit()){
                let heightFormater = NSLengthFormatter()
                heightFormater.forPersonHeightUse = true
                heightLocalizedString = meters
                
                let metricSystem = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue == true ? 1 : 0
                stringUnit = heightFormater.unitStringFromValue(meters, unit: (metricSystem == 1) ? .Centimeter : .Inch)
            }
            
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                self.height = heightLocalizedString
                self.heightUnit.text = stringUnit
            })
            
        }
        
    }
    
    func updateWeight()
    {
        healthKitManager?.readMostRecentSample(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!){(sample, error) -> Void in
            
            if(error != nil){
                print("\(error)")
                return;
            }
            var weightLocalizedString: Double = 0
            var kiloSystem = ""
            self.weightSample = (sample as? HKQuantitySample)!
            if let kilos = self.weightSample?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)){
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true
                weightLocalizedString = kilos
                var massFormatterUnit = NSMassFormatterUnit.Kilogram
                kiloSystem = weightFormatter.unitStringFromKilograms(kilos, usedUnit: &massFormatterUnit)
            }
            
            dispatch_async(dispatch_get_main_queue()){() -> Void in
                self.weight = weightLocalizedString
                self.weightUnit.text = kiloSystem
            }
        }
    }
    
    func updateBMI()
    {
        var bmi: Double? = 0
        if weightSample != nil && heightSample != nil{
            let weightInKilograms = weightSample?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
            let heightInMeters = heightSample?.quantity.doubleValueForUnit(HKUnit.meterUnit())
            
            bmi = calculateBMIWithWeightInKilograms(weightInKilograms!, heightInMeters: heightInMeters!)
        }
        
        if let bmiValue  = bmi{
            imc.text = String(format: "%.02f", bmiValue)
        }
    }
    
    func calculateBMIWithWeightInKilograms(weightInKilograms:Double, heightInMeters:Double) -> Double?
    {
        if heightInMeters == 0 {
            return nil;
        }
        return (weightInKilograms/(heightInMeters*heightInMeters));
    }
    
    
    @IBAction func savingData(sender: AnyObject) {
        healthKitManager.saveHeight(height){(success, error) -> Void in
            if error != nil{
                print(error)
            }
        }
        
        healthKitManager.saveWeight(weight){(success, error) -> Void in
            if error != nil{
                print(error)
            }
        }
    }
}


