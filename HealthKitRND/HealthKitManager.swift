//
//  HealthKitManager.swift
//  HealthKitRND
//
//  Created by Luiz Bildzinkas on 4/7/16.
//  Copyright © 2016 Luiz Bildzinkas. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager{
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func AutorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!){
        let healthKitTypesToRead : Set<HKObjectType> = [
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.workoutType()
            ]
        
        let healthKitTypesToWrite : Set<HKSampleType> = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKQuantityType.workoutType()]
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.bildzinkas.HealthKitRND", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    func GetProfileData() -> (age:Int?, biologicalSex: HKBiologicalSexObject?, bloodType: HKBloodTypeObject?){
        var age: Int?
        var biologicalSex: HKBiologicalSexObject?
        var bloodType: HKBloodTypeObject?
        
        do
        {
            
            let birthDay = try healthKitStore.dateOfBirth()
            let today = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let differenceComponents = calendar.components(.NSYearCalendarUnit, fromDate: birthDay, toDate: today, options:NSCalendarOptions(rawValue: 0))
            age = differenceComponents.year
        }
        catch
        {
            print("Error obtaining birthday")
        }
        
        do{
            biologicalSex = try healthKitStore.biologicalSex()
        }
        catch
        {
            print("Error obtaining biological sex")
        }
        
        do{
            bloodType = try healthKitStore.bloodType()
        }
        catch
        {
            print("Error obtaining blood type")
        }
        
        return (age, biologicalSex, bloodType)
    }
    
    func readMostRecentSample(sampleType: HKSampleType, completion: ((HKSample!, NSError!) -> Void)!)
    {
        let past = NSDate.distantPast()
        let now = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate: now, options: .None)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) {(sampleQuery, results, error)-> Void in
            
            if let queryError = error{
                completion(nil, queryError)
                return;
            }
            
            let mostRecentSample = results?.first as? HKQuantitySample
            
            if completion != nil
            {
                completion(mostRecentSample, nil)
            }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func saveWeight(weight: Double, completion: ((Bool, NSError!) -> Void)!)
    {
        let now = NSDate()
        let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        let quantity = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: weight)
        
        let sample = HKQuantitySample.init(type: quantityType!, quantity: quantity, startDate: now, endDate: now)
        
        healthKitStore.saveObject(sample){ (success, error) -> Void in
            completion(success, error)
        }
    }
    
    func saveHeight(height: Double, completion: ((Bool, NSError!) -> Void)!)
    {
        let now = NSDate()
        let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        let quantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: height)
        
        let sample = HKQuantitySample(type: quantityType!, quantity: quantity, startDate: now, endDate: now)
        
        healthKitStore.saveObject(sample){(success, error) -> Void in
            completion(success, error)
        }
    }
}

extension HKBloodType: CustomStringConvertible{
    public var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case NotSet: return "Não definido"
        case APositive: return "A+"
        case ANegative: return "A-"
        case BPositive: return "B+"
        case BNegative: return "B-"
        case ABPositive: return "AB+"
        case ABNegative: return "AB-"
        case OPositive: return "O+"
        case ONegative: return "O-"
        }
    }
}

extension HKBiologicalSex: CustomStringConvertible{
    public var description: String{
        switch self{
        case .Female: return "Feminino"
        case .Male: return "Masculino"
        case .NotSet: return "Não definido"
        case .Other: return "Outro"
        }
    }
}
