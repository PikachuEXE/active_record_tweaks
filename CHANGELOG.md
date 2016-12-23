# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


## [Unreleased]

### Added

- Nothing

### Changed

- Add support for AR 5.0.x
- Drop support for AR 3.x
- Drop support for Ruby < 2.1

### Fixed

- Nothing


## [0.2.1] - 2016-10-17

### Changed

- Remove activesupport dependency (was using "concern")
- Deprecate inclusion of `ActiveRecordTweaks` and `ActiveRecordTweaks::Integration`
- Change: Deprecate `ActiveRecordTweaks::Integration::ClassMethods` without replacement


## [0.2.0] - 2014-03-14

### Added

- Add `#cache_key_from_attributes` & `#cache_key_from_attribute`
- Add `.cache_key_without_timestamp`


## 0.1 - 2013-11-06

### Added

- Initial Release
  
  
[Unreleased]: https://github.com/AssetSync/asset_sync/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/AssetSync/asset_sync/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/AssetSync/asset_sync/compare/v0.1...v0.2.0

