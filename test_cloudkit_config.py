#!/usr/bin/env python3
"""
CloudKit Configuration Test Suite

Verifies that CloudKit has been properly configured in the MCVenture Xcode project.
This tests the configuration files, not the runtime CloudKit functionality.
"""

import os
import sys
import re
import plistlib
from pathlib import Path

# Colors for terminal output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_header(text):
    print(f"\n{BLUE}{'=' * 60}{RESET}")
    print(f"{BLUE}{text}{RESET}")
    print(f"{BLUE}{'=' * 60}{RESET}\n")

def print_test(name, passed, message=""):
    status = f"{GREEN}✅ PASS{RESET}" if passed else f"{RED}❌ FAIL{RESET}"
    print(f"{status} - {name}")
    if message:
        print(f"        {message}")

def test_project_structure():
    """Test 1: Verify project file structure exists"""
    print_header("Test 1: Project File Structure")
    
    tests = [
        ("project.pbxproj", "MCVenture.xcodeproj/project.pbxproj"),
        ("Entitlements", "MCVenture/MCVenture.entitlements"),
        ("CloudKit Manager", "MCVenture/Managers/CloudKitSyncManager.swift"),
        ("Community View", "MCVenture/Views/CommunityRoutesView.swift"),
    ]
    
    all_passed = True
    for name, path in tests:
        exists = Path(path).exists()
        print_test(name, exists, path if exists else f"Missing: {path}")
        all_passed = all_passed and exists
    
    return all_passed

def test_entitlements_file():
    """Test 2: Verify entitlements file contains CloudKit keys"""
    print_header("Test 2: Entitlements File Content")
    
    entitlements_path = Path("MCVenture/MCVenture.entitlements")
    
    if not entitlements_path.exists():
        print_test("Entitlements exists", False, "File not found")
        return False
    
    try:
        with open(entitlements_path, 'rb') as f:
            plist = plistlib.load(f)
        
        tests = [
            ("iCloud services key", "com.apple.developer.icloud-services" in plist),
            ("iCloud container IDs key", "com.apple.developer.icloud-container-identifiers" in plist),
            ("CloudKit in services", 
             "CloudKit" in plist.get("com.apple.developer.icloud-services", [])),
            ("Container ID correct", 
             any("iCloud." in str(item) for item in plist.get("com.apple.developer.icloud-container-identifiers", []))),
        ]
        
        all_passed = True
        for name, condition in tests:
            print_test(name, condition)
            all_passed = all_passed and condition
        
        return all_passed
    except Exception as e:
        print_test("Parse entitlements", False, str(e))
        return False

def test_xcode_project():
    """Test 3: Verify Xcode project has CloudKit capability configured"""
    print_header("Test 3: Xcode Project Configuration")
    
    pbxproj_path = Path("MCVenture.xcodeproj/project.pbxproj")
    
    if not pbxproj_path.exists():
        print_test("Project file exists", False)
        return False
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    tests = [
        ("Entitlements reference", 'MCVenture.entitlements' in content),
        ("CODE_SIGN_ENTITLEMENTS", 'CODE_SIGN_ENTITLEMENTS' in content),
        ("TargetAttributes section", 'TargetAttributes' in content),
        ("iCloud capability", 'com.apple.iCloud' in content),
        ("CloudKit capability", 'com.apple.CloudKit' in content),
        ("SystemCapabilities", 'SystemCapabilities' in content),
        ("Capability enabled", 'enabled = 1' in content),
    ]
    
    all_passed = True
    for name, condition in tests:
        print_test(name, condition)
        all_passed = all_passed and condition
    
    # Check for proper capability structure
    has_proper_structure = re.search(
        r'SystemCapabilities\s*=\s*{.*com\.apple\.(iCloud|CloudKit).*enabled\s*=\s*1',
        content,
        re.DOTALL
    )
    print_test("Capability structure", has_proper_structure is not None)
    all_passed = all_passed and (has_proper_structure is not None)
    
    return all_passed

def test_cloudkit_manager():
    """Test 4: Verify CloudKit manager implementation"""
    print_header("Test 4: CloudKit Manager Code")
    
    manager_path = Path("MCVenture/Managers/CloudKitSyncManager.swift")
    
    if not manager_path.exists():
        print_test("Manager file exists", False)
        return False
    
    with open(manager_path, 'r') as f:
        content = f.read()
    
    tests = [
        ("Import CloudKit", 'import CloudKit' in content),
        ("CKContainer reference", 'CKContainer' in content),
        ("Public database", 'publicCloudDatabase' in content),
        ("RouteData struct", 'struct RouteData' in content),
        ("Identifiable protocol", 'RouteData: Codable, Identifiable' in content),
        ("Upload function", re.search(r'func.*uploadRoute', content) is not None),
        ("Fetch function", re.search(r'func.*fetchRoutes', content) is not None),
        ("Offline queue", 'offlineQueue' in content),
        ("Retry logic", 'RetryManager' in content or 'retry' in content.lower()),
    ]
    
    all_passed = True
    for name, condition in tests:
        print_test(name, condition)
        all_passed = all_passed and condition
    
    return all_passed

