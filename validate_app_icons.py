#!/usr/bin/env python3
"""
App Icon Validation Script for Apple App Store Compliance

This script validates that all app icons meet Apple's requirements:
- Correct dimensions
- No alpha/transparency
- RGB color space
- PNG format
- Proper Contents.json configuration
"""

import json
import subprocess
import sys
from pathlib import Path

# ANSI color codes
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_header(text):
    print(f"\n{BLUE}{'=' * 70}{RESET}")
    print(f"{BLUE}{text:^70}{RESET}")
    print(f"{BLUE}{'=' * 70}{RESET}\n")

def print_result(test_name, passed, message=""):
    status = f"{GREEN}✅ PASS{RESET}" if passed else f"{RED}❌ FAIL{RESET}"
    print(f"{status} - {test_name}")
    if message:
        print(f"         {message}")

def get_image_info(image_path):
    """Get image properties using sips command"""
    try:
        result = subprocess.run(
            ['sips', '-g', 'pixelWidth', '-g', 'pixelHeight', '-g', 'hasAlpha', 
             '-g', 'space', '-g', 'format', str(image_path)],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            return None
        
        info = {}
        for line in result.stdout.split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                info[key.strip()] = value.strip()
        
        return {
            'width': int(info.get('pixelWidth', 0)),
            'height': int(info.get('pixelHeight', 0)),
            'has_alpha': info.get('hasAlpha', 'yes') == 'yes',
            'color_space': info.get('space', ''),
            'format': info.get('format', '')
        }
    except Exception as e:
        print(f"{RED}Error reading {image_path}: {e}{RESET}")
        return None

def validate_icon_requirements(icon_path, expected_size):
    """Validate a single icon meets Apple requirements"""
    info = get_image_info(icon_path)
    if not info:
        return False, "Could not read image"
    
    issues = []
    
    # Check dimensions
    if info['width'] != expected_size or info['height'] != expected_size:
        issues.append(f"Wrong size: {info['width']}x{info['height']} (expected {expected_size}x{expected_size})")
    
    # Check alpha channel
    if info['has_alpha']:
        issues.append("Has transparency/alpha channel (not allowed)")
    
    # Check color space
    if 'RGB' not in info['color_space']:
        issues.append(f"Wrong color space: {info['color_space']} (should be RGB)")
    
    # Check format
    if info['format'] != 'png':
        issues.append(f"Wrong format: {info['format']} (should be png)")
    
    if issues:
        return False, "; ".join(issues)
    return True, "All checks passed"

def validate_contents_json(contents_path):
    """Validate Contents.json structure"""
    try:
        with open(contents_path, 'r') as f:
            contents = json.load(f)
        
        # Check required keys
        if 'images' not in contents:
            return False, "Missing 'images' key"
        
        if 'info' not in contents:
            return False, "Missing 'info' key"
        
        # Check for required sizes
        required_sizes = {
            ('iphone', '20x20', '2x'): 40,
            ('iphone', '20x20', '3x'): 60,
            ('iphone', '29x29', '2x'): 58,
            ('iphone', '29x29', '3x'): 87,
            ('iphone', '40x40', '2x'): 80,
            ('iphone', '40x40', '3x'): 120,
            ('iphone', '60x60', '2x'): 120,
            ('iphone', '60x60', '3x'): 180,
            ('ios-marketing', '1024x1024', '1x'): 1024,
        }
        
        found_sizes = set()
        for image in contents['images']:
            key = (image.get('idiom'), image.get('size'), image.get('scale'))
            found_sizes.add(key)
        
        missing = []
        for required_key in required_sizes.keys():
            if required_key not in found_sizes:
                missing.append(f"{required_key[0]} {required_key[1]} @{required_key[2]}")
        
        if missing:
            return False, f"Missing required sizes: {', '.join(missing)}"
        
        return True, f"All {len(required_sizes)} required sizes present"
    
    except json.JSONDecodeError as e:
        return False, f"Invalid JSON: {e}"
    except Exception as e:
        return False, f"Error: {e}"

def main():
    print_header("MCVenture App Icon Compliance Validation")
    
    # Locate AppIcon.appiconset
    icon_set_path = Path('/Users/bntf/Desktop/MCVenture/MCVenture/Assets.xcassets/AppIcon.appiconset')
    
    if not icon_set_path.exists():
        print(f"{RED}❌ Error: AppIcon.appiconset not found at {icon_set_path}{RESET}")
        return 1
    
    print(f"{GREEN}✓{RESET} Found AppIcon.appiconset at: {icon_set_path}\n")
    
    # Test 1: Validate Contents.json
    print_header("Test 1: Contents.json Structure")
    
    contents_path = icon_set_path / 'Contents.json'
    passed, message = validate_contents_json(contents_path)
    print_result("Contents.json structure", passed, message)
    
    if not passed:
        print(f"\n{YELLOW}⚠️  Fix Contents.json before continuing{RESET}\n")
        return 1
    
    # Test 2: Validate individual icon files
    print_header("Test 2: Individual Icon Validation")
    
    # Load Contents.json to get expected sizes
    with open(contents_path, 'r') as f:
        contents = json.load(f)
    
    all_passed = True
    size_mapping = {
        'icon-20.png': 20,
        'icon-29.png': 29,
        'icon-40.png': 40,
        'icon-58.png': 58,
        'icon-60.png': 60,
        'icon-76.png': 76,
        'icon-80.png': 80,
        'icon-87.png': 87,
        'icon-120.png': 120,
        'icon-152.png': 152,
        'icon-167.png': 167,
        'icon-180.png': 180,
        'icon-1024.png': 1024,
    }
    
    for filename, expected_size in size_mapping.items():
        icon_path = icon_set_path / filename
        if icon_path.exists():
            passed, message = validate_icon_requirements(icon_path, expected_size)
            print_result(filename, passed, message)
            all_passed = all_passed and passed
        else:
            print_result(filename, False, "File not found")
            all_passed = False
    
    # Test 3: Check for extra/unused files
    print_header("Test 3: Clean Directory Check")
    
    all_files = set(p.name for p in icon_set_path.glob('*') if p.is_file() and p.name != 'Contents.json')
    expected_files = set(size_mapping.keys())
    extra_files = all_files - expected_files
    
    if extra_files:
        print_result("No extra files", False, f"Found: {', '.join(extra_files)}")
        all_passed = False
    else:
        print_result("No extra files", True, "Clean directory")
    
    # Test 4: Apple-specific requirements
    print_header("Test 4: Apple App Store Requirements")
    
    # Check 1024x1024 icon specifically (most important)
    icon_1024 = icon_set_path / 'icon-1024.png'
    if icon_1024.exists():
        info = get_image_info(icon_1024)
        if info:
            checks = [
                ("Exact 1024x1024 size", info['width'] == 1024 and info['height'] == 1024),
                ("No alpha/transparency", not info['has_alpha']),
                ("RGB color space", 'RGB' in info['color_space']),
                ("PNG format", info['format'] == 'png'),
            ]
            
            for check_name, result in checks:
                print_result(check_name, result)
                all_passed = all_passed and result
    
    # Test 5: File size check (icons shouldn't be too large)
    print_header("Test 5: File Size Optimization")
    
    icon_1024_size = icon_1024.stat().st_size / 1024  # KB
    if icon_1024_size > 1024:  # Over 1MB
        print_result("Icon file size", False, f"{icon_1024_size:.1f} KB (should be < 1 MB)")
        print(f"         {YELLOW}Consider optimizing to reduce app size{RESET}")
    else:
        print_result("Icon file size", True, f"{icon_1024_size:.1f} KB")
    
    # Final summary
    print_header("Validation Summary")
    
    if all_passed:
        print(f"{GREEN}{'=' * 70}{RESET}")
        print(f"{GREEN}🎉 ALL TESTS PASSED - Icons are Apple App Store compliant!{RESET}")
        print(f"{GREEN}{'=' * 70}{RESET}\n")
        print(f"{BLUE}Your app icons meet all Apple requirements:{RESET}")
        print("  ✅ Correct dimensions for all sizes")
        print("  ✅ No alpha/transparency")
        print("  ✅ RGB color space")
        print("  ✅ PNG format")
        print("  ✅ Proper Contents.json configuration")
        print("  ✅ Clean directory structure")
        print("\n✨ Your icons are ready for App Store submission! ✨\n")
        return 0
    else:
        print(f"{RED}{'=' * 70}{RESET}")
        print(f"{RED}❌ VALIDATION FAILED - Issues found with icons{RESET}")
        print(f"{RED}{'=' * 70}{RESET}\n")
        print(f"{YELLOW}Review the failures above and fix them before submission.{RESET}\n")
        return 1

if __name__ == '__main__':
    sys.exit(main())
