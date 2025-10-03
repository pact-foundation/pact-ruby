<a name="v1.66.2"></a>
### v1.66.2 (2025-10-03)

#### Bug Fixes

* **spec**
  * update rspec keyword vs arg changes https://github.com/rspec/rspec-mocks/pull/1473	 ([c1c17fc](/../../commit/c1c17fc))

* correct generators import and update specs	 ([d025342](/../../commit/d025342))
* example/animal-service/Gemfile to reduce vulnerabilities	 ([4dfb3f5](/../../commit/4dfb3f5))
* example/animal-service/Gemfile to reduce vulnerabilities	 ([3d8fa31](/../../commit/3d8fa31))
* example/zoo-app/Gemfile to reduce vulnerabilities	 ([5ff8945](/../../commit/5ff8945))

<a name="v1.66.1"></a>
### v1.66.1 (2025-01-20)

#### Bug Fixes

* HTTP_HOST headers for sinatra 4.x	 ([173bfb7](/../../commit/173bfb7))

<a name="v1.66.0"></a>
### v1.66.0 (2024-11-29)

#### Features

* **generators**
  * Add more generators as per spec	 ([f55adf1](/../../commit/f55adf1))
  * Pass context and add ProviderState generator	 ([7a1cf3b](/../../commit/7a1cf3b))

#### Bug Fixes

* add HTTPS_HOST header if invoking a Sinatra app	 ([ed44189](/../../commit/ed44189))
* example/animal-service/Gemfile to reduce vulnerabilities	 ([981ebee](/../../commit/981ebee))

<a name="v1.65.3"></a>
### v1.65.3 (2024-10-23)

#### Bug Fixes

* **test**
  * explicitly require ostruct as non stdlib in ruby 3.5.x	 ([c9a8525](/../../commit/c9a8525))

<a name="v1.65.2"></a>
### v1.65.2 (2024-09-26)

<a name="v1.65.1"></a>
### v1.65.1 (2024-08-08)

#### Bug Fixes

* set color codes even on dumb terms (prev behaviour)	 ([4f01bc9](/../../commit/4f01bc9))
* use .empty? in handling_no_pacts_found	 ([43bce74](/../../commit/43bce74))

<a name="v1.65.0"></a>
### v1.65.0 (2024-08-06)

#### Features

* support app_version_branch in MessageProviderDSL	 ([1653128](/../../commit/1653128))
* allow setting fail_if_no_pacts_found in honours_pacts_from_pact_broker	 ([f0f142e](/../../commit/f0f142e))

#### Bug Fixes

* handle case in no_pacts_found - undefined method empty? for nil	 ([0145d2d](/../../commit/0145d2d))
* remove unused ConsumerContractBuilder contract_details accessor	 ([fb5488e](/../../commit/fb5488e))
* example/animal-service/Gemfile to reduce vulnerabilities	 ([2bbefe2](/../../commit/2bbefe2))
* example/zoo-app/Gemfile to reduce vulnerabilities	 ([e10f914](/../../commit/e10f914))
* example/animal-service/Gemfile to reduce vulnerabilities	 ([7560918](/../../commit/7560918))
* example/zoo-app/Gemfile to reduce vulnerabilities	 ([b4cbe85](/../../commit/b4cbe85))
* example/animal-service/Gemfile to reduce vulnerabilities	 ([4028087](/../../commit/4028087))
* ConsumerContractBuilder exposing incorrect field	 ([c805c3e](/../../commit/c805c3e))

* **test**
  * alias Rack/Rackup WEBrick handler in x509 test for backwards compat	 ([cc77498](/../../commit/cc77498))

<a name="v1.64.0"></a>
### v1.64.0 (2023-11-09)

#### Features

