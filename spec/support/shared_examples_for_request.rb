shared_examples "a request" do

  describe 'matching' do
    let(:expected) do
      Pact::Request::Expected.from_hash(
        {'method' => 'get', 'path' => 'path', 'query' => /b/}
        )
    end

    let(:actual) do
      Pact::Consumer::Request::Actual.from_hash({'method' => 'get', 'path' => 'path', 'query' => 'blah', 'headers' => {}, 'body' => ''})
    end

    it "should match" do
      expect(expected.difference(actual)).to eq({})
    end
  end

  describe 'full_path' do
    context "with empty path" do
      subject { described_class.from_hash({:path => '', :method => 'get', :query => '', :headers => {}}) }
      it "returns the full path"do
        expect(subject.full_path).to eq "/"
      end
    end
    context "with a path" do
      subject { described_class.from_hash({:path => '/path', :method => 'get', :query => '', :headers => {}}) }
      it "returns the full path"do
        expect(subject.full_path).to eq "/path"
      end
    end
    context "with a path and query" do
      subject { described_class.from_hash({:path => '/path', :method => 'get', :query => "something", :headers => {}}) }
      it "returns the full path"do
        expect(subject.full_path).to eq "/path?something"
      end
    end
    context "with a path and a query that is a Term" do
      subject { described_class.from_hash({:path => '/path', :method => 'get', :headers => {}, :query => Pact::Term.new(generate: 'a', matcher: /a/)}) }
      it "returns the full path with reified path" do
        expect(subject.full_path).to eq "/path?a"
      end
    end
  end

  describe "building from a hash" do

    let(:raw_request) do
      {
        'method' => 'get',
        'path' => '/mallory',
        'query' => 'query',
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'body' => 'hello mallory'
      }
    end

    subject { described_class.from_hash(raw_request) }

    it "extracts the method" do
      expect(subject.method).to eq 'get'
    end

    it "extracts the path" do
      expect(subject.path).to eq '/mallory'
    end

    it "extracts the body" do
      expect(subject.body).to eq 'hello mallory'
    end

    it "extracts the query" do
      expect(subject.query).to eq 'query'
    end

    it "blows up if method is absent" do
      raw_request.delete 'method'
      expect { described_class.from_hash(raw_request) }.to raise_error
    end

    it "blows up if path is absent" do
      raw_request.delete 'path'
      expect { described_class.from_hash(raw_request) }.to raise_error
    end

    it "does not blow up if body is missing" do
      raw_request.delete 'body'
      expect { described_class.from_hash(raw_request) }.to_not raise_error
    end

  end
end