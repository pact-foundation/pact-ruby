Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)'

### 1.3.1 (11 August 2014)

* 3432259 - Fixed 'pact:verify broken with rspec-core 3.0.3'  https://github.com/realestate-com-au/pact/issues/44 (bethesque, Mon Aug 11 10:14:42 2014 +1000)
* e2e8eff - Deleted documentation that has been moved to the wiki (bethesque, Thu Jul 24 15:20:07 2014 +1000)
* bcc3143 - Fixing bug 'Method case should not matter when matching requests' https://github.com/realestate-com-au/pact/issues/41 (bethesque, Tue Jul 22 16:51:48 2014 +1000)
* d4bfab9 - Adding ability to configure DiffFormatter based on content-type (bethesque, Mon Jun 23 21:22:47 2014 +1000)
* eb330ea - Ensured content-type header works in a case insensitive way when looking up the right differ (bethesque, Mon Jun 23 17:23:04 2014 +1000)
* 2733e8e - Made header matching case insensitive for requests. Fixing issue https://github.com/realestate-com-au/pact/issues/20 (bethesque, Mon May 26 19:15:48 2014 +1000)
* 2b8355d - Added nicer error message for scenario when a service provider app has not been configured, and there is no config.ru (bethesque, Mon Jun 23 09:42:18 2014 +1000)
* 1e774bb - Defaulting to TextDiffer if response has no content-type (bethesque, Sat Jun 21 10:34:44 2014 +1000)
* 863b093 - Added support for documents without content types (bethesque, Sat Jun 21 10:32:08 2014 +1000)
* b21900b - Enabling differs to be configured based on Content-Type (bethesque, Sat Jun 21 10:21:37 2014 +1000)
* 527b5d5 - Modified after hook to only write pacts when one or more 'pact => true' examples have run (bethesque, Wed Jun 18 15:15:55 2014 +1000)

### 1.3.0 (18 June 2014)

* ea79190 - Modifying (cough*monkeypatching*cough) RSpec::Core::BacktraceFormatter as RSpec3 has some hardcoded exclusion patterns that result in *all* the backtrace lines being shown when pact:verify fails. (bethesque, Wed Jun 18 13:02:38 2014 +1000)
* 0fd2bb2 - Support objects that return valid URI strings through to_s (Gabriel Rotbart, Fri Jun 13 14:34:03 2014 +1000)

### 1.2.1.rc2 (13 June 2014)

* d805f35 - Ensuring the pact RSpec formatter works for both rspec 2 and rspec 3 (Beth, Fri Jun 13 16:27:01 2014 +1000)
* 1669d46 - Fix require for sample app to work without munging LOAD_PATH (Daniel Heath, Fri Jun 13 15:50:03 2014 +1000)

### 1.2.1.rc1 (13 June 2014)

