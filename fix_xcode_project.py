#!/usr/bin/env python3
import os
import re
import uuid
import plistlib

def generate_uuid():
    """Generate a 24-character hex UUID for Xcode"""
    return uuid.uuid4().hex.upper()[:24]

def create_pbx_file_reference(file_path, file_name):
    """Create a PBXFileReference entry"""
    file_uuid = generate_uuid()
    file_type = "sourcecode.swift" if file_name.endswith('.swift') else "text"
    return file_uuid, f'{file_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = {file_name}; sourceTree = "<group>"; }};'

def create_pbx_group(name, children_uuids, path=None):
    """Create a PBXGroup entry"""
    group_uuid = generate_uuid()
    children_str = "\n\t\t\t\t".join([f"{uuid} /* {name} */," for uuid, name in children_uuids])
    path_str = f'path = {path};' if path else 'name = {name}; path = {name};'
    return group_uuid, f'''{group_uuid} /* {name} */ = {{
			isa = PBXGroup;
			children = (
				{children_str}
			);
			{path_str}
			sourceTree = "<group>";
		}};'''

def find_swift_files(directory):
    """Find all Swift files in directory structure"""
    swift_files = {}
    for root, dirs, files in os.walk(directory):
        # Skip hidden directories
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        rel_path = os.path.relpath(root, directory)
        if rel_path == '.':
            rel_path = ''
            
        for file in files:
            if file.endswith('.swift'):
                full_path = os.path.join(rel_path, file) if rel_path else file
                swift_files[full_path] = file
                
    return swift_files

def create_new_project_structure():
    """Create the new project file structure"""
    print("📁 Creating new project structure...")
    
    # Find all Swift files
    swift_files = find_swift_files('Weather')
    
    # Organize files by directory
    file_structure = {}
    file_refs = {}
    
    for file_path, file_name in swift_files.items():
        # Create file reference
        file_uuid, file_ref = create_pbx_file_reference(file_path, file_name)
        file_refs[file_uuid] = file_ref
        
        # Organize by directory
        dir_path = os.path.dirname(file_path)
        if not dir_path:
            dir_path = 'root'
            
        if dir_path not in file_structure:
            file_structure[dir_path] = []
        file_structure[dir_path].append((file_uuid, file_name))
    
    # Create groups
    groups = {}
    
    # Create subgroups first
    for dir_path in sorted(file_structure.keys()):
        if dir_path != 'root' and '/' not in dir_path:
            children = file_structure.get(dir_path, [])
            group_uuid, group_ref = create_pbx_group(dir_path, children, dir_path)
            groups[group_uuid] = group_ref
    
    # Create main Weather group
    root_items = file_structure.get('root', [])
    root_items.extend([(uuid, name) for uuid, name in groups.items() if '/' not in name])
    
    weather_uuid, weather_group = create_pbx_group('Weather', root_items, 'Weather')
    groups[weather_uuid] = weather_group
    
    return file_refs, groups, weather_uuid

def update_project_file():
    """Update the Xcode project file"""
    project_file = 'Weather.xcodeproj/project.pbxproj'
    
    if not os.path.exists(project_file):
        print(f"❌ Project file not found: {project_file}")
        return False
        
    print(f"📝 Updating {project_file}...")
    
    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Create new structure
    file_refs, groups, main_group_uuid = create_new_project_structure()
    
    # Build new content sections
    file_ref_section = "/* Begin PBXFileReference section */\n"
    for uuid, ref in file_refs.items():
        file_ref_section += f"\t\t{ref}\n"
    file_ref_section += "/* End PBXFileReference section */"
    
    group_section = "/* Begin PBXGroup section */\n"
    for uuid, ref in groups.items():
        group_section += f"\t\t{ref}\n"
    group_section += "/* End PBXGroup section */"
    
    # Replace sections in project file
    # This is a simplified approach - in reality we'd need to parse the entire file
    # For now, let's create a backup and suggest manual steps
    
    backup_file = project_file + '.backup'
    with open(backup_file, 'w') as f:
        f.write(content)
    
    print(f"✅ Created backup: {backup_file}")
    print("\n📋 File structure found:")
    for path, name in sorted(find_swift_files('Weather').items()):
        print(f"  {path}")
    
    return True

if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    update_project_file()