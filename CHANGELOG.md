### 1.0.11 (26 September 2014)
* Added X-Pact-Mock-Service headers to all mock service administration requests, reducing the risk of the client project making a request that is unintentionally intercepted by the mock service administration handlers. [Beth Skurrie]

### 1.0.10 (24 September 2014)
* Removing unused requires [Beth Skurrie, 20 hours ago]
* Adding example changes [Beth Skurrie, 20 hours ago]
* Cleaning up provider configuration DSL. [Beth Skurrie, 6 days ago]
* Cleaned up consumer configuration DSL. [Beth Skurrie, 6 days ago]
* Splitting MockService request handlers into their own separate files. Divide and conquer... [Beth Skurrie, 6 days ago]
* Improving logging in mock service. [Beth Skurrie, 6 days ago]
* Cleaned up interaction list test. [Beth Skurrie, 6 days ago]
* Added better messages for matching when arrays are of different lengths. [Beth Skurrie, 6 days ago]
* Refactoring the Request world. Put each sub class of Request into it's relevant module. [Beth Skurrie, 6 days ago]
* Renaming request.match to request.matches? [Beth Skurrie, 7 days ago]
* Commenting and cleaning code. [Beth Skurrie, 7 days ago]
* Removed horrible as_json_for_mock_service method and created new class to do the same thing. [Beth Skurrie, 7 days ago]
* Moving rake task files into tasks directory. [Beth Skurrie, 7 days ago]
* Moving request file into consumer_contract folder. [Beth Skurrie, 7 days ago]
* Symbolizing keys so from_hash does not have to duplicate so much of the constructor methods. Service provider is now mandatory. [Beth Skurrie, 7 days ago]
* Removed Hashie from run time dependencies. [Beth Skurrie, 7 days ago]
* Starting to clean up mock service. Adding integration tests for failure scenarios. [Beth Skurrie, 7 days ago]
* Added RSpec fire to ensure stubbed methods exist. Pulled the recreation of a repayable request from an expected request out of the TestHelper into its own class. [Beth Skurrie, 7 days ago]
* Fixed problem where methods in previous scope could not be accessed by the DSL delegator [Beth Skurrie]

### 1.0.9 (16 September 2013)

* Fixing pretty generate of json [Beth Skurrie]
* Fixed missing require [Beth Skurrie]

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