* b8d1586 - Making RSpec::Mocks::ExampleMethods available in set_up and tear_down, so the allow method is available without configuration.
* 5ec17aa - Updating code to work with RSpec 3 (bethesque, Wed Jun 11 22:09:30 2014 +1000)
* 1227b71 - RESTifying the endpoints on the mock server (bethesque, Tue Jun 10 10:06:33 2014 +1000)
* 57409b5 - Moved pact writing into mock server, so the mock server can be reused by consumer libraries in other languages. (bethesque, Thu Jun

### 1.1.1 (3 June 2014)

* 503a3f4 - The pact verify executable now adds lib to the load path before requiring the pact_helper. (bethesque, Tue Jun 3 09:26:46 2014 +1000)
* f62622e - Fixed output when a Pact::Term is expected in a response header. (bethesque, Tue Jun 3 07:18:52 2014 +1000)
* bb5ae47 - Updated pact spec runner, matchers and pact verification code to work with both rspec 2.14 and 2.99. It's not pretty, but it does the job
* c150e35 - Created a "pact verify" executable and change the rake task to invoke it to avoid the problem of cross contamination of requires (eg. wit
* d981ab7 - Added "actual" response to pact:verify failure message to make it easier to identify the reason for failure. (bethesque, Tue May 20 21:49:06 2
* a18787d - Added pact specification compliance spec. WIP. (bethesque, Tue May 20 21:48:10 2014 +1000)
* 2d52356 - Adding back HTTP method and path to pact verify output, as it is otherwise impossible to tell from the output what the actual request was
* 674d8c9 - Addd query to request.method_and_path (bethesque, Sat May 17 16:23:20 2014 +1000)

### 1.1.0 (5 May 2014)

### 1.1.0.rc5 (5 May 2014)
  * dc9855b - Downcasing HTTP methods before sending call to RSpec::Test::Methods because pact-jvm is using an upcase method https://github.com/DiUS/pact-jvm/issues/34 (bethesque, Mon May 5 12:29:51 2014 +1000)
  * ddd4677 - Fixed problem of Pact::Terms displaying inside diff output by unpacking all the regular expressions before the diff is calculated (bethesque, Mon May 5 12:16:25 2014 +1000)

### 1.1.0.rc4 (1 May 2014)

  * 5e1b78d - Display / in logs when path is empty https://github.com/realestate-com-au/pact/issues/14 (bethesque, Thu May 1 22:09:29 2014 +1000)
  * 01c5414 - Fixing doc generation bug where Pact::Terms were being displayed https://github.com/realestate-com-au/pact/issues/13 (bethesque, Thu May 1 21:41:11 2014 +1000)
  * 292a14b - Cleaning doc dir before generating new docs as per https://github.com/realestate-com-au/pact/issues/11 (bethesque, Tue Apr 29 12:44:47 2014 +1000)
  * 73c15dd - Changed default doc_dir to ./doc/pacts as per https://github.com/realestate-com-au/pact/issues/12 (bethesque, Tue Apr 29 12:33:57 2014 +1000)
  * 78ca78c - Fixed bug where log_dir was being ignored when set to a non default value (bethesque, Tue Apr 29 07:50:32 2014 +1000)

### 1.1.0.rc3 (28 April 2014)

  * 41fa409 - Cleaned up consumer after spec failure message (bethesque, Sun Apr 27 22:18:03 2014 +1000)
  * 8593fa9 - Updated zoo-app example (bethesque, Sun Apr 27 20:54:51 2014 +1000)
  * 716e3a8 - Added standalone consumer spec and spec for VerificationGet (bethesque, Thu Apr 24 10:15:17 2014 +1000)
  * c0f9bc6 - Copied RSpec::Expectations::Differ to Pact::Matchers::Differ - safer than trying to override behaviour (bethesque, Thu Apr 24 09:17:58 2014 +
  * 0eeb032 - Changing default diff_formatter to unix (bethesque, Thu Apr 24 08:19:15 2014 +1000)
  * ace5d4d - Update README.md (bethesque, Wed Apr 23 20:59:24 2014 +1000)
  * 24efef6 - Update configuration.md (bethesque, Wed Apr 23 20:51:00 2014 +1000)
  * 2d862b7 - Update best-practices.md (bethesque, Wed Apr 23 07:33:01 2014 +1000)
  * ff8dfd2 - Updated doco (bethesque, Tue Apr 22 21:45:17 2014 +1000)
  * 88e4572 - Moving best practices into its own file (bethesque, Tue Apr 22 21:28:36 2014 +1000)
  * 5a3b92c - Moving provider state documentation out of main README into it's own file. (bethesque, Tue Apr 22 19:59:48 2014 +1000)
  * 1d568c4 - Updated configuration documentation (bethesque, Tue Apr 22 13:06:47 2014 +1000)
  * be1412e - Added configuration documentation (bethesque, Tue Apr 22 13:04:33 2014 +1000)
  * 9f9d178 - Added HAL raq (bethesque, Tue Apr 22 12:51:42 2014 +1000)
  * d9b6479 - Renamed ListOfPathsFormatter to ListDiffFormatter (bethesque, Tue Apr 22 12:48:57 2014 +1000)
  * 6b82402 - Renamed NestedJsonDiffFormatter to EmbeddedDiffFormatter (bethesque, Tue Apr 22 12:45:50 2014 +1000)
  * def8afd - Merge branch 'master' into release-1.1.0 (bethesque, Tue Apr 22 09:13:41 2014 +1000)
  * 789a471 - Added generated docs to zoo-app (bethesque, Tue Apr 15 17:20:08 2014 +1000)
  * f5da7ab - Improved header match failure message (bethesque, Tue Apr 15 09:39:12 2014 +1000)
  * 1179489 - Stopped RSpec turning failure message lines that should be white to red (bethesque, Mon Apr 14 21:41:55 2014 +1000)
  * ddad510 - Added type and regexp matching output to ListOfPathsFormatter (bethesque, Mon Apr 14 13:43:08 2014 +1000)
  * b007248 - Added class based matching output to plus_and_minus diff formatter (bethesque, Sat Apr 12 21:20:43 2014 +1000)
  * f7910a1 - Swapped colored for term-ansicolor, as the colored mixins clash with other gems (bethesque, Sat Apr 12 20:37:57 2014 +1000)
  * 93bfbdb - Fixing failing tests caused by JRuby inserting a blank line between the braces of an empty hash. Moved ActiveSupportSupport into shared
  * da16f95 - Added after hook to allow customisation of Doc::Generator (bethesque, Sat Apr 12 18:46:04 2014 +1000)
  * 85a6fe3 - Breaking up configuration files into separate files (bethesque, Sat Apr 12 11:21:56 2014 +1000)
  * 7515360 - Merge branch 'doc' into release-1.1.0 (bethesque, Sat Apr 12 10:37:51 2014 +1000)
  * 1200481 - Removed pact_gem key from pact fixtures (bethesque, Wed Apr 9 22:19:02 2014 +1000)
  * 72d791b - Ordered rendering of keys in markdown (bethesque, Wed Apr 9 22:15:01 2014 +1000)
  * 000b223 - Hiding headers and body from docs when they are empty (bethesque, Wed Apr 9 21:46:02 2014 +1000)
  * 7f6ed91 - Changing request key ordering so it makes more sense when reading it (bethesque, Wed Apr 9 21:45:31 2014 +1000)
  * 65054a8 - Added index rendering (bethesque, Wed Apr 9 19:38:55 2014 +1000)
  * 9426565 - Refactoring generation code. Fixed rendering of interaction in markdown when ActiveSupport is loaded (bethesque, Wed Apr 9 18:20:53 2014 +100
  * 73d0dbf - WIP refactoring generator code (bethesque, Wed Apr 9 17:03:14 2014 +1000)
  * 7d1d07b - WIP tests and refactor doc generator (bethesque, Wed Apr 9 13:36:46 2014 +1000)

### 1.0.39 (8 April 2014)

* a034ab6 - Oh ActiveSupport, why??? Fixing to_json for difference indicators (bethesque, Mon Apr 7 17:26:10 2014 +1000)
  * 1c7fa0d - Update faq.md (bethesque, Thu Apr 3 09:58:02 2014 +1100)
  * 8cf5b57 - Update README.md (bethesque, Thu Mar 27 13:38:13 2014 +1100)
  * 1c5fde9 - Preloading app before suite in pact:verify Ensures consistent behaviour between the first before/after each hooks (bethesque, Thu Mar 27 10:0

### 1.0.38 (24 March 2014)

* 7fb2bc3 - Improved readability of pact:verify specs by removing pactfile name and request details from output (bethesque, 23 hours ago)
* ff1de3c - Improving readability of error messages when pact:verify fails (bethesque, 23 hours ago)
* 8a08abf - Removed the last RSpec private API usage. I think. (bethesque, 33 hours ago)
* 6a0be58 - Reducing even more use of RSpec private APIs (bethesque, 33 hours ago)
* e1fd51c - Reducing use of RSpec private APIs (bethesque, 34 hours ago)
* 587cb90 - Replaced rspec 'commands to rerun failed examples' with Pact specific commands to rerun failed interactions (bethesque, 2 days ago)

### 1.0.37 (19 March 2014)

* 0e8b80e - Cleaned up pact:verify rspec matcher lines so the output makes more sense to the reader (bethesque, 3 minutes ago)
* 03e5ea3 - Fixed config.include to ensure ordering of config and provider state declarations does not matter (bethesque, 20 minutes ago)

### 1.0.36 (19 March 2014)

* c28de11 - Added patch level to pactSpecificationVersion (bethesque, 37 seconds ago)

### 1.0.35 (19 March 2014)

* 44c6806 - Updated README.md with new set_up and tear_down instructions (bethesque, 29 seconds ago)
* 3c426b7 - Added set_up/tear_down to manage base provider state.
* 697a5be - Changed default logging level to DEBUG (bethesque, 32 minutes ago)
* 48483b2 - Fixed JSON serialisation of matcher results with active_support loaded (bethesque, 49 minutes ago)
* 0be5b01 - Updated description of Shokkenki (bethesque, 7 hours ago)

### 1.0.34 (17 March 2014)

* 6c923f4 - In the pact file, replaced $.metadata.pact_gem.version with $.metadata.pactSpecificationVersion as the gem version is irrelevant - it is the serialization format that matters, and that hasn't changed yet. Also, recording the gem version creates extra changes to be committed when the gem is upgraded, and is meaningless for pacts generated/verified by the JVM code. (Beth Skurrie, 5 minutes ago)

### 1.0.33 (13 March 2014)

* 49456cc - Added the ability to configure modules that can be used in provider state definitions (Beth Skurrie, 75

### 1.0.32 (11 March 2014)

* 5a7cc36 - Adding as_json methods for diff indicators (index/key not found/unexpected) (Beth Skurrie, 2 days ago)

### 1.0.31 (11 March 2013)

* e109722 - Fixed output of pact:verify failures when active_support is loaded (Beth Skurrie, 2 days ago)
* 90d62fb - Returning a json error with a backtrace when a StandardError occurs in the MockServer, in an at
* 044cc71 - Using PATH_INFO instead of REQUEST_PATH as recommended by Rack spec - REQUEST_PATH isn't offici
* e40d785 - Using webrick instead of thin to run pact service as thin does not work on jruby (Beth Skurrie, 9 days
* ec732de - use puma instead of then as that gem works on JRuby (Ronald Holshausen, 9 days ago)
* 8720da9 - removed ruby head from travis config as event machine gem is not building on it (Ronald Holshau
* d46f712 - removed JRuby from Travis.ci config as JRubests can now use the pact-jvm (Ronald Holshausen, 9
* a1b0796 - Merge pull request #5 from jessedc/patch-1 (Ronald Holshausen, 9 days ago)
* bd1f9ed - Update link to DiUS repository. (Jesse Collis, 9 days ago)
* 5cbe40b - Added Shokkenki link and a Google form link. (Beth Skurrie, 2 weeks ago)
* 284481e - Updating example spec (Beth Skurrie, 2 weeks ago)
* 346cd57 - Fixed SomethingModel example code. (Beth Skurrie, 2 weeks ago)
* ac37919 - Adding terminology and 'reasons why pact is good' (Beth Skurrie, 10 weeks ago)
* 49923c6 - Added FAQ about non ruby codebases. (Beth Skurrie, 2 months ago)
* cba6409 - Splitting up the REAME into more manageable chunks (Beth Skurrie, 2 months ago)
* 115e786 - Added diagram to help explain testing with pact (Beth Skurrie, 2 months ago)
* 8962afe - Using Pact::DSL for provider states (Beth Skurrie, 3 months ago)
* 77d087f - Added helper method for mock service base URL (Beth Skurrie, 3 months ago)
* 0e7e249 - Updated example app with latest good practise pact code (Beth Skurrie, 3 months ago)
* bf225c6 - Added documentation for standalone mock server (Beth Skurrie, 3 months ago)

### 1.0.30 (17 December 2013)

* c8278c7 - Added thin into the gemspec for pact standalone mock server (Beth Skurrie, 2 minutes ago)

### 1.0.29 (12 December 2013)

* 8ffde69 - Providing before :all like functionality using before :each to get the dual benefits of faster tests and the ability to use stubbing (Beth Skurrie, 53 seconds ago)
* d30a78b - Added test to ensure rspec stubbing always works (Beth Skurrie, 15 hours ago)

### 1.0.28 (11 December 2013)

* 24f9ea0 - Changed provider set up and tear down back to running in before :each, as rspec stubbing is not supported in before :all (Beth Skurrie, 15 seconds ago)
* 825e787 - Fixing failing tests (Beth Skurrie, 4 hours ago)
* fb6a1c8 - Moving ProviderState collection into its own class (Beth Skurrie, 6 hours ago)

### 1.0.27 (10 December 2013)

* 388fc7b - Changing provider set up and tear down to run before :all rather than before :each (Beth Skurrie, 13 minutes ago)
* 06b5626 - Updating TODO list in the README. (Beth Skurrie, 25 hours ago)
* 823f306 - Update README.md (Beth Skurrie, 32 hours ago)
* 7d96017 - Improving layout of text diff message (Beth Skurrie, 2 days ago)
* 9c88c3a - Working on a new way to display the diff between an expected and actual request/response (Beth Skurrie, 2 days ago)
* ff2c448 - Added a Difference class instead of a hash with :expected and :actual (Beth Skurrie, 2 days ago)
* b34457c - Moved all missing provider state templates into the one message at the end of the test so it's easier to digest and can be copied directly into a file. (Beth Skurrie, 2
* 1729887 - Moving ProviderStateProxy on to Pact World (Beth Skurrie, 3 days ago)
* c53cb4d - Starting to add Pact::World (Beth Skurrie, 4 days ago)
* f7af9e2 - Recording missing provider states (Beth Skurrie, 4 days ago)
* 4caa171 - Starting work on ProviderStateProxy - intent is for it to record missing and unused states to report at the end of the pact:verify (Beth Skurrie, 4 days ago)

### 1.0.26 (5 December 2013)

* e4be654 - BEST COMMIT TO PACT EVER since the introduction of pact:verify. Got rid of the horrific backtraces. (Beth Skurrie, 5 hours ago)
* 2810db7 - Updated README to point to realestate-com-au travis CI build (Ronald Holshausen, 28 hours ago)
* bfa357a - Update README.md (Beth Skurrie, 30 hours ago)

### 1.0.25 (4 December 2013)

* 20dd5fa - Updated the homepage in gemspec (Beth Skurrie, 4 minutes ago)

### 1.0.24 (4 December 2013)

* fd30d36 - Merge branch 'master' of github.com:uglyog/pact (Beth Skurrie, 13 minutes ago)
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
* d9be65b - Added .travis.yml (Beth Skurrie, 6 days ago)
* e7a7e7b - Refactoring pact_helper loading. (Beth Skurrie, 6 days ago)
* 0224d36 - Only log loading of pact_helper once https://github.com/uglyog/pact/issues/8 (Beth Skurrie, 6 days ago)
* 0123207 - Updating gemspec description (Beth Skurrie, 7 days ago)
* 697cbdc - Updating README.md (Beth Skurrie, 4 weeks ago)
* ca79968 - Investigating Rack and HTTP headers in response to https://github.com/uglyog/pact/issues/6. Updated tests and README with info on multiple headers with the same name. (B
* 01f0b9a - Updating README (Beth Skurrie, 4 weeks ago)

### 1.0.20 (29 October 2013)

  * c03f34f - Fixed the pretty generation of JSON when active support is loaded. It is both a sad and a happy moment. (Beth Skurrie, 7 minutes ago)

### 1.0.19 (29 October 2013)
 * e4b990e - Gsub '-' to '_' in request headers. (Sebastian Glazebrook, 4 minutes ago)
 * 52ac8f8 - Added documentation for PACT_DESCRIPTION and PACT_PROVIDER_STATE to README. (Beth Skurrie, 13 hours ago)

### 1.0.18 (29 October 2013)

 * f2892d4 - Fixed bug where an exception is thrown when a key is not found and is attempted to be matched to a regexp (Beth Skurrie, 60 seconds ago)

### 1.0.17 (29 October 2013)

 * 74bdf09 - Added missing require for Regexp json deserialisation (Beth Skurrie, 3 minutes ago)
 * d69482e - Removed JsonWarning for ActiveSupport JSON. (Beth Skurrie, 3 hours ago)
 * 5f72720 - Fixing ALL THE REGEXPS that ActiveSupport JSON broke. The pact gem should now serialise and deserialise its own JSON properly even when ActiveSupport is loaded by the call
 * c3e6430 - Added config.ru parsing to best practices. (Beth Skurrie, 9 hours ago)
 * ae3a70f - DRYing up pact file reading code. (Beth Skurrie, 11 hours ago)
 * dc83557 - Fixing VerificationTask spec (Beth Skurrie, 11 hours ago)
 * bae379c - Added consumer name, provider name and request method to output of rspec. (Beth Skurrie, 12 hours ago)
 * 89c2620 - Adding spec filtering using PACT_DESCRIPTION and PACT_PROVIDER_STATE to pact:verify and pact:verify:at tasks. (Beth Skurrie, 28 hours ago)
 * 7ab43a9 - Adding puts to show when pact:verify specs are being filtered. (Beth Skurrie, 28 hours ago)

### 1.0.16 (28 October 2013)

* ce0d102 - Fixing specs after adding pact_helper and changing producer_state to provider_state. There is no producer here any more! Naughty producer. (Beth Skurrie, 71 seconds ago)
* 90f7203 - Fixing bug where RSpec world was not cleared between pact:verify tasks. (Beth Skurrie, 16 minutes ago)
* b323336 - Fixed bug where pact_helper option was not being passed into the PactSpecRunner from the task configuration (Beth Skurrie, 4 hours ago)
* b1e78f5 - Added environment variable support. (Sergei Matheson, 3 days ago)
* 2b9f39a - Allow match criteria to be passed through to pact:verify tasks on command line (Sergei Matheson, 3 days ago)
* 2241f29 - Un-deprecating the support_file functionality after having discovered a valid use for it (project that contains two rack apps that have a pact with each other). Renamed op
* c94fc13 - Updating example provider state (Beth Skurrie, 4 days ago)
* 6900f39 - Updating README with better client class example (Beth Skurrie, 5 days ago)
* e41f755 - Update README.md (bskurrie, 5 days ago)
* 2abcce4 - Adding to pact best practices. (Beth Skurrie, 5 days ago)

### 1.0.15 (22 October 2013)

 * 6800a58 - Updating README with latest TODOs (Beth Skurrie, 2 hours ago)
 * 99a6827 - Improving logging in pact:verify. Fixing bug where Pact log level was ignored. (Beth Skurrie, 3 hours ago)
 * 5434f54 - Updating README with best practice and information on the :pact => :verify metadata. (Beth Skurrie, 4 hours ago)
 * 16dd2be - Adding :pact => :verify to pact:verify rspec examples for https://github.com/uglyog/pact/issues/3 (Beth Skurrie, 5 hours ago)

### 1.0.14 (22 October 2013)

* 406e746 - Added a template for the provider state when no provider state is found (Beth Skurrie, 9 minutes ago)
* 1f58be8 - Adding error messages when set_up or tear_down are not defined, and added no_op as a way to avoid having to use an empty set_up block when there is no data to set up (Beth)
* 78d3999 - Merge pull request #2 from stuliston/json_warning_minor_refactor (Ronald Holshausen, 18 hours ago)
* be4a466 - Altering JsonWarning so that it only warns once. Added spec to confirm that's the case. (Stuart Liston, 21 hours ago)
* 3b11b42 - Fixing the issue where a method defined in global scope could not be accessed in the DSL delegation code (Beth Skurrie, 11 days ago)

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