def test_community_view():
    """Test 5: Verify Community Routes View implementation"""
    print_header("Test 5: Community Routes View")
    
    view_path = Path("MCVenture/Views/CommunityRoutesView.swift")
    
    if not view_path.exists():
        print_test("View file exists", False)
        return False
    
    with open(view_path, 'r') as f:
        content = f.read()
    
    tests = [
        ("CommunityRoutesView struct", 'struct CommunityRoutesView' in content),
        ("CloudKitSyncManager reference", 'CloudKitSyncManager' in content),
        ("NavigationStack (not NavigationView)", 'NavigationStack' in content),
        ("Route list", 'List' in content and 'ForEach' in content),
        ("Empty state", 'EmptyStateView' in content),
        ("Success animation", 'SuccessAnimationView' in content),
        ("Error handling", 'errorAlert' in content or 'error' in content),
        ("Unique struct names", 'CommunityRouteRowView' in content and 'CommunityShareRouteView' in content),
    ]
    
    all_passed = True
    for name, condition in tests:
        print_test(name, condition)
        all_passed = all_passed and condition
    
    return all_passed

def test_build_compiles():
    """Test 6: Verify project builds successfully"""
    print_header("Test 6: Build Verification")
    
    print("Building project for iOS Simulator...")
    print("(This may take 30-60 seconds)\n")
    
    import subprocess
    
    try:
        result = subprocess.run([
            'xcodebuild',
            '-project', 'MCVenture.xcodeproj',
            '-scheme', 'MCVenture',
            '-destination', 'platform=iOS Simulator,id=ECB93BA1-C363-4DC5-A5C9-452405D9B406',
            'build',
            '-quiet'
        ], capture_output=True, text=True, timeout=120)
        
        success = result.returncode == 0
        print_test("Build succeeds", success, 
                   "✓ No compilation errors" if success else "Build failed - check errors")
        
        if not success and result.stderr:
            print(f"\n{YELLOW}Build errors (first 500 chars):{RESET}")
            print(result.stderr[:500])
        
        return success
    except subprocess.TimeoutExpired:
        print_test("Build succeeds", False, "Build timed out after 120 seconds")
        return False
    except Exception as e:
        print_test("Build succeeds", False, str(e))
        return False

def main():
    """Run all tests"""
    print_header("CloudKit Configuration Test Suite")
    print(f"{BLUE}Testing MCVenture CloudKit Setup{RESET}\n")
    
    # Change to project directory
    project_dir = Path(__file__).parent
    os.chdir(project_dir)
    
    results = {
        "Project Structure": test_project_structure(),
        "Entitlements File": test_entitlements_file(),
        "Xcode Configuration": test_xcode_project(),
        "CloudKit Manager": test_cloudkit_manager(),
        "Community View": test_community_view(),
        "Build": test_build_compiles(),
    }
    
    # Summary
    print_header("Test Summary")
    
    total = len(results)
    passed = sum(1 for v in results.values() if v)
    
    for test_name, result in results.items():
        status = f"{GREEN}✅{RESET}" if result else f"{RED}❌{RESET}"
        print(f"{status} {test_name}")
    
    print(f"\n{BLUE}Results: {passed}/{total} tests passed{RESET}\n")
    
    if passed == total:
        print(f"{GREEN}{'=' * 60}{RESET}")
        print(f"{GREEN}🎉 ALL TESTS PASSED! CloudKit is properly configured.{RESET}")
        print(f"{GREEN}{'=' * 60}{RESET}")
        print(f"\n{BLUE}Next Steps:{RESET}")
        print("1. Connect your iPhone/iPad to your Mac")
        print("2. Open MCVenture.xcodeproj in Xcode")
        print("3. Select your device in the toolbar")
        print("4. Build and run (⌘R)")
        print("5. Test uploading/downloading routes in the Community section\n")
        return 0
    else:
        print(f"{RED}{'=' * 60}{RESET}")
        print(f"{RED}⚠️  Some tests failed. Review the output above.{RESET}")
        print(f"{RED}{'=' * 60}{RESET}\n")
        return 1

if __name__ == '__main__':
    sys.exit(main())
