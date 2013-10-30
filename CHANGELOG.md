Do this to generate your change history

    git log --date=relative --pretty=format:'  * %h - %s (%an, %ad)'

### 1.0.19 (29 October 2013)
 * e4b990e - Gsub '-' to '_' in request headers. (Sebastian Glazebrook, 4 minutes ago)
 * 52ac8f8 - Added documentation for PACT_DESCRIPTION and PACT_PROVIDER_STATE to README. (Beth, 13 hours ago)

### 1.0.18 (29 October 2013)

 * f2892d4 - Fixed bug where an exception is thrown when a key is not found and is attempted to be matched to a regexp (Beth, 60 seconds ago)

### 1.0.17 (29 October 2013)

 * 74bdf09 - Added missing require for Regexp json deserialisation (Beth, 3 minutes ago)
 * d69482e - Removed JsonWarning for ActiveSupport JSON. (Beth, 3 hours ago)
 * 5f72720 - Fixing ALL THE REGEXPS that ActiveSupport JSON broke. The pact gem should now serialise and deserialise its own JSON properly even when ActiveSupport is loaded by the call
 * c3e6430 - Added config.ru parsing to best practices. (Beth, 9 hours ago)
 * ae3a70f - DRYing up pact file reading code. (Beth, 11 hours ago)
 * dc83557 - Fixing VerificationTask spec (Beth, 11 hours ago)
 * bae379c - Added consumer name, provider name and request method to output of rspec. (Beth, 12 hours ago)
 * 89c2620 - Adding spec filtering using PACT_DESCRIPTION and PACT_PROVIDER_STATE to pact:verify and pact:verify:at tasks. (Beth, 28 hours ago)
 * 7ab43a9 - Adding puts to show when pact:verify specs are being filtered. (Beth, 28 hours ago)

### 1.0.16 (28 October 2013)

* ce0d102 - Fixing specs after adding pact_helper and changing producer_state to provider_state. There is no producer here any more! Naughty producer. (Beth, 71 seconds ago)
* 90f7203 - Fixing bug where RSpec world was not cleared between pact:verify tasks. (Beth, 16 minutes ago)
* b323336 - Fixed bug where pact_helper option was not being passed into the PactSpecRunner from the task configuration (Beth, 4 hours ago)
* b1e78f5 - Added environment variable support. (Sergei Matheson, 3 days ago)
* 2b9f39a - Allow match criteria to be passed through to pact:verify tasks on command line (Sergei Matheson, 3 days ago)
* 2241f29 - Un-deprecating the support_file functionality after having discovered a valid use for it (project that contains two rack apps that have a pact with each other). Renamed op
* c94fc13 - Updating example provider state (Beth, 4 days ago)
* 6900f39 - Updating README with better client class example (Beth, 5 days ago)
* e41f755 - Update README.md (bskurrie, 5 days ago)
* 2abcce4 - Adding to pact best practices. (Beth, 5 days ago)

### 1.0.15 (22 October 2013)

 * 6800a58 - Updating README with latest TODOs (Beth, 2 hours ago)
 * 99a6827 - Improving logging in pact:verify. Fixing bug where Pact log level was ignored. (Beth, 3 hours ago)
 * 5434f54 - Updating README with best practice and information on the :pact => :verify metadata. (Beth, 4 hours ago)
 * 16dd2be - Adding :pact => :verify to pact:verify rspec examples for https://github.com/uglyog/pact/issues/3 (Beth, 5 hours ago)

### 1.0.14 (22 October 2013)

* 406e746 - Added a template for the provider state when no provider state is found (Beth, 9 minutes ago)
* 1f58be8 - Adding error messages when set_up or tear_down are not defined, and added no_op as a way to avoid having to use an empty set_up block when there is no data to set up (Beth)
* 78d3999 - Merge pull request #2 from stuliston/json_warning_minor_refactor (Ronald Holshausen, 18 hours ago)
* be4a466 - Altering JsonWarning so that it only warns once. Added spec to confirm that's the case. (Stuart Liston, 21 hours ago)
* 3b11b42 - Fixing the issue where a method defined in global scope could not be accessed in the DSL delegation code (Beth, 11 days ago)

### 1.0.13 (10 October 2013)

* Fixed bug deserialising Pact::SomethingLike [Beth Skurrie]

### 1.0.12 (9 October 2013)

* Changing default pactfile_write_mode to :overwrite, and adding :smart option to dynamically determine whether rake is running. [Beth Skurrie]

### 1.0.11 (26 September 2013)
* Added X-Pact-Mock-Service headers to all mock service administration requests, reducing the risk of the client project making a request that is unintentionally intercepted by the mock service administration handlers. [Beth Skurrie]

### 1.0.10 (24 September 2013)
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
