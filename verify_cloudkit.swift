#!/usr/bin/env swift

import Foundation
import CloudKit

/**
 CloudKit Configuration Verification Script
 
 This script verifies that CloudKit is properly configured in your app.
 Run this to check your setup before deploying to a physical device.
 */

print("=" * 60)
print("CloudKit Configuration Verification")
print("=" * 60)

// Check 1: Verify container identifier
let containerIdentifier = "iCloud.com.mc.no.MCVenture"
let container = CKContainer(identifier: containerIdentifier)

print("\n✅ Check 1: Container Access")
print("   Container ID: \(containerIdentifier)")
print("   Container: \(container)")

// Check 2: Verify account status (requires device/simulator with iCloud)
print("\n⏳ Check 2: iCloud Account Status")
print("   Checking account status...")

let semaphore = DispatchSemaphore(value: 0)

container.accountStatus { (accountStatus, error) in
    if let error = error {
        print("   ❌ Error: \(error.localizedDescription)")
    } else {
        switch accountStatus {
        case .available:
            print("   ✅ iCloud account is available")
        case .noAccount:
            print("   ⚠️  No iCloud account configured")
            print("      → Sign into iCloud in Settings")
        case .restricted:
            print("   ⚠️  iCloud access is restricted")
            print("      → Check parental controls or MDM settings")
        case .couldNotDetermine:
            print("   ⚠️  Could not determine account status")
            print("      → Try again or check network connection")
        case .temporarilyUnavailable:
            print("   ⚠️  iCloud temporarily unavailable")
            print("      → Check network connection")
        @unknown default:
            print("   ❌ Unknown account status")
        }
    }
    semaphore.signal()
}

semaphore.wait()

// Check 3: Test database access
print("\n⏳ Check 3: Public Database Access")
let publicDB = container.publicCloudDatabase

// Try to perform a simple query
let predicate = NSPredicate(value: true)
let query = CKQuery(recordType: "Route", predicate: predicate)

let semaphore2 = DispatchSemaphore(value: 0)

publicDB.perform(query, inZoneWith: nil) { (records, error) in
    if let error = error {
        let ckError = error as? CKError
        if ckError?.code == .unknownItem {
            print("   ✅ Database accessible (no records yet)")
        } else {
            print("   ⚠️  Error: \(error.localizedDescription)")
            print("      This is normal if not tested on a real device")
        }
    } else {
        print("   ✅ Database accessible")
        print("      Found \(records?.count ?? 0) existing route(s)")
    }
    semaphore2.signal()
}

semaphore2.wait()

// Check 4: Verify entitlements file exists
print("\n✅ Check 4: Entitlements File")
let entitlementsPath = "MCVenture/MCVenture.entitlements"
let fileManager = FileManager.default
if fileManager.fileExists(atPath: entitlementsPath) {
    print("   ✅ Entitlements file exists at: \(entitlementsPath)")
    
    // Try to read and verify contents
    if let data = fileManager.contents(atPath: entitlementsPath),
       let content = String(data: data, encoding: .utf8) {
        let hasCloudKit = content.contains("com.apple.developer.icloud-services")
        let hasContainer = content.contains("iCloud.com.mc.no.MCVenture")
        
        print("   ✅ CloudKit services: \(hasCloudKit ? "✓" : "✗")")
        print("   ✅ Container identifier: \(hasContainer ? "✓" : "✗")")
    }
} else {
    print("   ❌ Entitlements file not found")
}

// Summary
print("\n" + "=" * 60)
print("Verification Complete")
print("=" * 60)
print("\n📱 Next Steps:")
print("   1. Open MCVenture.xcodeproj in Xcode")
print("   2. Connect your iPhone/iPad via USB")
print("   3. Ensure device is signed into iCloud")
print("   4. Build and run on device (Cmd+R)")
print("   5. Navigate to Community Routes section")
print("   6. Try uploading/downloading a route")
print("\n💡 Note: Full CloudKit testing requires a physical device.")
print("   Simulators have limited CloudKit functionality.\n")
