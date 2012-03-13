rm Resources; ln -s iphone-resources Resources
sed 's/TARGETED_DEVICE_FAMILY\ =\ 2/TARGETED_DEVICE_FAMILY\ =\ 1/g' Cellfense.xcodeproj/project.pbxproj > Cellfense.xcodeproj/project.new.pbxproj
cp Cellfense.xcodeproj/project.new.pbxproj Cellfense.xcodeproj/project.pbxproj