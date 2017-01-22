var fs = require('fs');

var podExtraSettings = `
use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
`;

fs.appendFile('platforms/ios/Podfile', podExtraSettings, function (err, data) {
  if (err) {
    console.log(err);
    process.exit(1);
  }
});
