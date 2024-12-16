<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v7.4.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v7.4.0) - 2024-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v7.3.0...v7.4.0)

### Added

- (CAT-2101) Add support for Debian-12 [#571](https://github.com/puppetlabs/puppetlabs-tomcat/pull/571) ([skyamgarp](https://github.com/skyamgarp))

### Fixed

- (CAT-2158) Upgrade rexml to address CVE-2024-49761 [#573](https://github.com/puppetlabs/puppetlabs-tomcat/pull/573) ([amitkarsale](https://github.com/amitkarsale))

## [v7.3.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v7.3.0) - 2024-10-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v7.2.0...v7.3.0)

### Added

- Adding support for sslhostconfig options [#569](https://github.com/puppetlabs/puppetlabs-tomcat/pull/569) ([malikparvez](https://github.com/malikparvez))

## [v7.2.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v7.2.0) - 2024-01-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v7.1.0...v7.2.0)

### Added

- CONT-1149-erb_to_epp_conversion_tomcat [#541](https://github.com/puppetlabs/puppetlabs-tomcat/pull/541) ([praj1001](https://github.com/praj1001))

### Fixed

- Update var types [#536](https://github.com/puppetlabs/puppetlabs-tomcat/pull/536) ([Joris29](https://github.com/Joris29))

## [v7.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v7.1.0) - 2023-05-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v7.0.0...v7.1.0)

### Added

- (CONT-588) - allow deferred function for change [#533](https://github.com/puppetlabs/puppetlabs-tomcat/pull/533) ([Ramesh7](https://github.com/Ramesh7))
- pdksync - (MAINT) - Allow Stdlib 9.x [#532](https://github.com/puppetlabs/puppetlabs-tomcat/pull/532) ([LukasAud](https://github.com/LukasAud))

### Fixed

- (CONT-802) - Revert RSpec/NoExpectationExample [#526](https://github.com/puppetlabs/puppetlabs-tomcat/pull/526) ([jordanbreen28](https://github.com/jordanbreen28))
- Optimize var types [#519](https://github.com/puppetlabs/puppetlabs-tomcat/pull/519) ([Joris29](https://github.com/Joris29))

## [v7.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v7.0.0) - 2023-04-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v6.4.1...v7.0.0)

### Changed

- (CONT-802) - add puppet 8/drop puppet 6 [#523](https://github.com/puppetlabs/puppetlabs-tomcat/pull/523) ([jordanbreen28](https://github.com/jordanbreen28))

## [v6.4.1](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v6.4.1) - 2023-03-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v6.4.0...v6.4.1)

### Fixed

- (CONT-817) Fix wrong package_ensure parameter type [#516](https://github.com/puppetlabs/puppetlabs-tomcat/pull/516) ([LukasAud](https://github.com/LukasAud))

## [v6.4.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v6.4.0) - 2023-03-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v6.3.0...v6.4.0)

### Added

- (CONT-366) Syntax update [#507](https://github.com/puppetlabs/puppetlabs-tomcat/pull/507) ([LukasAud](https://github.com/LukasAud))

### Fixed

- Update commons-daemon-native version to match Tomcat bundled version [#510](https://github.com/puppetlabs/puppetlabs-tomcat/pull/510) ([uoe-pjackson](https://github.com/uoe-pjackson))
- Allow adding and removing attributes  in Context (#502) [#503](https://github.com/puppetlabs/puppetlabs-tomcat/pull/503) ([uoe-pjackson](https://github.com/uoe-pjackson))
- Exclude name in resources [#501](https://github.com/puppetlabs/puppetlabs-tomcat/pull/501) ([kobybr](https://github.com/kobybr))
- pdksync - (CONT-189) Remove support for RedHat6 / OracleLinux6 / Scientific6 [#500](https://github.com/puppetlabs/puppetlabs-tomcat/pull/500) ([david22swan](https://github.com/david22swan))

## [v6.3.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v6.3.0) - 2022-09-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v6.2.0...v6.3.0)

### Added

- pdksync - (GH-cat-11) Certify Support for Ubuntu 22.04 [#493](https://github.com/puppetlabs/puppetlabs-tomcat/pull/493) ([david22swan](https://github.com/david22swan))
- pdksync - (GH-cat-12) Add Support for Redhat 9 [#492](https://github.com/puppetlabs/puppetlabs-tomcat/pull/492) ([david22swan](https://github.com/david22swan))
- Allow usage of Context/Resources [#491](https://github.com/puppetlabs/puppetlabs-tomcat/pull/491) ([tuxmea](https://github.com/tuxmea))

## [v6.2.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v6.2.0) - 2022-05-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v6.1.0...v6.2.0)

### Added

- Update puppet-archive dependency [#477](https://github.com/puppetlabs/puppetlabs-tomcat/pull/477) ([h4l](https://github.com/h4l))
- pdksync - (IAC-1753) - Add Support for AlmaLinux 8 [#476](https://github.com/puppetlabs/puppetlabs-tomcat/pull/476) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1751) - Add Support for Rocky 8 [#475](https://github.com/puppetlabs/puppetlabs-tomcat/pull/475) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - (GH-iac-334) Remove Support for Ubuntu 14.04/16.04 [#480](https://github.com/puppetlabs/puppetlabs-tomcat/pull/480) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1787) Remove Support for CentOS 6 [#478](https://github.com/puppetlabs/puppetlabs-tomcat/pull/478) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1598) - Remove Support for Debian 8 [#474](https://github.com/puppetlabs/puppetlabs-tomcat/pull/474) ([david22swan](https://github.com/david22swan))

## [v6.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v6.1.0) - 2021-08-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v6.0.0...v6.1.0)

### Added

- pdksync - (IAC-1709) - Add Support for Debian 11 [#468](https://github.com/puppetlabs/puppetlabs-tomcat/pull/468) ([david22swan](https://github.com/david22swan))

### Fixed

- (IAC-1741) Allow stdlib v8.0.0 [#469](https://github.com/puppetlabs/puppetlabs-tomcat/pull/469) ([david22swan](https://github.com/david22swan))

## [v6.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v6.0.0) - 2021-07-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v5.1.0...v6.0.0)

### Changed

- [IAC-1690] - Remove tomcat7 as is EOL [#459](https://github.com/puppetlabs/puppetlabs-tomcat/pull/459) ([daianamezdrea](https://github.com/daianamezdrea))

### Added

- (MODULES-9520) Allow removal of webapps [#456](https://github.com/puppetlabs/puppetlabs-tomcat/pull/456) ([daianamezdrea](https://github.com/daianamezdrea))
- Accept Datatype Sensitive for Secrets [#454](https://github.com/puppetlabs/puppetlabs-tomcat/pull/454) ([cocker-cc](https://github.com/cocker-cc))

### Fixed

- [MODULES-9781] - Add examples for catalina attributes and properties [#453](https://github.com/puppetlabs/puppetlabs-tomcat/pull/453) ([daianamezdrea](https://github.com/daianamezdrea))

## [v5.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v5.1.0) - 2021-05-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v5.0.0...v5.1.0)

### Added

- Add service_name parameter to tomcat::instance [#446](https://github.com/puppetlabs/puppetlabs-tomcat/pull/446) ([treydock](https://github.com/treydock))

### Fixed

- (MODULES-10644) Document source upgrade process [#443](https://github.com/puppetlabs/puppetlabs-tomcat/pull/443) ([binford2k](https://github.com/binford2k))

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v5.0.0) - 2021-03-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.3.0...v5.0.0)

### Changed

- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#431](https://github.com/puppetlabs/puppetlabs-tomcat/pull/431) ([carabasdaniel](https://github.com/carabasdaniel))

## [v4.3.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.3.0) - 2020-12-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.2.0...v4.3.0)

### Added

- pdksync - (feat) - Add support for Puppet 7 [#422](https://github.com/puppetlabs/puppetlabs-tomcat/pull/422) ([daianamezdrea](https://github.com/daianamezdrea))
- Refactor valve types [#415](https://github.com/puppetlabs/puppetlabs-tomcat/pull/415) ([h-haaks](https://github.com/h-haaks))

### Fixed

- (IAC-1236) Adding SLES OSs for release_checks [#417](https://github.com/puppetlabs/puppetlabs-tomcat/pull/417) ([pmcmaw](https://github.com/pmcmaw))
- (IAC-1214) - Move SKIP_GCC to test file [#416](https://github.com/puppetlabs/puppetlabs-tomcat/pull/416) ([pmcmaw](https://github.com/pmcmaw))

## [v4.2.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.2.0) - 2020-08-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.1.0...v4.2.0)

### Added

- pdksync - (IAC-973) - Update travis/appveyor to run on new default branch `main` [#405](https://github.com/puppetlabs/puppetlabs-tomcat/pull/405) ([david22swan](https://github.com/david22swan))

### Fixed

- Increase puppetlabs/concat lower bound [#404](https://github.com/puppetlabs/puppetlabs-tomcat/pull/404) ([bFekete](https://github.com/bFekete))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.1.0) - 2020-07-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.0.0...v4.1.0)

### Added

- (IAC-746) - Add ubuntu 20.04 support [#399](https://github.com/puppetlabs/puppetlabs-tomcat/pull/399) ([david22swan](https://github.com/david22swan))

### Fixed

- Allow override status_command in case of use_init [#400](https://github.com/puppetlabs/puppetlabs-tomcat/pull/400) ([leroyguillaume](https://github.com/leroyguillaume))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.0.0) - 2019-12-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v3.1.0...v4.0.0)

### Changed

- (MAINT) Make ensurable enums consistent [#367](https://github.com/puppetlabs/puppetlabs-tomcat/pull/367) ([smortex](https://github.com/smortex))

### Added

- (FM-8699) - Addition of Support for CentOS 8 [#374](https://github.com/puppetlabs/puppetlabs-tomcat/pull/374) ([david22swan](https://github.com/david22swan))
- Add Resources support [#368](https://github.com/puppetlabs/puppetlabs-tomcat/pull/368) ([smortex](https://github.com/smortex))

### Fixed

- Completely remove tomcat::install_from_source [#366](https://github.com/puppetlabs/puppetlabs-tomcat/pull/366) ([smortex](https://github.com/smortex))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v3.1.0) - 2019-09-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v3.0.0...v3.1.0)

### Added

- FM-8413 add support on Debian10 [#361](https://github.com/puppetlabs/puppetlabs-tomcat/pull/361) ([lionce](https://github.com/lionce))
- (FM-8232) Convert to litmus [#360](https://github.com/puppetlabs/puppetlabs-tomcat/pull/360) ([tphoney](https://github.com/tphoney))
- FM-8050 - add redhat8 support [#354](https://github.com/puppetlabs/puppetlabs-tomcat/pull/354) ([lionce](https://github.com/lionce))

### Fixed

- add show diff to all augeas calls [#322](https://github.com/puppetlabs/puppetlabs-tomcat/pull/322) ([johmicd](https://github.com/johmicd))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v3.0.0) - 2019-05-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.5.0...v3.0.0)

### Changed

- pdksync - (MODULES-8444) - Raise lower Puppet bound [#347](https://github.com/puppetlabs/puppetlabs-tomcat/pull/347) ([david22swan](https://github.com/david22swan))

### Fixed

- (MODULES-8817) - Update to account for loss of SVN Tomcat archive [#344](https://github.com/puppetlabs/puppetlabs-tomcat/pull/344) ([david22swan](https://github.com/david22swan))

## [2.5.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.5.0) - 2019-01-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.4.0...2.5.0)

### Added

- (MODULES-8147) - Add SLES 15 support [#328](https://github.com/puppetlabs/puppetlabs-tomcat/pull/328) ([eimlav](https://github.com/eimlav))
- Add context parameter type (re-submit #205) [#317](https://github.com/puppetlabs/puppetlabs-tomcat/pull/317) ([joshbeard](https://github.com/joshbeard))

### Fixed

- (maint) - Ubuntu 18.04 issues fix [#333](https://github.com/puppetlabs/puppetlabs-tomcat/pull/333) ([david22swan](https://github.com/david22swan))
- pdksync - (FM-7655) Fix rubygems-update for ruby < 2.3 [#330](https://github.com/puppetlabs/puppetlabs-tomcat/pull/330) ([tphoney](https://github.com/tphoney))
- [MODULES-7547] Update globalnamingresource class, and add tests [#305](https://github.com/puppetlabs/puppetlabs-tomcat/pull/305) ([jplindquist](https://github.com/jplindquist))

## [2.4.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.4.0) - 2018-10-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.3.0...2.4.0)

### Added

- pdksync - (FM-7392) - Puppet 6 Testing Changes [#321](https://github.com/puppetlabs/puppetlabs-tomcat/pull/321) ([pmcmaw](https://github.com/pmcmaw))
- pdksync - (MODULES-7658) use beaker4 in puppet-module-gems [#315](https://github.com/puppetlabs/puppetlabs-tomcat/pull/315) ([tphoney](https://github.com/tphoney))
- (FM-7239) - Addition of support for Ubuntu 18.04 [#306](https://github.com/puppetlabs/puppetlabs-tomcat/pull/306) ([david22swan](https://github.com/david22swan))
- adding wait_timeout var for init [#303](https://github.com/puppetlabs/puppetlabs-tomcat/pull/303) ([ackiejoe](https://github.com/ackiejoe))
- [FM-7050] Addition of support for Debian 9 on Tomcat [#300](https://github.com/puppetlabs/puppetlabs-tomcat/pull/300) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - (MODULES-6805) metadata.json shows support for puppet 6 [#319](https://github.com/puppetlabs/puppetlabs-tomcat/pull/319) ([tphoney](https://github.com/tphoney))
- pdksync - (MODULES-7705) - Bumping stdlib dependency from < 5.0.0 to < 6.0.0 [#314](https://github.com/puppetlabs/puppetlabs-tomcat/pull/314) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-7633) - Update README Limitations section [#307](https://github.com/puppetlabs/puppetlabs-tomcat/pull/307) ([eimlav](https://github.com/eimlav))
- (maint) Double retry count to workaround slow startups [#301](https://github.com/puppetlabs/puppetlabs-tomcat/pull/301) ([hunner](https://github.com/hunner))
- [FM-6967] Removal of unsupported OS from tomcat [#299](https://github.com/puppetlabs/puppetlabs-tomcat/pull/299) ([david22swan](https://github.com/david22swan))
- Add rspec retry gem to sync file [#295](https://github.com/puppetlabs/puppetlabs-tomcat/pull/295) ([HelenCampbell](https://github.com/HelenCampbell))
- #puppethack work if resource title contains spaces [#287](https://github.com/puppetlabs/puppetlabs-tomcat/pull/287) ([rheijkoop](https://github.com/rheijkoop))

## [2.3.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.3.0) - 2018-02-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.2.0...2.3.0)

### Fixed

- (MODULES-6626) fix the generated shell when using addto [#286](https://github.com/puppetlabs/puppetlabs-tomcat/pull/286) ([tequeter](https://github.com/tequeter))

## [2.2.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.2.0) - 2018-02-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.1.0...2.2.0)

### Added

- Addition of protocol flag -1 to curl command [#281](https://github.com/puppetlabs/puppetlabs-tomcat/pull/281) ([HelenCampbell](https://github.com/HelenCampbell))
- Add ability to set status_command [#262](https://github.com/puppetlabs/puppetlabs-tomcat/pull/262) ([esalberg](https://github.com/esalberg))
- Add flexibility to directory management in tomcat::instance [#217](https://github.com/puppetlabs/puppetlabs-tomcat/pull/217) ([esalberg](https://github.com/esalberg))

### Fixed

- Merging Fix Into Release [#283](https://github.com/puppetlabs/puppetlabs-tomcat/pull/283) ([david22swan](https://github.com/david22swan))
- Fix failing curl command [#282](https://github.com/puppetlabs/puppetlabs-tomcat/pull/282) ([HelenCampbell](https://github.com/HelenCampbell))
- Fixes Gemfile and avoid break in future module syncs. [#274](https://github.com/puppetlabs/puppetlabs-tomcat/pull/274) ([pmcmaw](https://github.com/pmcmaw))
- Fix Tomcat tests for Tomcat8 [#268](https://github.com/puppetlabs/puppetlabs-tomcat/pull/268) ([willmeek](https://github.com/willmeek))
- Syntax error when $addto parameter set in tomcat::setenv::entry [#266](https://github.com/puppetlabs/puppetlabs-tomcat/pull/266) ([adsully](https://github.com/adsully))
- [#puppethack] tomcat::war copy the war as root user and not as tomcat [#265](https://github.com/puppetlabs/puppetlabs-tomcat/pull/265) ([ralfbosz](https://github.com/ralfbosz))
- MODULES-5805: Fix for spaces in context elements [#261](https://github.com/puppetlabs/puppetlabs-tomcat/pull/261) ([BarnacleBob](https://github.com/BarnacleBob))

## [2.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.1.0) - 2017-10-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.0.0...2.1.0)

### Fixed

- (MODULES-5589) - add user/group to war file [#254](https://github.com/puppetlabs/puppetlabs-tomcat/pull/254) ([pmcmaw](https://github.com/pmcmaw))
- fix lint warnings [#252](https://github.com/puppetlabs/puppetlabs-tomcat/pull/252) ([PascalBourdier](https://github.com/PascalBourdier))
- (MODULES-5396) move tomcat::config::properties declaration out of else block [#238](https://github.com/puppetlabs/puppetlabs-tomcat/pull/238) ([jimethn](https://github.com/jimethn))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.0.0) - 2017-08-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.7.0...2.0.0)

### Changed

- (maint Remove validate calls and update lint/docs [#223](https://github.com/puppetlabs/puppetlabs-tomcat/pull/223) ([hunner](https://github.com/hunner))

### Added

- add support for allow_insecure parameter [#231](https://github.com/puppetlabs/puppetlabs-tomcat/pull/231) ([hunner](https://github.com/hunner))
- add support for valves in context.xml [#213](https://github.com/puppetlabs/puppetlabs-tomcat/pull/213) ([simonrondelez](https://github.com/simonrondelez))
- Implement beaker-module_install_helper [#196](https://github.com/puppetlabs/puppetlabs-tomcat/pull/196) ([wilson208](https://github.com/wilson208))

### Fixed

- (maint) Retry harder [#248](https://github.com/puppetlabs/puppetlabs-tomcat/pull/248) ([hunner](https://github.com/hunner))
- (maint) Add allow_insecure to tomcat::war [#246](https://github.com/puppetlabs/puppetlabs-tomcat/pull/246) ([hunner](https://github.com/hunner))
- (maint) Allow mismatched ssl certs [#245](https://github.com/puppetlabs/puppetlabs-tomcat/pull/245) ([hunner](https://github.com/hunner))
- (maint) Moar retry! (still failed on one node) [#243](https://github.com/puppetlabs/puppetlabs-tomcat/pull/243) ([hunner](https://github.com/hunner))
- (maint) Retry failures instead of blind sleeps [#242](https://github.com/puppetlabs/puppetlabs-tomcat/pull/242) ([hunner](https://github.com/hunner))
- (MODULES-1545) Switch back to curl [#235](https://github.com/puppetlabs/puppetlabs-tomcat/pull/235) ([hunner](https://github.com/hunner))
- [MODULES-5360] Adding fix to allow the proxy settings to be passed to archive resource [#234](https://github.com/puppetlabs/puppetlabs-tomcat/pull/234) ([pckls](https://github.com/pckls))
- (MODULES-1545) Allow context paths in war_name [#233](https://github.com/puppetlabs/puppetlabs-tomcat/pull/233) ([hunner](https://github.com/hunner))
- (MODULES-2232) Verify connector ports don't conflict [#230](https://github.com/puppetlabs/puppetlabs-tomcat/pull/230) ([hunner](https://github.com/hunner))
- (maint) Don't duplicate resources for different dependencies [#228](https://github.com/puppetlabs/puppetlabs-tomcat/pull/228) ([hunner](https://github.com/hunner))
- fix retval checks in init script template [#221](https://github.com/puppetlabs/puppetlabs-tomcat/pull/221) ([fraenki](https://github.com/fraenki))
- (MODULES-4658) Allow duplicate realms [#216](https://github.com/puppetlabs/puppetlabs-tomcat/pull/216) ([hunner](https://github.com/hunner))

## [1.7.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.7.0) - 2017-05-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.6.1...1.7.0)

### Added

- [MODULES-4654] Add SLES to metadata.json [#204](https://github.com/puppetlabs/puppetlabs-tomcat/pull/204) ([wilson208](https://github.com/wilson208))
- [msync] 786266 Implement puppet-module-gems, a45803 Remove metadata.json from locales config [#201](https://github.com/puppetlabs/puppetlabs-tomcat/pull/201) ([wilson208](https://github.com/wilson208))
- Ability to not manage catalina.properties. [#194](https://github.com/puppetlabs/puppetlabs-tomcat/pull/194) ([ikogan](https://github.com/ikogan))
- (FM-5972) gettext and spec.opts [#189](https://github.com/puppetlabs/puppetlabs-tomcat/pull/189) ([eputnam](https://github.com/eputnam))
- Add proxy / environment support for tomcat::install [#173](https://github.com/puppetlabs/puppetlabs-tomcat/pull/173) ([edestecd](https://github.com/edestecd))
- Add ability to add `Environment` elements. [#169](https://github.com/puppetlabs/puppetlabs-tomcat/pull/169) ([ikogan](https://github.com/ikogan))

### Fixed

- (FM-6166) - Updating tests error match [#207](https://github.com/puppetlabs/puppetlabs-tomcat/pull/207) ([pmcmaw](https://github.com/pmcmaw))
- Fix faulty header and link in ToC [#198](https://github.com/puppetlabs/puppetlabs-tomcat/pull/198) ([sgnl05](https://github.com/sgnl05))
- (maint) Fix duplicate resources in host/realm/valve [#197](https://github.com/puppetlabs/puppetlabs-tomcat/pull/197) ([hunner](https://github.com/hunner))
- MODULES-4238 fix #184 create $catalina_home [#190](https://github.com/puppetlabs/puppetlabs-tomcat/pull/190) ([tphoney](https://github.com/tphoney))
- [#puppethack] Fix fixtures.yml [#187](https://github.com/puppetlabs/puppetlabs-tomcat/pull/187) ([ralfbosz](https://github.com/ralfbosz))

## [1.6.1](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.6.1) - 2016-12-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.6.0...1.6.1)

### Fixed

- #[puppethack] Fix MODULES-3224 [#186](https://github.com/puppetlabs/puppetlabs-tomcat/pull/186) ([dhollinger](https://github.com/dhollinger))
- #[puppethack] Fix MODULES-1986 [#185](https://github.com/puppetlabs/puppetlabs-tomcat/pull/185) ([dhollinger](https://github.com/dhollinger))
- #[puppethack] MODULES-4003 Fix ordering issue when using a package for installation [#184](https://github.com/puppetlabs/puppetlabs-tomcat/pull/184) ([dhollinger](https://github.com/dhollinger))
- (MODULES-4153) Fix duplicate resources; unfix umask [#182](https://github.com/puppetlabs/puppetlabs-tomcat/pull/182) ([hunner](https://github.com/hunner))

## [1.6.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.6.0) - 2016-10-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.5.0...1.6.0)

### Added

- (MODULES-3713) Allow catalina_home and catalina_base to be unmanaged [#166](https://github.com/puppetlabs/puppetlabs-tomcat/pull/166) ([hunner](https://github.com/hunner))
- Feature: MODULES-3458 - Support nesting valve under parent context [#150](https://github.com/puppetlabs/puppetlabs-tomcat/pull/150) ([fherbert](https://github.com/fherbert))
- Feature: Add the ability to configure manager elements in context.xml [#142](https://github.com/puppetlabs/puppetlabs-tomcat/pull/142) ([aaron-miller](https://github.com/aaron-miller))
- add tomcat::config::context::environment [#137](https://github.com/puppetlabs/puppetlabs-tomcat/pull/137) ([juame](https://github.com/juame))

### Fixed

- Fix ubuntu 16.04 tests [#165](https://github.com/puppetlabs/puppetlabs-tomcat/pull/165) ([hunner](https://github.com/hunner))
- MODULES-3742 Bugfix/strict vars service [#161](https://github.com/puppetlabs/puppetlabs-tomcat/pull/161) ([hggh](https://github.com/hggh))
- Add owner/group to tomcat_users.pp [#158](https://github.com/puppetlabs/puppetlabs-tomcat/pull/158) ([ananace](https://github.com/ananace))
- MODULES-3436 export prefix in sysconfig/tomcat does not work [#149](https://github.com/puppetlabs/puppetlabs-tomcat/pull/149) ([k2patel](https://github.com/k2patel))
- changed user and group for the extract resource [#147](https://github.com/puppetlabs/puppetlabs-tomcat/pull/147) ([sacchettom](https://github.com/sacchettom))
- fix MODULES-3353 by making sure the Resource name is defined first [#143](https://github.com/puppetlabs/puppetlabs-tomcat/pull/143) ([jimethn](https://github.com/jimethn))

## [1.5.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.5.0) - 2016-04-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.4.1...1.5.0)

### Added

- MODULES-2984 - Add support for host aliases [#118](https://github.com/puppetlabs/puppetlabs-tomcat/pull/118) ([kdhquickitt](https://github.com/kdhquickitt))

### Fixed

- fixes for jsvc-init script template [#135](https://github.com/puppetlabs/puppetlabs-tomcat/pull/135) ([DavidS](https://github.com/DavidS))
- (maint) fix t::c::s::tomcat_users under strict variables [#134](https://github.com/puppetlabs/puppetlabs-tomcat/pull/134) ([DavidS](https://github.com/DavidS))
- Update documentation and fix bugs [#131](https://github.com/puppetlabs/puppetlabs-tomcat/pull/131) ([hunner](https://github.com/hunner))
- Remove function call from collector [#129](https://github.com/puppetlabs/puppetlabs-tomcat/pull/129) ([hunner](https://github.com/hunner))
- Finish the install before creating instances [#128](https://github.com/puppetlabs/puppetlabs-tomcat/pull/128) ([hunner](https://github.com/hunner))
- Fix for older concats [#127](https://github.com/puppetlabs/puppetlabs-tomcat/pull/127) ([hunner](https://github.com/hunner))
- Fix home/base installation [#125](https://github.com/puppetlabs/puppetlabs-tomcat/pull/125) ([hunner](https://github.com/hunner))

## [1.4.1](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.4.1) - 2015-12-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.4.0...1.4.1)

## [1.4.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.4.0) - 2015-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.3.3...1.4.0)

### Fixed

- (FM-3930) Fix for multiple realms [#112](https://github.com/puppetlabs/puppetlabs-tomcat/pull/112) ([mentat](https://github.com/mentat))

## [1.3.3](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.3.3) - 2015-12-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.3.2...1.3.3)

### Added

- (MODULES-2471) Specify port when purging connectors [#105](https://github.com/puppetlabs/puppetlabs-tomcat/pull/105) ([joshbeard](https://github.com/joshbeard))

### Fixed

- delete realm nodes in depth-first order to workaround augeas segfault [#111](https://github.com/puppetlabs/puppetlabs-tomcat/pull/111) ([GeoffWilliams](https://github.com/GeoffWilliams))
- Document 'purge_connectors' [#107](https://github.com/puppetlabs/puppetlabs-tomcat/pull/107) ([joshbeard](https://github.com/joshbeard))

## [1.3.2](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.3.2) - 2015-08-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.3.1...1.3.2)

### Fixed

- [#puppethack] Validate that catalina_base does not to end with / [#102](https://github.com/puppetlabs/puppetlabs-tomcat/pull/102) ([igalic](https://github.com/igalic))
- Wrap username attribute in quotes. [#100](https://github.com/puppetlabs/puppetlabs-tomcat/pull/100) ([bryancornies](https://github.com/bryancornies))

## [1.3.1](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.3.1) - 2015-07-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.3.0...1.3.1)

## [1.3.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.3.0) - 2015-06-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.2.0...1.3.0)

### Added

- (MODULES-1886) - Allow configuration of location of server.xml [#82](https://github.com/puppetlabs/puppetlabs-tomcat/pull/82) ([underscorgan](https://github.com/underscorgan))
- Adds parameter for enabling Tomcat service on boot [#77](https://github.com/puppetlabs/puppetlabs-tomcat/pull/77) ([bmjen](https://github.com/bmjen))
- Being able to ordering setenv entries. [#74](https://github.com/puppetlabs/puppetlabs-tomcat/pull/74) ([icalvete](https://github.com/icalvete))
- Added manifest for managing Realm elements in server.xml [#73](https://github.com/puppetlabs/puppetlabs-tomcat/pull/73) ([surry](https://github.com/surry))
- Manage User and Roles in Realms [#70](https://github.com/puppetlabs/puppetlabs-tomcat/pull/70) ([juame](https://github.com/juame))
- Context Container below Host element in server.xml [#66](https://github.com/puppetlabs/puppetlabs-tomcat/pull/66) ([juame](https://github.com/juame))

### Fixed

- tomcat 7 mirror ran away [#85](https://github.com/puppetlabs/puppetlabs-tomcat/pull/85) ([underscorgan](https://github.com/underscorgan))
- (FM-2010) Tomcat download mirrors are flaky (tests) [#67](https://github.com/puppetlabs/puppetlabs-tomcat/pull/67) ([justinstoller](https://github.com/justinstoller))
- Update additional_attributes to support values with spaces [#64](https://github.com/puppetlabs/puppetlabs-tomcat/pull/64) ([underscorgan](https://github.com/underscorgan))

## [1.2.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.2.0) - 2014-11-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.1.0...1.2.0)

### Added

- MODULES-1478: Add a $purge_connectors parameter. [#56](https://github.com/puppetlabs/puppetlabs-tomcat/pull/56) ([philipwigg](https://github.com/philipwigg))

### Fixed

- Fix for strict variables [#61](https://github.com/puppetlabs/puppetlabs-tomcat/pull/61) ([underscorgan](https://github.com/underscorgan))
- Use `curl -k` to fix cert issue with rhel5 [#60](https://github.com/puppetlabs/puppetlabs-tomcat/pull/60) ([underscorgan](https://github.com/underscorgan))
- Directory in opt should only be created if  is true [#52](https://github.com/puppetlabs/puppetlabs-tomcat/pull/52) ([krionux](https://github.com/krionux))

## [1.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.1.0) - 2014-10-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.0.1...1.1.0)

### Added

- Use curl -k [#53](https://github.com/puppetlabs/puppetlabs-tomcat/pull/53) ([underscorgan](https://github.com/underscorgan))

### Fixed

- (FM-1912) Illegal version range in puppetlabs-tomcat requirements [#50](https://github.com/puppetlabs/puppetlabs-tomcat/pull/50) ([thallgren](https://github.com/thallgren))
- More strict var unit test fixes [#48](https://github.com/puppetlabs/puppetlabs-tomcat/pull/48) ([underscorgan](https://github.com/underscorgan))
- Tomcat strict variables [#46](https://github.com/puppetlabs/puppetlabs-tomcat/pull/46) ([underscorgan](https://github.com/underscorgan))
- MODULES-1295: Multiple connectors with same protocol [#44](https://github.com/puppetlabs/puppetlabs-tomcat/pull/44) ([underscorgan](https://github.com/underscorgan))
- Fix version key for dependencies in metadata.json. [#43](https://github.com/puppetlabs/puppetlabs-tomcat/pull/43) ([scotje](https://github.com/scotje))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.0.1) - 2014-09-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.0.0...1.0.1)

### Fixed

- Cherrypick test fixes [#38](https://github.com/puppetlabs/puppetlabs-tomcat/pull/38) ([underscorgan](https://github.com/underscorgan))
- Setenv fix [#35](https://github.com/puppetlabs/puppetlabs-tomcat/pull/35) ([underscorgan](https://github.com/underscorgan))
- fixed to allow value arrays. [#17](https://github.com/puppetlabs/puppetlabs-tomcat/pull/17) ([zshahan](https://github.com/zshahan))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/1.0.0) - 2014-09-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/0.1.2...1.0.0)

### Added

- Add the ability to purge exploded WAR directories. [#23](https://github.com/puppetlabs/puppetlabs-tomcat/pull/23) ([underscorgan](https://github.com/underscorgan))
- Allow one to set configuration when using tomcat package. [#21](https://github.com/puppetlabs/puppetlabs-tomcat/pull/21) ([Spredzy](https://github.com/Spredzy))

## [0.1.2](https://github.com/puppetlabs/puppetlabs-tomcat/tree/0.1.2) - 2014-08-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/0.1.1...0.1.2)

## [0.1.1](https://github.com/puppetlabs/puppetlabs-tomcat/tree/0.1.1) - 2014-08-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/0.1.0...0.1.1)

### Added

- Tomcat 7.0.55 was released. [#11](https://github.com/puppetlabs/puppetlabs-tomcat/pull/11) ([underscorgan](https://github.com/underscorgan))

### Fixed

- Call install_ methods only once in spec_helper_acceptance [#10](https://github.com/puppetlabs/puppetlabs-tomcat/pull/10) ([colinPL](https://github.com/colinPL))
- Fix warning function name [#6](https://github.com/puppetlabs/puppetlabs-tomcat/pull/6) ([joshbeard](https://github.com/joshbeard))

## [0.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/0.1.0) - 2014-08-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/99f264460b6eae6bfbbed68e91eaa1fa2b48c3b9...0.1.0)