* support x509 certs in HTTP Client (#298)	 ([3ed5680](/../../commit/3ed5680))

* **CI**
  * use setup-ruby's bundle installer and cache (#275)	 ([f5621b6](/../../commit/f5621b6))

#### Bug Fixes

* assert provider retrieved successfully before using link	 ([0af0691](/../../commit/0af0691))
* update call to Rack::Builder.parse_file for rack 3	 ([652047c](/../../commit/652047c))
* example/zoo-app/Gemfile to reduce vulnerabilities	 ([b4ca8cb](/../../commit/b4ca8cb))
* example/animal-service/Gemfile to reduce vulnerabilities	 ([7ad2073](/../../commit/7ad2073))
* example/zoo-app/Gemfile to reduce vulnerabilities	 ([dd417fd](/../../commit/dd417fd))
* example/animal-service/Gemfile to reduce vulnerabilities (#281)	 ([4ea07cd](/../../commit/4ea07cd))

<a name="v1.63.0"></a>
### v1.63.0 (2022-09-28)

#### Features

* relax rack-test dependency to allow version 2 (#270)	 ([a619deb](/../../commit/a619deb))
* only print metrics warning once per thread	 ([91da38f](/../../commit/91da38f))
* provide configuration for build url to be published in verification results (#252)	 ([ce1c9bc](/../../commit/ce1c9bc))

#### Bug Fixes

* example/animal-service/Gemfile to reduce vulnerabilities (#263)	 ([8f3b732](/../../commit/8f3b732))
* Fixup ruby warnings (#262)	 ([3640593](/../../commit/3640593))

<a name="v1.62.0"></a>
### v1.62.0 (2022-02-21)

#### Features

* add telemetry (#256)	 ([4497ee9](/../../commit/4497ee9))

<a name="v1.61.0"></a>
### v1.61.0 (2021-12-16)

#### Features

* support description of matching_branch and matching_tag consumer version selectors	 ([8e8bb22](/../../commit/8e8bb22))

#### Bug Fixes

* pass through includePendingStatus to the 'pacts for verification' API when it is false	 ([f0e37a4](/../../commit/f0e37a4))

<a name="v1.60.0"></a>
### v1.60.0 (2021-10-01)

#### Features

* allow SSL verification to be disabled in the HAL client by setting the environment variable PACT_DISABLE_SSL_VERIFICATION=true	 ([ce07d32](/../../commit/ce07d32))

<a name="v1.59.0"></a>
### v1.59.0 (2021-09-07)

#### Features

* update descriptions for new consumer version selectors	 ([0471397](/../../commit/0471397))

<a name="v1.58.0"></a>
### v1.58.0 (2021-09-01)

#### Features

* support publishing verification results with a version branch	 ([da2facf](/../../commit/da2facf))

#### Bug Fixes

* gracefully handle display of username that causes InvalidComponentError to be raised when composing a URI	 ([cecb98f](/../../commit/cecb98f))

<a name="v1.57.0"></a>
### v1.57.0 (2021-01-27)

#### Features

* allow verbose flag to be set when publishing verifications	 ([9238e4c](/../../commit/9238e4c))

<a name="v1.56.0"></a>
### v1.56.0 (2021-01-22)

#### Features

* catch and log error during help text generation	 ([182a7cd](/../../commit/182a7cd))

<a name="v1.55.7"></a>
### v1.55.7 (2020-11-25)

#### Bug Fixes

* add consumer name to the selection description (#229)	 ([5127036](/../../commit/5127036))

<a name="v1.55.6"></a>
### v1.55.6 (2020-11-06)

#### Bug Fixes

* require rspec now that pact-support does not depend on it	 ([5b5c27c](/../../commit/5b5c27c))

<a name="v1.55.5"></a>
### v1.55.5 (2020-10-12)

#### Bug Fixes

* **security**
  * hide personal access token given in uri (#225)	 ([f6db12d](/../../commit/f6db12d))

<a name="v1.55.4"></a>
### v1.55.4 (2020-10-09)

#### Bug Fixes

* add back missing output describing the interactions filter	 ([1a2d7c1](/../../commit/1a2d7c1))

<a name="v1.55.3"></a>
### v1.55.3 (2020-09-28)

#### Bug Fixes

* correct logic for determining if all interactions for a pact have been verified	 ([c4f968e](/../../commit/c4f968e))
* de-duplicate re-run commands	 ([0813498](/../../commit/0813498))

<a name="v1.55.2"></a>
### v1.55.2 (2020-09-26)

#### Bug Fixes

* correctly calculate exit code when a mix of pending and non pending pacts are verified	 ([533faa1](/../../commit/533faa1))

<a name="v1.55.1"></a>
### v1.55.1 (2020-09-26)

#### Bug Fixes

* remove accidentally committed debug logging	 ([081423e](/../../commit/081423e))

<a name="v1.55.0"></a>
### v1.55.0 (2020-09-26)

#### Features

* add consumer_version_selectors to pact verification DSL, and convert consumer_version_tags to selectors	 ([39e6c4a](/../../commit/39e6c4a))
* allow verification task to set just a pact_helper without a URI	 ([303077d](/../../commit/303077d))
* split pending and failed rerun commands into separate sections	 ([f839391](/../../commit/f839391))
* update output during verification so the pact info shows before the describe blocks of the pact that is being verified	 ([15ec231](/../../commit/15ec231))

<a name="v1.54.0"></a>
### v1.54.0 (2020-09-12)

#### Features

* use pb relation in preference to beta relation when fetching pacts for verification	 ([7563fcf](/../../commit/7563fcf))
* allow include_wip_pacts_since to use a Date, DateTime or Time	 ([dd35366](/../../commit/dd35366))
* add support for include_wip_pacts_since	 ([f2247b8](/../../commit/f2247b8))

<a name="v1.53.0"></a>
### v1.53.0 (2020-09-11)

#### Features

* add support for the enable_pending flag	 ([16866f4](/../../commit/16866f4))

<a name="v1.52.0"></a>
### v1.52.0 (2020-09-10)

#### Features

* support webdav http methods	 ([fa1d712](/../../commit/fa1d712))

<a name="v1.51.1"></a>
### v1.51.1 (2020-08-12)

#### Bug Fixes

* update thor dependency (#218)	 ([bf3ce69](/../../commit/bf3ce69))
* bump rake dependency per CVE-2020-8130 (#219)	 ([09feaa6](/../../commit/09feaa6))

<a name="v1.51.0"></a>
### v1.51.0 (2020-06-24)


#### Features

* allow individual interactions to be re-run by setting PACT_BROKER_INTERACTION_ID	 ([a586d80](/../../commit/a586d80))


<a name="v1.50.1"></a>
### v1.50.1 (2020-06-15)


#### Bug Fixes

* fix integration with pact-message-ruby (#216)	 ([d2da13e](/../../commit/d2da13e))


<a name="v1.50.0"></a>
### v1.50.0 (2020-04-25)


#### Features

* Set expected interactions on mock service but without writing them to pact file (#210)	 ([14f5327](/../../commit/14f5327))


<a name="v1.49.3"></a>
### v1.49.3 (2020-04-22)


#### Bug Fixes

* pact selection verification options logging	 ([9ff59f4](/../../commit/9ff59f4))


<a name="v1.49.2"></a>
### v1.49.2 (2020-04-08)


#### Bug Fixes

* json parser error for top level JSON values	 ([dafbc35](/../../commit/dafbc35))


<a name="v1.49.1"></a>
### v1.49.1 (2020-03-21)


#### Bug Fixes

* ensure diff is included in the json output	 ([0bd9753](/../../commit/0bd9753))
* ensure the presence of basic auth credentials does not cause an error when displaying the path of a pact on the local filesystem	 ([f6a0b4d](/../../commit/f6a0b4d))


<a name="v1.49.0"></a>
### v1.49.0 (2020-02-18)


#### Features

* use environment variables PACT_BROKER_USERNAME and PACT_BROKER_PASSWORD when verifying a pact by URL, if the environment variables are present	 ([308f25d](/../../commit/308f25d))


<a name="v1.48.0"></a>
### v1.48.0 (2020-02-13)


#### Features

* use certificates from SSL_CERT_FILE and SSL_CERT_DIR environment variables in HTTP connections	 ([164912b](/../../commit/164912b))


<a name="v1.47.0"></a>
### v1.47.0 (2020-02-08)


#### Features

* update json formatter output	 ([376e47a](/../../commit/376e47a))
* add pact metadata to json formatter	 ([6c6ddb8](/../../commit/6c6ddb8))


<a name="v1.46.1"></a>
### v1.46.1 (2020-01-22)


#### Bug Fixes

* send output messages to the correct stream when using the XML formatter	 ([e768a33](/../../commit/e768a33))


<a name="v1.46.0"></a>
### v1.46.0 (2020-01-22)


#### Features

* expose full notice object in JSON output	 ([bdc2711](/../../commit/bdc2711))


#### Bug Fixes

* remove accidentally committed verbose: true	 ([498518c](/../../commit/498518c))


<a name="v1.45.0"></a>
### v1.45.0 (2020-01-21)


#### Features

* use custom json formatter when --format json is specified and send it straight to stdout or the configured file	 ([6c703a1](/../../commit/6c703a1))
* support pending pacts in json formatter	 ([2c0d20d](/../../commit/2c0d20d))


#### Bug Fixes

* show pending test output in yellow instead of red	 ([e8d4a55](/../../commit/e8d4a55))


<a name="v1.44.1"></a>
### v1.44.1 (2020-01-20)


#### Bug Fixes

* print notices from 'pacts for verification' response to indicate why pacts are included an/or pending	 ([b107348](/../../commit/b107348))


<a name="v1.44.0"></a>
### v1.44.0 (2020-01-16)


#### Features

* **message pact**
  * add DSL for configuring Message Pact verifications	 ([a5181b6](/../../commit/a5181b6))


<a name="v1.43.1"></a>
### v1.43.1 (2020-01-11)


#### Bug Fixes

* use configured credentials when fetching the diff with previous version	 ([b9deb09](/../../commit/b9deb09))
* use URI.open instead of Kernel.open	 ([7b3ea81](/../../commit/7b3ea81))


<a name="v1.43.0"></a>
### v1.43.0 (2020-01-11)


#### Features

* **verify**
  * allow includePendingStatus to be specified when fetching pacts	 ([1f5fc9c](/../../commit/1f5fc9c))


<a name="v1.42.3"></a>
### v1.42.3 (2019-11-15)


#### Bug Fixes

* **verify**
  * exit with status 0 if all pacts are in pending state	 ([2f7110b](/../../commit/2f7110b))


<a name="v1.42.2"></a>
### v1.42.2 (2019-11-09)


#### Bug Fixes

* remove missed &.	 ([be700d8](/../../commit/be700d8))


<a name="v1.42.1"></a>
### v1.42.1 (2019-11-09)


#### Bug Fixes

* can't use safe navigation operator because of Ruby 2.2 in Travelling Ruby for the pact-ruby-standalone	 ([3068ceb](/../../commit/3068ceb))


<a name="v1.42.0"></a>
### v1.42.0 (2019-09-26)


#### Features

* use new 'pacts for verification' endpoint to retrieve pacts (#199)	 ([55bb935](/../../commit/55bb935))


<a name="v1.41.2"></a>
### v1.41.2 (2019-09-10)


#### Bug Fixes

* **pact_helper_locator**
  * add 'test' dir to file patterns (#196)	 ([746883d](/../../commit/746883d))

* file upload spec	 ([0fe072c](/../../commit/0fe072c))


<a name="v1.41.1"></a>
### v1.41.1 (2019-09-04)


#### Bug Fixes

* use to_json instead of JSON.dump because it generates different JSON when used in conjuction with other libraries (eg. Oj)	 ([14566fb](/../../commit/14566fb))


<a name="v1.41.0"></a>
### v1.41.0 (2019-05-22)


#### Features

* redact Authorization header from HTTP client debug output	 ([c48c991](/../../commit/c48c991))


<a name="v1.40.0"></a>
### v1.40.0 (2019-02-22)


#### Features

* remove ruby 2.2 tests	 ([4a30791](/../../commit/4a30791))
* add support for bearer token	 ([297268d](/../../commit/297268d))


<a name="v1.39.0"></a>
### v1.39.0 (2019-02-21)


#### Features

* allow host of mock service to be specified	 ([de267bd](/../../commit/de267bd))


<a name="v1.38.0"></a>
### v1.38.0 (2019-02-11)


#### Features

* unlock rack-test dependency to allow version 1.1.0	 ([b0c40f6](/../../commit/b0c40f6))
* update http client code	 ([bba3a08](/../../commit/bba3a08))


<a name="v1.37.0"></a>
### v1.37.0 (2018-11-15)


#### Features

* **hal client**
  * ensure meaningful error is displayed when HTTP errors are returned	 ([9244c14](/../../commit/9244c14))


#### Bug Fixes

* correct url encoding for expanded HAL links	 ([4abfe7d](/../../commit/4abfe7d))


<a name="v1.36.2"></a>
### v1.36.2 (2018-10-22)


#### Bug Fixes

* always execute global and base states	 ([8317fe3](/../../commit/8317fe3))


<a name="v1.36.0"></a>
### v1.36.0 (2018-10-04)


#### Features

* **v3**
  * make provider state params available to set up and tear down blocks	 ([9593730](/../../commit/9593730))
  * support set up and tear down of multiple provider states	 ([cbad0be](/../../commit/cbad0be))


<a name="v1.34.0"></a>
### v1.34.0 (2018-09-06)


#### Features

* **verify**
  * add request customizer for pact-provider-verifier	 ([4ae0b58](/../../commit/4ae0b58))


#### Bug Fixes

* add missing require for net/http	 ([fe2ebb1](/../../commit/fe2ebb1))


<a name="v1.33.2"></a>
### v1.33.2 (2018-09-06)


#### Bug Fixes

* add missing requires for pact/errors	 ([0e01451](/../../commit/0e01451))


<a name="v1.33.1"></a>
### v1.33.1 (2018-08-28)


#### Features

* rename 'wip pacts' to 'pending pacts'	 ([6a46ebb](/../../commit/6a46ebb))

* **verify cli**
  * rename --wip to --ignore-failures	 ([8e2dffd](/../../commit/8e2dffd))


#### Bug Fixes

* correct version for dependency on pact-mock_service	 ([01c0df7](/../../commit/01c0df7))


<a name="v1.33.0"></a>
### v1.33.0 (2018-08-07)


#### Features

* update version of pact-mock_service	 ([25a04fb](/../../commit/25a04fb))
* add support for multipart/form requests	 ([7a16ab1](/../../commit/7a16ab1))


<a name="v1.32.0"></a>
### v1.32.0 (2018-07-25)


#### Features

* add actual pact message contents to results published to Pact Broker	 ([09e9d89](/../../commit/09e9d89))


<a name="v1.31.0"></a>
### v1.31.0 (2018-07-25)


#### Features

* publish beta format of individual interaction results to Pact Broker	 ([6742afa](/../../commit/6742afa))


<a name="v1.30.0"></a>
### v1.30.0 (2018-07-24)


#### Features

* raise error when an expected HAL relation cannot be found in a resource	 ([5db4134](/../../commit/5db4134))


<a name="v1.29.0"></a>
### v1.29.0 (2018-07-24)


#### Features

* return plain string URLs from Pact::PactBroker.fetch_pact_uris	 ([1aa1989](/../../commit/1aa1989))
* use beta:wip-provider-pacts rather than pb:wip-provider-pacts to fetch WIP pacts	 ([3bb0501](/../../commit/3bb0501))
* allow WIP pacts to be verified without causing the process to return an non zero exit code	 ([9e6de46](/../../commit/9e6de46))


#### Bug Fixes

* add missing require	 ([0aa2d2a](/../../commit/0aa2d2a))
* default pact specification version to 2	 ([917891a](/../../commit/917891a))


<a name="v1.28.0"></a>
### v1.28.0 (2018-06-24)


#### Features

* add logging to indicate which pacts are being fetched from the broker	 ([06fa615](/../../commit/06fa615))
* allow verbose http logging to be turned on when fetching pacts URLs from the broker	 ([436f3f2](/../../commit/436f3f2))
* allow pacts to be dynamically fetched from a pact broker by provider name and tags	 ([ef97898](/../../commit/ef97898))

#### Bug Fixes

* reverting safe navigation operator to chained calls.	 ([8194ed6](/../../commit/8194ed6))


<a name="v1.27.0"></a>
### v1.27.0 (2018-06-22)


#### Features

* log tagging to stdout when publishing verification results	 ([2387424](/../../commit/2387424))
* Dynamically retrieve pacts for a given provider	 ([5aca966](/../../commit/5aca966))


#### Bug Fixes

* correct request url in http client	 ([1fb22b6](/../../commit/1fb22b6))
* correctly escape expanded URL in the HAL client	 ([821238d](/../../commit/821238d))


<a name="v1.26.0"></a>
### v1.26.0 (2018-05-08)


#### Bug Fixes

* **message**
  * message body actual content should be 'contents'	 ([d0157b0](/../../commit/d0157b0))


<a name="v1.25.0"></a>
### v1.25.0 (2018-05-07)


#### Bug Fixes

* **message**
  * message body content should be 'contents'	 ([d3a9a4a](/../../commit/d3a9a4a))


<a name="v1.24.0"></a>
### v1.24.0 (2018-04-13)


#### Features

* Add retries to verification publishing	 ([6620165](/../../commit/6620165))


<a name="v1.23.0"></a>
### v1.23.0 (2018-04-16)


#### Features

* allow --out FILE to be specified for the output from pact verify	 ([ca19aa8](/../../commit/ca19aa8))


#### Bug Fixes

* URL escape file paths in index of generated markdown	 ([6af19d5](/../../commit/6af19d5))


<a name="v1.22.2"></a>
### v1.22.2 (2018-03-24)


#### Bug Fixes

* message pact verification code	 ([1bfa8f3](/../../commit/1bfa8f3))


<a name="v1.22.0"></a>
### v1.22.0 (2018-03-16)


#### Features

* do not create reports/pacts/help.md when executing verify from a wrapper language	 ([f1a2cd4](/../../commit/f1a2cd4))
* add support for verifying message pacts	 ([fa98102](/../../commit/fa98102))


<a name="v1.21.0"></a>
### v1.21.0 (2018-03-19)


#### Features

* update pact-support to ~>1.3	 ([17cfbf8](/../../commit/17cfbf8))
* do not create reports/pacts/help.md when executing verify from a wrapper language	 ([ea6de47](/../../commit/ea6de47))


<a name="v1.20.0"></a>
### v1.20.0 (2017-12-10)


#### Bug Fixes

* send verification publishing message to stderr when json output	 ([568f511](/../../commit/568f511))


<a name="v1.19.2"></a>
### v1.19.2 (2017-11-16)


#### Features

* **publish test results**
  * rename example to test in JSON	 ([cd2b79e](/../../commit/cd2b79e))
  * remove ansi colours from error messages	 ([4416d04](/../../commit/4416d04))
  * only publish for rspec 3	 ([31192d0](/../../commit/31192d0))
  * only publish verification results when all interactions have been run	 ([0c56752](/../../commit/0c56752))
  * enable test results to be published to the pact broker in the verification results	 ([e0dad27](/../../commit/e0dad27))


#### Bug Fixes

* **verifications**
  * tag provider version, not consumer version	 ([b347588](/../../commit/b347588))


<a name="v1.19.1"></a>
### v1.19.1 (2017-10-31)


#### Bug Fixes

* **verifications**
  * do not print warning about missing pb:tag-version link when there are no tags configured	 ([ed9468a](/../../commit/ed9468a))


<a name="v1.19.0"></a>
### v1.19.0 (2017-10-30)


#### Features

* **verifications**
  * allow provider version tags to be specified	 ([bff4611](/../../commit/bff4611))


<a name="v1.18.0"></a>
## 1.18.0 (2017-10-30)
* 7cde586 - feat: correct rack-test dependency for rails 5 support (Beth Skurrie, Mon Oct 30 10:09:07 2017 +1100)

<a name="v1.17.0"></a>
## 1.17.0 (2017-10-27)

* 4ae8417 - feat: allow json formatter to be configured for pact verify (Beth Skurrie, Fri Oct 27 16:08:41 2017 +1100)

<a name="v1.16.1"></a>
## 1.16.1 (2017-10-18)

* 7b1747b - fix: reify terms in headers when replaying request (Beth Skurrie, Wed Oct 18 09:01:26 2017 +1100)

## 1.16.0 (25 September 2017)
* 70e67cf - feat: improve description of rspec header matching 'it' blocks and failure text (Beth Skurrie, Mon Sep 25 08:46:06 2017 +1000)
* 85d8e09 - fix: correctly display pact term when parent key is missing (Beth Skurrie, Mon Sep 25 08:43:02 2017 +1000)

## 1.15.0 (11 August 2017)
* a950a16 - fix: Fix module declaration (Beth Skurrie, Fri Aug 11 11:47:46 2017 +1000)
* 14cd969 - feat(output): Remove ruby specific text from pact verification output. (Beth Skurrie, Tue Aug 8 17:12:50 2017 +1000)

## 1.14.0 (19 June 2017)
* eb44499 - Updated pact-support version (Beth Skurrie, Mon Jun 19 09:51:13 2017 +1000)
* 8835496 - Changed colour of acutal response body output (Beth Skurrie, Tue Jun 6 10:44:45 2017 +1000)
* f675d50 - Mention pact-consumer-minitest in Readme (azul, Sat May 27 09:53:25 2017 +0200)

## 1.13.0 (26 May 2017)
* c9800b0 - Make the code to call for provider state set up and tear down configurable. (Beth Skurrie, Fri May 26 14:32:34 2017 +1000)

## 1.12.1 (23 May 2017)
* 47140b7 - Update .travis.yml to publish to rubygems (Beth Skurrie, Tue May 23 16:23:21 2017 +1000)
* 16c40bd - Use RSpec.configuration.reporter.failed_examples to get failed examples instead of the suite, as it is backwards compatible with rspec 3.0.0 (Beth Skurrie, Tue May 23 15:59:36 2017 +1000)
* c54a3a9 - Add specs and tasks for doing manual end to end testing (create, publish, verify, publish verification) (Beth Skurrie, Tue May 23 15:45:41 2017 +1000)

## 1.12.0 (12 May 2017)
* e12ce11 - Updated pact-mock_service and pact-support gems. Major change: provider_state is now providerState in pact files. (Beth Skurrie, Fri May 12 08:43:04 2017 +1000)

## 1.11.1 (9 May 2017)
* 85f5716 - Add support for publishing verifications over HTTPS. (Beth Skurrie, Tue May 9 14:21:28 2017 +1000)

## 1.11.0 (8 May 2017)
* 2a54388 - Only publish verification results when using spec 3. (Beth Skurrie, Mon May 8 12:08:48 2017 +1000)
* a82d919 - Remove build for ruby 2.0.0! (Beth Skurrie, Tue May 2 15:16:40 2017 +1000)
* 37437db - Use basic auth to publish verification if basic auth was configured on the pact URL. (Beth Skurrie, Tue May 2 10:22:15 2017 +1000)
* 3038354 - Enable verifications to be automatically published to the pact broker. (Beth Skurrie, Tue May 2 08:44:19 2017 +1000)
* 527f27f - Update gem dependency versions. (Beth Skurrie, Tue May 2 08:24:37 2017 +1000)
* 041f107 - Updated pact-mock_service version in gemspec (Beth Skurrie, Tue Apr 4 16:20:10 2017 +1000)

## 1.10.0 (14 Nov 2016)
* 1e8c0bc - Updating pact-support and pact-mock_service versions (Beth Skurrie, Mon Nov 14 10:16:38 2016 +1100)

## 1.9.6 (12 Nov 2016)
* 63d4b81 - Fix bug in default interactions replay order (Yury Tsarev, Sat Nov 12 17:53:14 2016 +1100)

## 1.9.5 (9 Nov 2016)
* b794881 - Read template file with script encoding (Taiki Ono, Wed Nov 2 20:18:50 2016 +0900)

### 1.9.4 (19 Aug 2016)
* 93a1c42 - Ensure consumer level teardown gets called when set up is not defined. https://github.com/pact-foundation/pact-ruby/issues/111 (Beth Skurrie, Fri Aug 19 08:56:20 2016 +1000)

### 1.9.3 (27 Jun 2016)
* edb2208 - Clarify that pact will only work with ruby >= 2.0 (Sergei Matheson, Mon Jun 27 10:53:08 2016 +1000)
* 52de989 - remove duplicated `--backtrace` option (Takuto Wada, Tue Jun 7 15:51:12 2016 +0900)

### 1.9.2 (26 May 2016)
* 88741ac - Merge pull request #104 from reevoo/randomise_contract_interactions (Sergei Matheson, Thu May 26 15:09:31 2016 +1000)
* 67c2b30 - Add interactions_replay_order and pactfile_write_order into Pact.configuration (Alex Malkov, Tue May 10 01:44:04 2016 +0100)
* 983a505 - Merge pull request #105 from elgalu/patch-2 (Beth Skurrie, Thu May 12 07:52:21 2016 +1000)
* 60d8b5c - "to need to need" README.md typo (Leo Gallucci, Wed May 11 17:39:49 2016 +0200)
* 2cb57f7 - Test on ruby 2.3.1 (Sergei Matheson, Tue May 3 16:37:40 2016 +1000)
* 4594a97 - Use at least v0.5.7 of pact-support (Sergei Matheson, Tue May 3 16:36:39 2016 +1000)

### 1.9.1 (3 May 2016)
* b3409a7 - Accept nil port as find and use available port (Taiki Ono, Wed Mar 16 19:34:46 2016 +0900)
* a7f644f - Update README URLs based on HTTP redirects (ReadmeCritic, Mon Mar 14 07:03:52 2016 -0700)
* 9cbf0f0 - Load missing dependent library (Taiki Ono, Mon Mar 14 17:43:13 2016 +0900)
* 34e6ef9 - Update Travis CI setting with new Rubies (Taiki Ono, Sun Mar 13 21:11:27 2016 +0900)
* 04f80c4 - Update doc about pactfile_write_mode (Taiki Ono, Thu Mar 3 14:25:49 2016 +0900)
* a1c8b6d - Add instructions to put pact gem in Gemfile. (Beth Skurrie, Thu Nov 5 11:16:38 2015 +1100)
* 5f76726 - Escape markdown characters in description and provider state (Beth, Thu Oct 22 09:07:53 2015 +1100)
* 4922ad3 - README.md tiny typo (Leo Gallucci, Tue Sep 8 13:33:58 2015 +0200)
* f4f7276 - there is no attr_reader for :name (Jacob Evans, Mon Jul 27 15:05:31 2015 +1000)

### 1.9.0 (10 July 2015)

* 3e9f310 - Include Pact helper methods to create Terms, ArrayLikes and SomethingLikes. (Beth Skurrie, Fri Jul 10 13:33:50 2015 +1000)
* 583b03d - Added spec to show v2 provider verification works (Beth Skurrie, Thu Jul 9 15:54:09 2015 +1000)
* 1871e91 - Upgraded an losened pact-support and pact-mock_service dependencies (Beth Skurrie, Thu Jul 9 15:53:03 2015 +1000)
* d8010e4 - Updated .ruby-version to 2.2.2 (Beth Skurrie, Thu Jul 9 14:25:04 2015 +1000)
* c1881c4 - Added test to show mock service will use v2 matching rules when the pact specification version is set to 2 (Beth Skurrie, Thu Jul 9 14:01:13 2015
* 5d44285 - Fixed hanging CLI spec (Beth Skurrie, Thu Jul 9 13:33:10 2015 +1000)
* dbf26f2 - Escape markdown chars in consumer and provider names when rendering markdown docs (Beth Skurrie, Tue Jun 16 10:56:43 2015 +1000)

### 1.8.1 (15 June 2015)

* 207a33d - Escape HTML characters in description when generating 'a' tag IDs. https://github.com/pact-foundation/pact_broker/issues/28 (Beth, Mon Jun 15 17:39:02 2015 +1000)
* 2441e25 - hide the password in the pact uri to_s (lifei zhou, Mon May 4 19:21:40 2015 +1000)
* 60ba514 - added to_s method on PactUri for printing out the uri when running the test (lifei zhou, Sun May 3 17:20:28 2015 +1000)

### 1.8.0 (27 April 2015)

* 5c73acd - Upgrade pact-support (BrunoChauvet, Thu Apr 23 21:40:16 2015 +1000)

### 1.7.0 (20 March 2015)

* 61ce2da - Upgraded pact-support and pact-mock_service gems (Beth Skurrie, Fri Mar 20 15:05:14 2015 +1100)
* 40666b6 - In pact verification DSL pass extra options for pact uri for http basic authentication.  In pact:verify:at[url] task pass http basic authentication info via environment variables (lifei zhou, Thu Feb 26 23:35:32 2015 +1100)

### 1.6.0 (17 February 2015)

* 03a71f7 - Added specs for 'pact docs' CLI, and changed defaults to standard Pact configuration defaults (Beth Skurrie, Tue Feb 17 21:25:50 2015 +1100)
* 8e0deba - Pact CLI docs feature basic implementation (Daniel Stankevich, Tue Feb 17 20:27:21 2015 +1100)
* 0e0e3f2 - Added pact_specification_version to the service provider DSL. Upgraded to pact-mock_service 0.4.0 to support this option. (Beth Skurrie, Fri Feb 13 17:53:31 2015 +1100)
* c8c58cd - minor readme updates to help with clarity :memo: (Joe Sustaric, Thu Feb 12 11:13:21 2015 +1100)
* dda3c5e - Expose ability to add more than one doc generator (Beth Skurrie, Wed Feb 11 09:50:48 2015 +1100)
* ada2231 - Upgrading to version 0.3.0 of pact-mock_service (Beth Skurrie, Wed Feb 4 19:41:10 2015 +1100)
* f34c1de - Whitespace change to LICENSE.txt so I can add a comment to indicate that the previous commit to LICENSE.txt was made because Mike Rowe requested it, as he was auditing REA's use of open source software. (Beth Skurrie, Mon Feb 2 17:05:13 2015 +1100)
* ff98558 - Update LICENSE.txt (Beth Skurrie, Mon Feb 2 16:59:14 2015 +1100)

### 1.5.0 (25 November 2014)

* 9a5ab1c - Allow path to be specified as a Pact::Term (Beth, Wed Jan 21 07:56:19 2015 +1100)
* cdec8bd - Prepended rake commands in output with 'bundle exec' (Beth, Mon Dec 22 17:27:12 2014 +1100)
* 6dfb16e - Added line to print pact verify command to stdout (Beth, Mon Dec 22 17:19:00 2014 +1100)
* b507f50 - Changed colours of missing provider state templates (Beth, Tue Dec 16 21:50:00 2014 +1100)
* d61769c - Added prompt for rake pact:verify:help on test failure. (Beth, Tue Dec 16 21:34:51 2014 +1100)
* c5377a1 - Created rake pact:verify:help task to display help text (Beth, Tue Dec 16 20:38:45 2014 +1100)
* c9d1189 - Write help to file after pact:verify (Beth, Tue Dec 16 19:49:20 2014 +1100)
* c7d8c35 - Added pact diff to help text (Beth, Tue Dec 16 13:14:35 2014 +1100)
* c877b94 - Moved interaction filter to command line argument from ENV (Beth, Sun Dec 14 22:05:44 2014 +1100)
* cd077ec - Added message to show diff between current pact and previous version when pact:verify fails. This relies on the 'diff-previous-distinct' relation being present in the pact resource, so will only work when the pact is retrieved from a pact broker (Beth, Fri Dec 12 11:25:59 2014 +1100)
* 43aa930 - Added command line option to show full backtrace for pact:verify failures (Beth, Thu Dec 4 08:45:28 2014 +1100)
* 5667874 - Ensure markdown doc rendering doesn't blow up if there is a nil description (Beth, Wed Dec 3 21:35:42 2014 +1100)

### 1.4.0 (25 November 2014)

* e596eb8 - Added appraisal gem so we can test against RSpec 2 and 3. (bethesque, Thu Nov 20 09:31:13 2014 +1100)
* fb40662 - Rescue EOFError when starting server jruby fails because of this all the time on TravisCI (bethesque, Fri Nov 14 15:58:08 2014 +1100)
* c1e8b55 - Removing extraneous files from being included in the gem (bethesque, Fri Nov 14 14:03:44 2014 +1100)
* 247e1c2 - Added example pact:publish task to example app (bethesque, Tue Nov 11 21:30:48 2014 +1100)
* 935b318 - Removed Gemfile.lock from source control (bethesque, Fri Oct 24 16:02:36 2014 +1100)
* b2f9073 - Mock Service client must now specify the pact dir (bethesque, Fri Oct 24 09:39:12 2014 +1100)
* c64e122 - Add the ability to use regex in headers when defining the response. (Michael Treacher, Thu Oct 23 21:22:13 2014 +1100)
* 892e526 - Removed jruby-19mode from .travis.yml, it fails inconsistently with EOF error. (bethesque, Wed Oct 22 16:26:28 2014 +1100)

### 1.4.0.rc4 (22 October 2014)

* e56775a - Upgraded pact support gems to allow form bodies to be specified as Hashes with Pact::Terms (bethesque, Wed Oct 22 15:31:30 2014 +1100)

### 1.4.0.rc3 (17 October 2014)

* 602906f - Upped pact-support version to allow queries specified as hashes. (bethesque, Fri Oct 17 14:30:39 2014 +1100)

### 1.4.0.rc2 (12 October 2014)

* 61036fc - Updating pact-support version (bethesque, Sun Oct 12 14:39:36 2014 +1100)

### 1.4.0.rc1 (12 October 2014)

* df3342f - Removing pact server command as it is now in pact-mock_service (bethesque, Sun Oct 12 12:39:56 2014 +1100)
* 12ccdb7 - Making gem source configurable (bethesque, Sun Oct 12 12:39:32 2014 +1100)
* 5b76516 - Removed files that are now in pact-support (bethesque, Sun Oct 12 11:40:57 2014 +1100)
* c4365c5 - Fix bug in calling of SomethingLike serialisation (André Allavena, Fri Oct 10 15:39:57 2014 +1000)
* 546b5c7 - JSON isn't auto-loaded; require it before use. (Daniel Heath, Wed Oct 8 13:31:24 2014 +1100)
* 7cac7e9 - Replaced response hash with Response class - say no to Hash Driven Development (bethesque, Fri Oct 3 17:22:38 2014 +1000)
* 36940d3 - Added test cases to show response headers are case insensitive (bethesque, Fri Oct 3 15:25:03 2014 +1000)
* f4422e2 - Fix typos in README (Mark Dalgleish, Mon Sep 29 17:12:17 2014 +1000)

### 1.3.3 (23 September 2014)

* 9106aac - Fixed reification when using FactoryGirl. (bethesque, Tue Sep 23 08:23:51 2014 +1000)
* 2182803 - Added "query" to example. (bethesque, Fri Sep 19 14:29:36 2014 +1000)
* 0002014 - Added key to explain - and + in unix diff output. (bethesque, Mon Sep 8 15:21:37 2014 +1000)
* 34f1c9b - Adding forward compatibility for reading 'providerState' from pact. (bethesque, Mon Aug 25 16:09:57 2014 +1000)

### 1.3.2 (20 August 2014)

* 65e1e23 - Renamed memoised :options to :diff_options because it clashes with the HTTP options method (bethesque, Wed Aug 20 09:31:0
* ca883a8 - Made options optional for ConsumerContactBuilder.wait_for_interactions (bethesque, Mon Aug 18 15:53:47 2014 +1000)

### 1.3.1 (11 August 2014)

* 3432259 - Fixed 'pact:verify broken with rspec-core 3.0.3'  https://github.com/pact-foundation/pact-ruby/issues/44 (bethesque, Mon Aug 11 10:14:42 2014 +1000)
* e2e8eff - Deleted documentation that has been moved to the wiki (bethesque, Thu Jul 24 15:20:07 2014 +1000)
* bcc3143 - Fixing bug 'Method case should not matter when matching requests' https://github.com/pact-foundation/pact-ruby/issues/41 (bethesque, Tue Jul 22 16:51:48 2014 +1000)
* d4bfab9 - Adding ability to configure DiffFormatter based on content-type (bethesque, Mon Jun 23 21:22:47 2014 +1000)
* eb330ea - Ensured content-type header works in a case insensitive way when looking up the right differ (bethesque, Mon Jun 23 17:23:04 2014 +1000)
* 2733e8e - Made header matching case insensitive for requests. Fixing issue https://github.com/pact-foundation/pact-ruby/issues/20 (bethesque, Mon May 26 19:15:48 2014 +1000)
* 2b8355d - Added nicer error message for scenario when a service provider app has not been configured, and there is no config.ru (bethesque, Mon Jun 23 09:42:18 2014 +1000)
* 1e774bb - Defaulting to TextDiffer if response has no content-type (bethesque, Sat Jun 21 10:34:44 2014 +1000)
* 863b093 - Added support for documents without content types (bethesque, Sat Jun 21 10:32:08 2014 +1000)
* b21900b - Enabling differs to be configured based on Content-Type (bethesque, Sat Jun 21 10:21:37 2014 +1000)
* 527b5d5 - Modified after hook to only write pacts when one or more 'pact => true' examples have run (bethesque, Wed Jun 18 15:15:55 2014 +1000)

### 1.3.0 (18 June 2014)

* ea79190 - Modifying (cough*monkeypatching*cough) RSpec::Core::BacktraceFormatter as RSpec3 has some hardcoded exclusion patterns that result in *all* the backtrace lines being shown when pact:verify fails. (bethesque, Wed Jun 18 13:02:38 2014 +1000)
* 0fd2bb2 - Support objects that return valid URI strings through to_s (Gabriel Rotbart, Fri Jun 13 14:34:03 2014 +1000)

### 1.2.1.rc2 (13 June 2014)

* d805f35 - Ensuring the pact RSpec formatter works for both rspec 2 and rspec 3 (bethesque, Fri Jun 13 16:27:01 2014 +1000)
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

  * 5e1b78d - Display / in logs when path is empty https://github.com/pact-foundation/pact-ruby/issues/14 (bethesque, Thu May 1 22:09:29 2014 +1000)
  * 01c5414 - Fixing doc generation bug where Pact::Terms were being displayed https://github.com/pact-foundation/pact-ruby/issues/13 (bethesque, Thu May 1 21:41:11 2014 +1000)
  * 292a14b - Cleaning doc dir before generating new docs as per https://github.com/pact-foundation/pact-ruby/issues/11 (bethesque, Tue Apr 29 12:44:47 2014 +1000)
  * 73c15dd - Changed default doc_dir to ./doc/pacts as per https://github.com/pact-foundation/pact-ruby/issues/12 (bethesque, Tue Apr 29 12:33:57 2014 +1000)
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
