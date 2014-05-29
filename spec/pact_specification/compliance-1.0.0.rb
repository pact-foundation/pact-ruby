require 'spec_helper'
require 'pact/consumer/request'
require 'pact/consumer_contract/request'

PACT_SPEC_DIR = "../pact-specification/testcases"
REQUEST_TEST_CASE_FOLDERS = Dir.glob("#{PACT_SPEC_DIR}/request/**")
REQUEST_TEST_CASE_FILES = Dir.glob("#{PACT_SPEC_DIR}/request/**/*.json")

TEST_DESCRIPTIONS = {true => "matches", false => "does not match"}

describe "Pact gem complicance with Pact Specification 1.0.0" do

  directories = Dir.glob("#{PACT_SPEC_DIR}/*")

  directories.each do | dir_name |

    describe File.basename(dir_name) do

      sub_directories = Dir.glob("#{dir_name}/*")

      sub_directories.each do | sub_dir_name |

        context File.basename(sub_dir_name) do
          testcases = Dir.glob("#{sub_dir_name}/**/*.json")

          testcases.each do | file_name |

            context File.basename(file_name).chomp(".json") do

              file_content = JSON.parse(File.read(file_name))
              expected = Pact::Request::Expected.from_hash(file_content["expected"])
              actual = Pact::Consumer::Request::Actual.from_hash(file_content["actual"])
              expected_result = file_content.fetch("match")
              comment = file_content["comment"]

              it "#{TEST_DESCRIPTIONS[expected_result]} - #{comment}" do
                expect(expected.matches?(actual)).to eq expected_result
              end

            end

          end
        end
      end
    end
  end
end
