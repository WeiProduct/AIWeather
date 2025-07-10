#!/usr/bin/env ruby
require 'xcodeproj'

# Open the project
project_path = 'Weather.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "🔧 Fixing Weather.xcodeproj..."

# Find the main Weather group
main_group = project.main_group['Weather']
if main_group.nil?
  puts "❌ Could not find Weather group"
  exit 1
end

# Remove all current file references (they point to wrong locations)
puts "🗑️  Removing old file references..."
main_group.clear

# Define the folder structure
folders = {
  'Models' => ['WeatherAPIModels.swift', 'WeatherCondition.swift', 'WeatherData.swift'],
  'Views/Components' => ['CardBackground.swift', 'ErrorView.swift', 'GradientBackground.swift', 
                        'LoadingView.swift', 'NavigationHeader.swift', 'RefreshableScrollView.swift'],
  'Views/Screens' => ['CityManagementView.swift', 'MainWeatherView.swift', 'SettingsView.swift',
                      'WeatherDetailView.swift', 'WeeklyForecastView.swift', 'WelcomeView.swift'],
  'Services' => ['CacheManager.swift', 'DependencyContainer.swift', 'LanguageManager.swift',
                 'LocationManager.swift', 'NetworkManager.swift', 'WeatherService.swift', 'WeatherServiceV2.swift'],
  'ViewModels' => ['WeatherViewModel.swift', 'WeatherViewModelV2.swift'],
  'Utilities' => ['AppConstants.swift', 'Debouncer.swift'],
  'Extensions' => ['Color+Extensions.swift']
}

# Root level files
root_files = ['ApiConfig.swift', 'ContentView.swift', 'WeatherApp.swift']

# Add root files
puts "📝 Adding root files..."
root_files.each do |file|
  file_path = "Weather/#{file}"
  if File.exist?(file_path)
    file_ref = main_group.new_reference(file_path)
    file_ref.name = file
    puts "  ✅ Added #{file}"
  else
    puts "  ⚠️  File not found: #{file_path}"
  end
end

# Add folders and their files
folders.each do |folder_path, files|
  puts "\n📁 Processing #{folder_path}..."
  
  # Create nested groups
  current_group = main_group
  folder_path.split('/').each do |folder_name|
    existing_group = current_group[folder_name]
    if existing_group
      current_group = existing_group
    else
      current_group = current_group.new_group(folder_name)
    end
  end
  
  # Add files to the group
  files.each do |file|
    file_path = "Weather/#{folder_path}/#{file}"
    if File.exist?(file_path)
      file_ref = current_group.new_reference(file_path)
      file_ref.name = file
      puts "  ✅ Added #{file}"
    else
      puts "  ⚠️  File not found: #{file_path}"
    end
  end
end

# Add files to build phase
puts "\n🔨 Updating build phases..."
target = project.targets.first
build_phase = target.source_build_phase

# Clear existing build files
build_phase.clear

# Add all Swift files to build phase
swift_files = Dir.glob("Weather/**/*.swift")
swift_files.each do |file_path|
  file_ref = project.files.find { |f| f.real_path.to_s == file_path }
  if file_ref && !file_ref.real_path.to_s.include?('Test')
    build_phase.add_file_reference(file_ref)
    puts "  ✅ Added to build: #{File.basename(file_path)}"
  end
end

# Save the project
puts "\n💾 Saving project..."
project.save

puts "\n✅ Project fixed!"
puts "\nNext steps:"
puts "1. Open Xcode"
puts "2. Clean build folder (Cmd+Shift+K)"
puts "3. Build the project (Cmd+B)"