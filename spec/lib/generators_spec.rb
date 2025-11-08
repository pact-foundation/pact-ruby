# frozen_string_literal: true

require 'spec_helper'
require 'pact/generators'

module Pact
  module Generators
    RSpec.describe RandomIntGenerator do
      subject { described_class.new(min: 1, max: 10) }

      describe '#as_basic' do
        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:matcher:type' => 'integer',
                                              'pact:generator:type' => 'RandomInt',
                                              'min' => 1,
                                              'max' => 10,
                                              'value' => a_value_between(1, 10)
                                            })
        end
      end
    end

    RSpec.describe RandomDecimalGenerator do
      subject { described_class.new(digits: 5) }

      describe '#as_basic' do
        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:matcher:type' => 'decimal',
                                              'pact:generator:type' => 'RandomDecimal',
                                              'digits' => 5,
                                              'value' => a_value_between(0.00001, 0.99999)
                                            })
        end
      end
    end

    RSpec.describe RandomHexadecimalGenerator do
      subject { described_class.new(digits: 8) }

      describe '#as_basic' do
        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:matcher:type' => 'decimal',
                                              'pact:generator:type' => 'RandomHexadecimal',
                                              'digits' => 8,
                                              'value' => match(/[0-9a-f]{8}/)
                                            })
        end
      end
    end

    RSpec.describe RandomStringGenerator do
      subject { described_class.new(size: 12) }

      describe '#as_basic' do
        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:matcher:type' => 'type',
                                              'pact:generator:type' => 'RandomString',
                                              'size' => 12,
                                              'value' => match(/[a-zA-Z0-9]{12}/)
                                            })
        end
      end
    end

    RSpec.describe UuidGenerator do
      subject { described_class.new }

      describe '#as_basic' do
        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:generator:type' => 'Uuid',
                                              'pact:matcher:type' => 'regex',
                                              'regex' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
                                              'value' => match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/) # rubocop:disable Layout/LineLength
                                            })
        end
      end
    end

    RSpec.describe DateGenerator do
      context 'with format' do
        subject { described_class.new(format: 'yyyy-MM-dd') }

        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:matcher:type' => 'date',
                                              'pact:generator:type' => 'Date',
                                              'format' => 'yyyy-MM-dd',
                                              'value' => match(/\d{4}-\d{2}-\d{2}/)
                                            })
        end
      end

      context 'without format' do
        subject { described_class.new }

        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'format' => 'yyyy-MM-dd',
                                              'pact:generator:type' => 'Date',
                                              'pact:matcher:type' => 'date',
                                              'value' => match(/\d{4}-\d{2}-\d{2}/)
                                            })
        end
      end
    end

    RSpec.describe TimeGenerator do
      context 'with format' do
        subject { described_class.new(format: 'HH:mm:ss') }

        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:generator:type' => 'Time',
                                              'pact:matcher:type' => 'time',
                                              'format' => 'HH:mm:ss',
                                              'value' => match(/\d{2}:\d{2}:\d{2}/)
                                            })
        end
      end

      context 'without format' do
        subject { described_class.new }

        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'format' => 'HH:mm',
                                              'pact:generator:type' => 'Time',
                                              'pact:matcher:type' => 'time',
                                              'value' => match(/\d{2}:\d{2}/)
                                            })
        end
      end
    end

    RSpec.describe DateTimeGenerator do
      context 'with format' do
        subject { described_class.new(format: "yyyy-MM-dd'T'HH:mm:ssZ") }

        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'pact:generator:type' => 'DateTime',
                                              'pact:matcher:type' => 'datetime',
                                              'format' => "yyyy-MM-dd'T'HH:mm:ssZ",
                                              'value' => match(/\d{4}-\d{2}-\d{2}'T'\d{2}:\d{2}:\d{2}\+\d{4}/)
                                            })
        end
      end

      context 'without format' do
        subject { described_class.new }

        it 'returns the correct hash' do
          expect(subject.as_basic).to match({
                                              'format' => 'yyyy-MM-dd HH:mm',
                                              'pact:generator:type' => 'DateTime',
                                              'pact:matcher:type' => 'datetime',
                                              'value' => match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}/)
                                            })
        end
      end
    end

    RSpec.describe RandomBooleanGenerator do
      subject { described_class.new }

      describe '#as_basic' do
        it 'returns the correct hash' do
          match({
                  'pact:generator:type' => 'RandomBoolean',
                  'pact:matcher:type' => 'boolean',
                  'value' => satisfy { |v| [true, false].include?(v) }
                })
        end
      end
    end

    RSpec.describe ProviderStateGenerator do
      subject { described_class.new(expression: '/alligators/${alligator_name}', example: '/alligators/Mary') }

      describe '#as_basic' do
        it 'returns the correct hash' do
          expect(subject.as_basic).to eq({
                                           'pact:generator:type' => 'ProviderState',
                                           'pact:matcher:type' => 'type',
                                           'expression' => '/alligators/${alligator_name}',
                                           'value' => '/alligators/Mary'
                                         })
        end
      end
    end

    RSpec.describe MockServerURLGenerator do
      subject { described_class.new(regex: 'http://localhost:\\d+', example: 'http://localhost:1234') }

      describe '#as_basic' do
        it 'returns the correct hash' do
          expect(subject.as_basic).to eq({
                                           'pact:generator:type' => 'MockServerURL',
                                           'pact:matcher:type' => 'regex',
                                           'regex' => 'http://localhost:\\d+',
                                           'example' => 'http://localhost:1234',
                                           'value' => 'http://localhost:1234'
                                         })
        end
      end
    end
  end
end
