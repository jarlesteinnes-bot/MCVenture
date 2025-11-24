#!/usr/bin/env python3
"""
Automatically add iCloud/CloudKit capability to MCVenture Xcode project.
This modifies the project.pbxproj file to add the necessary capability attributes.
"""

import re
import uuid
import shutil
from pathlib import Path


def generate_xcode_uuid():
    """Generate a 24-character hex UUID compatible with Xcode format."""
    return uuid.uuid4().hex.upper()[:24]


def add_cloudkit_capability(pbxproj_path):
    """
    Add iCloud and CloudKit capability to the Xcode project.
    This adds the necessary PBXTargetAttributes section entries.
    """
    
    # Read the project file
    with open(pbxproj_path, 'r') as f:
        content = f.read()
    
    # Backup original
    backup_path = str(pbxproj_path) + '.backup2'
    shutil.copy2(pbxproj_path, backup_path)
    print(f"✅ Created backup: {backup_path}")
    
    # Find the target UUID for MCVenture (it's in the PBXNativeTarget section)
    target_match = re.search(r'6E7A28B12ED07CF3000DAB69 /\* MCVenture \*/ = \{', content)
    if not target_match:
        print("❌ Could not find MCVenture target")
        return False
    
    target_uuid = "6E7A28B12ED07CF3000DAB69"
    print(f"✅ Found MCVenture target UUID: {target_uuid}")
    
    # Check if TargetAttributes section exists
    if 'TargetAttributes' not in content:
        print("⚠️  TargetAttributes section not found, will create it")
        
        # Find the PBXProject section
        project_match = re.search(
            r'(6E7A28AA2ED07CF3000DAB69 /\* Project object \*/ = \{[^\}]*?buildConfigurationList = [^;]+;)',
            content,
            re.DOTALL
        )
        
        if project_match:
            # Add TargetAttributes after buildConfigurationList
            target_attributes = f'''
			TargetAttributes = {{
				{target_uuid} = {{
					CreatedOnToolsVersion = 15.0;
					DevelopmentTeam = HVLTT45S6B;
					SystemCapabilities = {{
						com.apple.iCloud = {{
							enabled = 1;
						}};
						com.apple.CloudKit = {{
							enabled = 1;
						}};
					}};
				}};
			}};'''
            
            # Insert after buildConfigurationList line
            insertion_point = project_match.end()
            content = content[:insertion_point] + target_attributes + content[insertion_point:]
            print("✅ Added TargetAttributes section with CloudKit capability")
        else:
            print("❌ Could not find PBXProject section")
            return False
    else:
        print("✅ TargetAttributes section already exists")
        
        # Check if our target already has attributes
        target_attr_pattern = rf'{target_uuid} = \{{[^}}]*?\}};'
        target_attr_match = re.search(target_attr_pattern, content, re.DOTALL)
        
        if target_attr_match:
            # Target attributes exist, check for SystemCapabilities
            target_attr_content = target_attr_match.group(0)
            
            if 'SystemCapabilities' not in target_attr_content:
                # Add SystemCapabilities to existing target attributes
                system_capabilities = '''
					SystemCapabilities = {
						com.apple.iCloud = {
							enabled = 1;
						};
						com.apple.CloudKit = {
							enabled = 1;
						};
					};'''
                
                # Insert before the closing brace of the target attributes
                insert_pos = target_attr_match.end() - 3  # Before "};"
                content = content[:insert_pos] + system_capabilities + '\n\t\t\t\t' + content[insert_pos:]
                print("✅ Added SystemCapabilities to existing target attributes")
            else:
                print("⚠️  SystemCapabilities already exist, checking CloudKit...")
                
                if 'com.apple.CloudKit' not in target_attr_content:
                    # Add CloudKit to existing SystemCapabilities
                    syscap_match = re.search(r'SystemCapabilities = \{', target_attr_content)
                    if syscap_match:
                        cloudkit_entry = '''
						com.apple.iCloud = {
							enabled = 1;
						};
						com.apple.CloudKit = {
							enabled = 1;
						};'''
                        
                        # Find position in full content
                        syscap_pos = content.find('SystemCapabilities = {', target_attr_match.start())
                        insert_pos = syscap_pos + len('SystemCapabilities = {')
                        content = content[:insert_pos] + cloudkit_entry + content[insert_pos:]
                        print("✅ Added CloudKit to existing SystemCapabilities")
                else:
                    print("✅ CloudKit capability already configured!")
        else:
            # Target has no attributes, add them inside TargetAttributes
            target_attributes_entry = f'''
				{target_uuid} = {{
					CreatedOnToolsVersion = 15.0;
					DevelopmentTeam = HVLTT45S6B;
					SystemCapabilities = {{
						com.apple.iCloud = {{
							enabled = 1;
						}};
						com.apple.CloudKit = {{
							enabled = 1;
						}};
					}};
				}};'''
            
            # Find TargetAttributes section and add our entry
            target_attr_section = re.search(r'TargetAttributes = \{', content)
            if target_attr_section:
                insert_pos = target_attr_section.end()
                content = content[:insert_pos] + target_attributes_entry + content[insert_pos:]
                print("✅ Added target attributes with CloudKit capability")
    
    # Write the modified content
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
    print(f"\n✅ Successfully modified {pbxproj_path}")
    return True


def verify_entitlements():
    """Verify the entitlements file exists and has correct content."""
    entitlements_path = Path('/Users/bntf/Desktop/MCVenture/MCVenture/MCVenture.entitlements')
    
    if not entitlements_path.exists():
        print(f"❌ Entitlements file not found: {entitlements_path}")
        return False
    
    with open(entitlements_path, 'r') as f:
        content = f.read()
    
    required_keys = [
        'com.apple.developer.icloud-container-identifiers',
        'com.apple.developer.icloud-services',
        'CloudKit'
    ]
    
    missing = [key for key in required_keys if key not in content]
    if missing:
        print(f"⚠️  Entitlements file missing keys: {missing}")
        return False
    
    print("✅ Entitlements file verified")
    return True


def main():
    print("=" * 60)
    print("CloudKit Capability Auto-Setup for MCVenture")
    print("=" * 60)
    
    project_path = Path('/Users/bntf/Desktop/MCVenture/MCVenture.xcodeproj/project.pbxproj')
    
    if not project_path.exists():
        print(f"❌ Project file not found: {project_path}")
        return
    
    print(f"\n📁 Project: {project_path}")
    
    # Step 1: Verify entitlements
    print("\n📝 Step 1: Verifying entitlements file...")
    verify_entitlements()
    
    # Step 2: Add CloudKit capability to project
    print("\n⚙️  Step 2: Adding CloudKit capability to Xcode project...")
    if add_cloudkit_capability(project_path):
        print("\n" + "=" * 60)
        print("✅ SUCCESS! CloudKit capability has been added!")
        print("=" * 60)
        print("\n📋 Next steps:")
        print("1. Open MCVenture.xcodeproj in Xcode")
        print("2. Verify in Signing & Capabilities tab that iCloud is enabled")
        print("3. Build and run on a physical device")
        print("4. Test route upload/download from CloudKit")
        print("\n💡 If the capability doesn't show in Xcode:")
        print("   • Clean build folder (Cmd+Shift+K)")
        print("   • Close and reopen Xcode")
        print("   • The code will work even if UI doesn't show it immediately")
    else:
        print("\n❌ Failed to add CloudKit capability")
        print("Please add it manually in Xcode:")
        print("Target → Signing & Capabilities → + Capability → iCloud → CloudKit")


if __name__ == '__main__':
    main()
