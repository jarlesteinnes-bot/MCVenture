#!/usr/bin/env python3
"""
Automatically configure CloudKit in MCVenture Xcode project
"""

import os
import sys
import uuid
import re

def generate_uuid():
    """Generate unique ID for Xcode objects"""
    return ''.join(str(uuid.uuid4()).upper().split('-'))[:24]

def backup_project(project_path):
    """Create backup of project file"""
    import shutil
    backup_path = project_path + '.backup'
    shutil.copy2(project_path, backup_path)
    print(f"✅ Backed up project to: {backup_path}")
    return backup_path

def add_entitlements_to_project(project_path, entitlements_path):
    """Add entitlements file to Xcode project"""
    
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Generate UUIDs for the file references
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    # Add file reference
    file_ref_section = f"""
\t\t{file_ref_uuid} /* MCVenture.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = MCVenture.entitlements; sourceTree = "<group>"; }};"""
    
    # Find PBXFileReference section and add our reference
    pbx_file_ref_pattern = r'(/\* Begin PBXFileReference section \*/)'
    content = re.sub(pbx_file_ref_pattern, r'\1' + file_ref_section, content, count=1)
    
    # Add to main group (find MCVenture group)
    group_pattern = r'(/\* MCVenture \*/ = \{[^}]*children = \([^)]*)'
    replacement = r'\1\n\t\t\t\t' + file_ref_uuid + ' /* MCVenture.entitlements */,'
    content = re.sub(group_pattern, replacement, content, count=1)
    
    # Add CODE_SIGN_ENTITLEMENTS to build configuration
    # Find XCBuildConfiguration sections for MCVenture target
    build_settings_pattern = r'(buildSettings = \{[^}]*ASSETCATALOG_COMPILER_APPICON_NAME[^}]*)(PRODUCT_BUNDLE_IDENTIFIER = com\.mc\.no\.MCVenture;)'
    replacement = r'\1CODE_SIGN_ENTITLEMENTS = MCVenture/MCVenture.entitlements;\n\t\t\t\t\2'
    content = re.sub(build_settings_pattern, replacement, content)
    
    # Write back
    with open(project_path, 'w') as f:
        f.write(content)
    
    print(f"✅ Added entitlements file to project")
    return True

def add_icloud_capability(project_path):
    """Add iCloud capability to project"""
    
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Check if already has CloudKit
    if 'com.apple.CloudKit' in content or 'com.apple.developer.icloud' in content:
        print("⚠️  iCloud capability already exists in project")
        return True
    
    # Add SystemCapabilities if not present
    capabilities_uuid = generate_uuid()
    
    # This is a simplified version - full implementation would parse pbxproj properly
    # For now, we'll add a note that manual step is needed
    print("⚠️  iCloud capability needs to be added manually in Xcode")
    print("   Reason: Xcode project capabilities require complex pbxproj modifications")
    
    return False

def main():
    # Paths
    project_dir = '/Users/bntf/Desktop/MCVenture'
    project_path = os.path.join(project_dir, 'MCVenture.xcodeproj/project.pbxproj')
    entitlements_path = os.path.join(project_dir, 'MCVenture/MCVenture.entitlements')
    
    print("🚀 Configuring CloudKit for MCVenture...")
    print()
    
    # Check files exist
    if not os.path.exists(project_path):
        print(f"❌ Error: Project file not found at {project_path}")
        sys.exit(1)
    
    if not os.path.exists(entitlements_path):
        print(f"❌ Error: Entitlements file not found at {entitlements_path}")
        sys.exit(1)
    
    # Backup project
    backup_path = backup_project(project_path)
    
    try:
        # Add entitlements file reference
        add_entitlements_to_project(project_path, entitlements_path)
        
        # Try to add iCloud capability (may require manual step)
        add_icloud_capability(project_path)
        
        print()
        print("=" * 60)
        print("✅ AUTOMATIC CONFIGURATION COMPLETE!")
        print("=" * 60)
        print()
        print("📝 MANUAL STEPS REQUIRED IN XCODE:")
        print()
        print("1. Open MCVenture.xcodeproj in Xcode")
        print("2. Select MCVenture target → Signing & Capabilities tab")
        print("3. Click '+ Capability' button")
        print("4. Add 'iCloud'")
        print("5. Check the 'CloudKit' checkbox")
        print("6. Under Containers, it should show:")
        print("   ✓ iCloud.com.mc.no.MCVenture")
        print()
        print("That's it! The entitlements file is already configured.")
        print()
        print("🧪 TO TEST:")
        print("- Build the project (should succeed)")
        print("- Run on a physical device signed into iCloud")
        print("- Open CommunityRoutesView to browse/share routes")
        print()
        print(f"💾 Backup saved at: {backup_path}")
        print()
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print(f"Restoring backup from: {backup_path}")
        import shutil
        shutil.copy2(backup_path, project_path)
        print("✅ Project restored from backup")
        sys.exit(1)

if __name__ == '__main__':
    main()
