Do this to generate your change history

    git log --date=relative --pretty=format:'  * %h - %s (%an, %ad)'

### 1.0.29 (12 December 2013)

* 8ffde69 - Providing before :all like functionality using before :each to get the dual benefits of faster tests and the ability to use stubbing (Beth, 53 seconds ago)
* d30a78b - Added test to ensure rspec stubbing always works (Beth Skurrie, 15 hours ago)

### 1.0.28 (11 December 2013)

* 24f9ea0 - Changed provider set up and tear down back to running in before :each, as rspec stubbing is not supported in before :all (Beth, 15 seconds ago)
* 825e787 - Fixing failing tests (Beth, 4 hours ago)
* fb6a1c8 - Moving ProviderState collection into its own class (Beth, 6 hours ago)

### 1.0.27 (10 December 2013)

* 388fc7b - Changing provider set up and tear down to run before :all rather than before :each (Beth, 13 minutes ago)
* 06b5626 - Updating TODO list in the README. (Beth, 25 hours ago)
* 823f306 - Update README.md (bethesque, 32 hours ago)
* 7d96017 - Improving layout of text diff message (Beth Skurrie, 2 days ago)
* 9c88c3a - Working on a new way to display the diff between an expected and actual request/response (Beth Skurrie, 2 days ago)
* ff2c448 - Added a Difference class instead of a hash with :expected and :actual (Beth Skurrie, 2 days ago)
* b34457c - Moved all missing provider state templates into the one message at the end of the test so it's easier to digest and can be copied directly into a file. (Beth Skurrie, 2
* 1729887 - Moving ProviderStateProxy on to Pact World (Beth Skurrie, 3 days ago)
* c53cb4d - Starting to add Pact::World (Beth, 4 days ago)
* f7af9e2 - Recording missing provider states (Beth, 4 days ago)
* 4caa171 - Starting work on ProviderStateProxy - intent is for it to record missing and unused states to report at the end of the pact:verify (Beth, 4 days ago)

### 1.0.26 (5 December 2013)

* e4be654 - BEST COMMIT TO PACT EVER since the introduction of pact:verify. Got rid of the horrific backtraces. (Beth, 5 hours ago)
* 2810db7 - Updated README to point to realestate-com-au travis CI build (Ronald Holshausen, 28 hours ago)
* bfa357a - Update README.md (bethesque, 30 hours ago)

### 1.0.25 (4 December 2013)

* 20dd5fa - Updated the homepage in gemspec (Beth, 4 minutes ago)

### 1.0.24 (4 December 2013)

* fd30d36 - Merge branch 'master' of github.com:uglyog/pact (Beth, 13 minutes ago)
* 45430b1 - Whoops; use actual latest ruby p484, not p448 (Daniel Heath, 18 hours ago)
* 9a999ad - Specify a non-compromised version of ruby in .ruby-version (Daniel Heath, 18 hours ago)
* bb8d4d9 - Merge pull request #13 from stevenfarlie/update-awesome-print (Ronald Holshausen, 20 hours ago)
* 6582d15 - Allow newer awesome_print versions (Steven Farlie, 2 days ago)

### 1.0.23 (29 November 2013)

* a978654 - Improving the display of verification errors in the consumer project. (Beth Skurrie, 2 days ago)

### 1.0.22 (25 November 2013)

* f742833 - Updating README (Beth Skurrie, 36 seconds ago)
* ec0d9e2 - Refactor config_ru lambda (Beth Skurrie, 8 minutes ago)
* 5cb5702 - Added code to use app in config.ru if non is specified as per https://github.com/uglyog/pact/issues/9 (Beth Skurrie, 10 minutes ago)

### 1.0.21 (25 November 2013)

* f810795 - add jruby 2.0 to travis (Ronald Holshausen, 4 days ago)
* 65e0ea2 - dropped rbx as it was failing in a crazy way (Ronald Holshausen, 4 days ago)
* 1403594 - added ruby 2 to travis (Ronald Holshausen, 4 days ago)
* c72662e - rbx requires the rubysl-thwait gem (Ronald Holshausen, 4 days ago)
* 70745dc - require webrick (Ronald Holshausen, 4 days ago)
* 43110ad - removed thin as a runtime dependancy as it is not supported on all rubies (Ronald Holshausen, 4 days ago)
* d4eea58 - dropped all rubies < 1.9.3 (Ronald Holshausen, 4 days ago)
* cb312b5 - removed debugger as a development dependancy as it will not build on all rubies (Ronald Holshausen, 4 days ago)
* 872c649 - removed ruby 1.9.2 as active support does not active support it (Ronald Holshausen, 4 days ago)
* 1930269 - added travis CI for the uglyog repo (Ronald Holshausen, 4 days ago)
* 7750ee1 - added travis build status image (Ronald Holshausen, 5 days ago)
* 9f72b31 - added travis build status image (Ronald Holshausen, 5 days ago)
* d9be65b - Added .travis.yml (Beth, 6 days ago)
* e7a7e7b - Refactoring pact_helper loading. (Beth, 6 days ago)
* 0224d36 - Only log loading of pact_helper once https://github.com/uglyog/pact/issues/8 (Beth, 6 days ago)
* 0123207 - Updating gemspec description (Beth, 7 days ago)
* 697cbdc - Updating README.md (Beth, 4 weeks ago)
* ca79968 - Investigating Rack and HTTP headers in response to https://github.com/uglyog/pact/issues/6. Updated tests and README with info on multiple headers with the same name. (B
* 01f0b9a - Updating README (Beth, 4 weeks ago)

### 1.0.20 (29 October 2013)

  * c03f34f - Fixed the pretty generation of JSON when active support is loaded. It is both a sad and a happy moment. (Beth, 7 minutes ago)

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
