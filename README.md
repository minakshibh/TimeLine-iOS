# timeline-ios

## Setting up project
First install [carthage](https://github.com/Carthage/Carthage), [fastlane](https://github.com/fastlane/fastlane) and [cocoapods](https://github.com/cocoapods/cocoapods).
```
$ brew install carthage fastlane
$ gem install cocoapods
```

Then update the dependencies.
```
$ fastlane update
```

## URL Schemes
- User
	
	`mytimelineapp://user/?user_id=:uuid&external=:eid&name=:name`
	
- Timeline

	`mytimelineapp://timeline/?timeline_id=:uuid&name=:name`
- Moment

	`mytimelineapp://moment/?video_id=:uuid&name=:name&timeline_id=:tid`

## Fastlane
- `$ fastlane update`: updates all dependencies like `carthage` and `pod`
- `$ fastlane archive`: updates, builds and archives the application
- `$ fastlane beta`: archives and publishes the application to TestFlight
- `$ fastlane deploy`: archives and submit the application for review
