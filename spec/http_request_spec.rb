require 'spec_helper'
require 'ronin/db/http_request'

describe Ronin::DB::HTTPRequest do
  it "must use the 'ronin_http_requests' table" do
    expect(described_class.table_name).to eq('ronin_http_requests')
  end

  let(:name)  { 'foo' }
  let(:value) { 'bar' }

  let(:http_header_name) do
    Ronin::DB::HTTPHeaderName.find_or_initialize_by(name: name)
  end

  let(:version)        { '1.1' }
  let(:request_method) { :get }
  let(:path)           { '/search' }

  subject do
    described_class.new(
      version:        version,
      request_method: request_method,
      path:           path
    )
  end

  describe "validations" do
    describe "version" do
      %w[1.0 1.1 2.0].each do |valid_version|
        it "must accept '#{valid_version}'" do
          request = described_class.new(
            version:        valid_version,
            request_method: request_method,
            path:           path
          )

          expect(request).to be_valid
        end
      end

      it "must not accept any other version String" do
        request = described_class.new(
          version:        '3.0',
          request_method: request_method,
          path:           path
        )

        expect(request).to_not be_valid
        expect(request.errors[:version]).to eq(
          ["is not included in the list"]
        )
      end

      it "must not accept any other String" do
        request = described_class.new(
          version:        'foo',
          request_method: request_method,
          path:           path
        )

        expect(request).to_not be_valid
        expect(request.errors[:version]).to eq(
          ["is not included in the list"]
        )
      end

      it "must not accept nil" do
        request = described_class.new(
          version:        nil,
          request_method: request_method,
          path:           path
        )

        expect(request).to_not be_valid
        expect(request.errors[:version]).to eq(
          ["can't be blank", "is not included in the list"]
        )
      end
    end

    describe "source_ip" do
      let(:address)      { '127.0.0.1' }
      let(:ipv4_address) { '93.184.216.34' }
      let(:ipv6_address) { '2606:2800:220:1:248:1893:25c8:1946' }

      it "must not require an address" do
        request = described_class.new

        expect(request).to_not be_valid

        request = described_class.new(
          version:        version,
          request_method: request_method,
          path:           path
        )

        expect(request).to be_valid
      end

      it "must accept IPv4 addresses" do
        request = described_class.new(
          version:        version,
          request_method: request_method,
          path:           path,
          source_ip:      ipv4_address
        )

        expect(request).to be_valid
      end

      it "must accept IPv6 addresses" do
        request = described_class.new(
          version:        version,
          request_method: request_method,
          path:           path,
          source_ip:      ipv6_address
        )

        expect(request).to be_valid
      end

      it "must not accept non-IP addresses" do
        request = described_class.new(
          version:        version,
          request_method: request_method,
          path:           path,
          source_ip:      '0'
        )

        expect(request).to_not be_valid
        expect(request.errors[:source_ip]).to eq(
          ["Must be a valid IP address"]
        )
      end
    end

    describe "request_method" do
      [
        :copy,
        :delete,
        :get,
        :head,
        :lock,
        :mkcol,
        :move,
        :options,
        :patch,
        :post,
        :propfind,
        :proppatch,
        :put,
        :trace,
        :unlock,
        'COPY',
        'DELETE',
        'GET',
        'HEAD',
        'LOCK',
        'MKCOL',
        'MOVE',
        'OPTIONS',
        'PATCH',
        'POST',
        'PROPFIND',
        'PROPPATCH',
        'PUT',
        'TRACE',
        'UNLOCK'
      ].each do |valid_request_method|
        it "must accept #{valid_request_method.inspect}" do
          request = described_class.new(
            version:        version,
            request_method: valid_request_method,
            path:           path
          )

          expect(request).to be_valid
        end
      end

      it "must not accept any other Symbol" do
        expect {
          described_class.new(
            version:        version,
            request_method: :foo,
            path:           path
          )
        }.to raise_error(ArgumentError,"'foo' is not a valid request_method")
      end

      it "must not accept a nil value" do
        request = described_class.new(
          version:        version,
          request_method: nil,
          path:           path
        )

        expect(request).to_not be_valid
      end

      it "must require a request_method value" do
        request = described_class.new(
          version: version,
          path:    path
        )

        expect(request).to_not be_valid
      end
    end

    describe "path" do
      it "must require a path" do
        request = described_class.new(
          version:        version,
          request_method: request_method
        )

        expect(request).to_not be_valid
        expect(request.errors[:path]).to eq(
          ["can't be blank"]
        )
      end

      it "must require a non-empty path" do
        request = described_class.new(
          version:        version,
          request_method: request_method,
          path:           ''
        )

        expect(request).to_not be_valid
        expect(request.errors[:path]).to eq(
          ["can't be blank"]
        )
      end
    end
  end

  describe "#copy_request?" do
    context "when #request_method is :copy" do
      let(:request_method) { :copy }

      it "must return true" do
        expect(subject.copy_request?).to be(true)
      end
    end

    context "when #request_method is not :copy" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.copy_request?).to be(false)
      end
    end
  end

  describe "#delete_request?" do
    context "when #request_method is :delete" do
      let(:request_method) { :delete }

      it "must return true" do
        expect(subject.delete_request?).to be(true)
      end
    end

    context "when #request_method is not :delete" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.delete_request?).to be(false)
      end
    end
  end

  describe "#get_request?" do
    context "when #request_method is :get" do
      let(:request_method) { :get }

      it "must return true" do
        expect(subject.get_request?).to be(true)
      end
    end

    context "when #request_method is not :get" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.get_request?).to be(false)
      end
    end
  end

  describe "#head_request?" do
    context "when #request_method is :head" do
      let(:request_method) { :head }

      it "must return true" do
        expect(subject.head_request?).to be(true)
      end
    end

    context "when #request_method is not :head" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.head_request?).to be(false)
      end
    end
  end

  describe "#lock_request?" do
    context "when #request_method is :lock" do
      let(:request_method) { :lock }

      it "must return true" do
        expect(subject.lock_request?).to be(true)
      end
    end

    context "when #request_method is not :lock" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.lock_request?).to be(false)
      end
    end
  end

  describe "#mkcol_request?" do
    context "when #request_method is :mkcol" do
      let(:request_method) { :mkcol }

      it "must return true" do
        expect(subject.mkcol_request?).to be(true)
      end
    end

    context "when #request_method is not :mkcol" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.mkcol_request?).to be(false)
      end
    end
  end

  describe "#move_request?" do
    context "when #request_method is :move" do
      let(:request_method) { :move }

      it "must return true" do
        expect(subject.move_request?).to be(true)
      end
    end

    context "when #request_method is not :move" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.move_request?).to be(false)
      end
    end
  end

  describe "#options_request?" do
    context "when #request_method is :options" do
      let(:request_method) { :options }

      it "must return true" do
        expect(subject.options_request?).to be(true)
      end
    end

    context "when #request_method is not :options" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.options_request?).to be(false)
      end
    end
  end

  describe "#patch_request?" do
    context "when #request_method is :patch" do
      let(:request_method) { :patch }

      it "must return true" do
        expect(subject.patch_request?).to be(true)
      end
    end

    context "when #request_method is not :patch" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.patch_request?).to be(false)
      end
    end
  end

  describe "#post_request?" do
    context "when #request_method is :post" do
      let(:request_method) { :post }

      it "must return true" do
        expect(subject.post_request?).to be(true)
      end
    end

    context "when #request_method is not :post" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.post_request?).to be(false)
      end
    end
  end

  describe "#propfind_request?" do
    context "when #request_method is :propfind" do
      let(:request_method) { :propfind }

      it "must return true" do
        expect(subject.propfind_request?).to be(true)
      end
    end

    context "when #request_method is not :propfind" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.propfind_request?).to be(false)
      end
    end
  end

  describe "#proppatch_request?" do
    context "when #request_method is :proppatch" do
      let(:request_method) { :proppatch }

      it "must return true" do
        expect(subject.proppatch_request?).to be(true)
      end
    end

    context "when #request_method is not :proppatch" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.proppatch_request?).to be(false)
      end
    end
  end

  describe "#put_request?" do
    context "when #request_method is :put" do
      let(:request_method) { :put }

      it "must return true" do
        expect(subject.put_request?).to be(true)
      end
    end

    context "when #request_method is not :put" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.put_request?).to be(false)
      end
    end
  end

  describe "#trace_request?" do
    context "when #request_method is :trace" do
      let(:request_method) { :trace }

      it "must return true" do
        expect(subject.trace_request?).to be(true)
      end
    end

    context "when #request_method is not :trace" do
      let(:request_method) { :unlock }

      it "must return false" do
        expect(subject.trace_request?).to be(false)
      end
    end
  end

  describe "#unlock_request?" do
    context "when #request_method is :unlock" do
      let(:request_method) { :unlock }

      it "must return true" do
        expect(subject.unlock_request?).to be(true)
      end
    end

    context "when #request_method is not :unlock" do
      let(:request_method) { :get }

      it "must return false" do
        expect(subject.unlock_request?).to be(false)
      end
    end
  end
end
