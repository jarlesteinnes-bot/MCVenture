# CloudKit Setup for MCVenture

To make CloudKit work in production and TestFlight, complete these steps.

## 1) Enable iCloud & CloudKit in Xcode

1. Open `MCVenture.xcodeproj` in Xcode
2. Select the `MCVenture` target → Signing & Capabilities
3. Click `+ Capability`
4. Add `iCloud`
5. In iCloud options, check `CloudKit`
6. Under Containers, select `Use default container` or add a custom one:
   - Default: `iCloud.$(CFBundleIdentifier)` (recommended)
7. Ensure the `MCVenture.entitlements` file is attached to the target

## 2) App ID and Provisioning Profiles

- Ensure your App ID in Apple Developer has `iCloud` capability
- Regenerate and download provisioning profiles if needed
- Xcode usually handles this automatically with Automatic Signing

## 3) CloudKit Dashboard Setup

1. Go to https://icloud.developer.apple.com/dashboard/
2. Select your app’s container (e.g., `iCloud.com.mc.no.MCVenture`)
3. Click `Schema` → ensure the following (can be auto-created at runtime during development):
   - Record Types: `Route`
   - Fields: `name (String)`, `coordinates (String)`, `distance (Double)`, `createdBy (String)`, `createdAt (Date)`
4. In `Security Roles` → set Development environment to allow Reads for World, Writes for Authenticated users (typical dev settings)
5. For Production, configure appropriate security and deploy schema

## 4) Info.plist Privacy Strings (already handled)

- `NSUbiquityContainerIdentifier` is not required for CloudKit
- Ensure privacy strings for Location/Camera/Motion are present (they are already integrated)

## 5) Testing

- Test on a physical device signed into iCloud
- Use a real Apple ID (not child/managed account)
- In Xcode, select `Edit Scheme…` → set `Container` to your iCloud account
- In Development environment, records show up immediately in Dashboard

## 6) Common Issues

- If you see `CKError.notAuthenticated`, ensure device iCloud login is present
- If you see `PermissionFailure`, adjust Dashboard security for Development
- If you see `NetworkUnavailable`, verify connectivity and try again (retry logic included)
- If `Container not found`, ensure entitlements and bundle ID match the container name

## 7) Shipping to Production

1. In CloudKit Dashboard, click `Deploy` to Production after testing
2. Update Production security roles as needed (usually Public Read, Authenticated Write)
3. Submit your app build to App Store Connect

## 8) Code Integration Points

- `CloudKitSyncManager` handles: upload, fetch, delete, offline queue, retry
- `CommunityRoutesView` provides a UI for discover/share
- `RouteData` maps CloudKit records to app models

No code changes are needed after enabling iCloud/CloudKit in Xcode and setting up the container.