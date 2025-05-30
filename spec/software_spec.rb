require 'spec_helper'
require 'ronin/db/software'

describe Ronin::DB::Software do
  it "must use the 'ronin_softwares' table" do
    expect(described_class.table_name).to eq('ronin_softwares')
  end

  let(:name)    { 'Test'  }
  let(:version) { '0.1.0' }
  let(:vendor)  { 'TestCo' }

  describe "validations" do
    describe "nmae" do
      it "must require name attribute" do
        software = described_class.new(version: version)
        expect(software).to_not be_valid
        expect(software.errors[:name]).to eq(
          ["can't be blank"]
        )

        software = described_class.new(name: name, version: version)
        expect(software).to be_valid
      end
    end

    describe "version" do
      it "must require version attribute" do
        software = described_class.new(name: name)
        expect(software).to_not be_valid
        expect(software.errors[:version]).to eq(
          ["can't be blank"]
        )

        software = described_class.new(name: name, version: version)
        expect(software).to be_valid
      end
    end

    it "the name and version attributes must be unique" do
      described_class.create(name: name, version: version)

      software = described_class.new(name: name, version: version)
      expect(software).to_not be_valid
      expect(software.errors[:version]).to eq(
        ['has already been taken']
      )

      described_class.destroy_all
    end
  end

  describe ".with_version" do
    let(:version) { '1.2.3' }

    before do
      described_class.create(name: 'Minesweeper', version: '0.1')
      described_class.create(name: 'Solitare',    version: version)
      described_class.create(name: 'Notepad',     version: version)
    end

    subject { described_class }

    it "must find all #{described_class} with the matching version" do
      software = subject.with_version(version)

      expect(software.length).to eq(2)
      expect(software.map(&:version).uniq).to eq([version])
    end

    after do
      described_class.destroy_all
    end
  end

  describe ".with_vendor_name" do
    let(:vendor_name) { 'Microsoft' }

    before do
      vendor1 = Ronin::DB::SoftwareVendor.create(name: 'Mozilla')
      vendor2 = Ronin::DB::SoftwareVendor.create(name: vendor_name)

      described_class.create(name: 'Firefox',  version: '12.0', vendor: vendor1)
      described_class.create(name: 'Solitare', version: '1.0',  vendor: vendor2)
      described_class.create(name: 'Notepad',  version: '2.0',  vendor: vendor2)
    end

    subject { described_class }

    it "must find all #{described_class} with the matching version" do
      software = subject.with_vendor_name(vendor_name)

      expect(software.length).to eq(2)
      expect(software.map { |s| s.vendor.name }.uniq).to eq([vendor_name])
    end

    after do
      Ronin::DB::Software.destroy_all
      Ronin::DB::SoftwareVendor.destroy_all
    end
  end

  subject do
    described_class.new(
      name:    name,
      version: version,
      vendor:  Ronin::DB::SoftwareVendor.new(name: vendor)
    )
  end

  describe "#to_s" do
    it "must be convertable to a String" do
      expect(subject.to_s).to eq("#{vendor} #{name} #{version}")
    end

    context "without a vendor" do
      subject do
        described_class.new(name: name, version: version)
      end

      it "must ignore the missing vendor information" do
        expect(subject.to_s).to eq("#{name} #{version}")
      end
    end
  end
end
