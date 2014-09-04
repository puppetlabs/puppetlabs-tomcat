##2014-09-04 - Supported Release 1.0.1
###Summary

This is a bugfix release.

###Bugfixes
- Fix typo in tomcat::instance
- Update acceptance tests for new tomcat releases

##2014-08-27 - Supported Release 1.0.0
###Summary

This release has added support for installation from packages, improved WAR management, and updates to testing and documentation.

###Features
- Updated tomcat::setenv::entry to better support installations from package
- Added the ability to purge auto-exploded WAR directories when removing WARs. Defaults to purging these directories
- Added warnings for unused variables when installing from package
- Updated acceptance tests and nodesets
- Updated README

###Deprecations
- $tomcat::setenv::entry::base_path is being deprecated in favor of $tomcat::setenv::entry::config_file

##2014-08-20 - Release 0.1.2
###Summary

This release adds compatibility information and updates the README with information on the requirement of augeas >= 1.0.0.

##2014-08-14 - Release 0.1.1
###Summary

This is a bugfix release.

###Bugfixes
- Update 'warn' to correct 'warning' function.
- Update README for use_init.
- Test updates and fixes.

##2014-08-06 - Release 0.1.0
###Summary

Initial release of the tomcat module.
