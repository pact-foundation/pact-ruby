### 1.0.9 (unreleased)

* Fixing pretty generate of json [Beth Skurrie]

### 1.0.8 (13 September 2013)

* Added validation to ensure that a Term has both a matcher and a generate value, and that the value to generate matches the given regular expression [Beth Skurrie]

* Added the SomethingLike class that does a structure diff on anything contianed within in it. Will change the name when we can think of something better! [Beth Skurrie, Greg Dziemidowicz]

### 1.0.7 (11 September 2013)

* Allow request query to be a Pact Term. [Seb Glazebrook]

### 1.0.6 (11 September 2013)

* Made reports dir configurable [Beth Skurrie]
* Changed the way the pact files are configured. They are now in the Pact.service_provider block in the pact_helper file. Require 'pact/tasks' in the Rakefile and run 'rake pact:verify' instead of setting up custom tasks. [Beth Skurrie]

### 1.0.5 (6 September 2013)

* Added verification reports when running rake pact:verify:xxx [Latheesh Padukana, Beth Skurrie]
* Changed pact:verify failure message to display in red [Latheesh Padukana, Beth Skurrie]

### 1.0.4 (6 September 2013)

* Added pact/tasks as an easy way to load the rake tasks and classes into the client project [Beth Skurrie]
* Removed unused rake_task.rb file [Beth Skurrie]

### 1.0.3 (5 September 2013)

* pact_helper.rb is located and loaded automatically if a support_file is not defined in a pact:verify task [Beth Skurrie]
