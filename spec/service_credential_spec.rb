require 'spec_helper'
require 'ronin/db/service_credential'

describe Ronin::DB::ServiceCredential do
  it "must use the 'ronin_credentials' table" do
    expect(described_class.table_name).to eq('ronin_credentials')
  end

  let(:user)        { 'admin' }
  let(:user_name)   { Ronin::DB::UserName.new(name: user) }
  let(:password)    { Ronin::DB::Password.new(clear_text: 'secret') }
  let(:port_number) { 22 }
  let(:ip_address)  { Ronin::DB::IPAddress.new(address: '1.2.3.4') }
  let(:port)        { Ronin::DB::Port.new(number: port_number) }
  let(:open_port) do
    Ronin::DB::OpenPort.new(
      port:       port,
      ip_address: ip_address
    )
  end

  subject do
    described_class.new(
      user_name: user_name,
      password:  password,
      open_port: open_port
    )
  end

  describe "#to_s" do
    it "must return the username:password and ip:port values in the String" do
      expect(subject.to_s).to eq(
        "#{user_name}:#{password} (#{open_port})"
      )
    end
  end
end
