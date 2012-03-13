rm Resources; ln -s ipad-resources Resources
sed 's/TARGETED_DEVICE_FAMILY\ =\ 1/TARGETED_DEVICE_FAMILY\ =\ 2/g' Cellfense.xcodeproj/project.pbxproj > Cellfense.xcodeproj/project.new.pbxproj
cp Cellfense.xcodeproj/project.new.pbxproj Cellfense.xcodeproj/project.pbxproj