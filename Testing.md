# Combined integration/system testing for OBS frontend and backend

## General Assumptions

* Modification of the to be tested VM should be avoided
* Checks where the host of execution can influence the test result should be executed on a jump host.
* Test cases should always be written independently from the executing test system.
  It should be always easy to switch between CI/CD frameworks. Therefore the usual
  UNIX exit codes should (0=success, 1 < failed) be used.


## Current situation

### Test phases

* Before merging a pull request
  * CircleCI
* While building
  * %check section in RPM spec files checked in OBS
* After building
  * RPM/Appliances in openQA and kanku

### Test systems

OBS frontend and backend are tested by two different tools:

* CircleCI
* openQA
  * rspec test suite for the OBS frontend in open-build-service/dist/t
* backend  - kanku
  * perl test cases
    * open-build-service/dist/t (test_system, test_appliance)
    * open-build-service/dist/t/osc (test_system)

### Test scenarios in kanku

1. Appliance test
   Using a prebuild Appliance image, boot it up and start checks

2. RPM installation test
   Using a Kanku JeOS image, boot it up, install OBS RPM Packages and start checks

3. Upgrade test
   Use a prebuilt OBS Appliance image, boot up, run the 1st testphase to ensure
   that the original appliance works, change repos, update RPM Packages, Reboot,
   start 2nd test phase.

### Test case classes

* test_unit (*.t)
  * make it easier to debug and detect problems earlier
  * fast execution
  * Examples
    * check if daemons are started
    * check if files/dirs exists and have right permissions
* test_system (*.ts)
  * Intregration tests, e.g.:
    * Create a home for a user
    * Configure interconnect
    * Run a service
    * Build a package
    * Build a container
    * Download a container via the internal registry
    * Check if containers/packages signed correctly
* test_appliance (*.ta)
  * Appliance specific tests which are not needed if installed via RPM
* test_upgrade (*.tu) (TBD)
  * Tests specific for upgrade screnarios
  * So far there was no need to have such a test class


# Testing with the rpec test suite
  - zypper ar https://download.opensuse.org/repositories/devel:/tools/openSUSE_Leap_15.1/devel:tools.repo
  - zypper ref -s
  - zypper -n in ruby2.5-rubygem-rspec phantomjs ruby2.5-devel zlib-devel
  - cd /srv/obs/open-build-service/dist/t && bundle.ruby2.5 install && bundle.ruby2.5 exec rspec
