RSpec.describe "SoftEtherSever" do

  before :all do
    @cid=`/usr/bin/docker run -d -p 4443:443 --name softether frosquin/softether`
    sleep 5
    @server = SoftEther::Server.new('localhost', :port => 4443)
  end
  
  after :all do
    @cid=`/usr/bin/docker stop #{@cid}`
    `/usr/bin/docker rm #{@cid}`
  end

  let(:uid){ (Time.now.to_f * 1000.0).to_i }

  it "should have a default constructor that takes no argument" do
    s = SoftEther::Server.new()
    expect(s.host).to eq('localhost')
    expect(s.port).to eq(443)
    expect(s.timeout).to eq(5)
    expect(s.vpncmd_bin_path).to eq('/usr/local/bin/vpncmd')
    expect(s.password).to eq('')
  end

  it "should accept a host address as its first constructor address" do
    s = SoftEther::Server.new('10.10.10.1')
    expect(s.host).to eq '10.10.10.1'
  end

  it "should accept a port number in its options constructor hash" do
    s = SoftEther::Server.new('localhost', :port => 444, :timeout => 500)
    expect(s.host).to eq 'localhost'
    expect(s.port).to eq 444
    expect(s.timeout).to eq 500
    expect(s.vpncmd_bin_path).to eq '/usr/local/bin/vpncmd'
    expect(s.password).to eq ''
  end

  it "should accept a timeout number in its options constructor hash" do
    s = SoftEther::Server.new('localhost', :timeout => 500)
    expect(s.host).to eq 'localhost'
    expect(s.port).to eq 443
    expect(s.timeout).to eq 500
    expect(s.vpncmd_bin_path).to eq '/usr/local/bin/vpncmd'
    expect(s.password).to eq ''
  end

  it "should have a collections of hubs" do
    expect(@server).to respond_to("hubs").with(0).argument
    hub = @server.hubs['DEFAULT']
    expect(hub).to be_an_instance_of SoftEther::Hub
  end

  it "should be able to create hubs" do
    expect(@server).to respond_to("create_hub!").with(1).argument
    expect(@server).to respond_to("create_hub!").with(2).arguments

    hub_ct = @server.hubs.count
    hub = @server.create_hub!("hub#{uid}",'pass')

    expect(hub).to be_an_instance_of SoftEther::Hub
    expect(@server.hubs.count).to eq(hub_ct+1)
    expect(@server.hubs["hub#{uid}"]).not_to be_nil 
    expect(@server.hubs["hub#{uid}"]).to be_an_instance_of SoftEther::Hub
  end

  it "should be able to delete hubs" do
    expect(@server).to respond_to("delete_hub!").with(1).argument

    hub_ct = @server.hubs.count
    hub = @server.hubs['DEFAULT']
    result = @server.delete_hub!(hub.name)

    expect(hub).to be_an_instance_of SoftEther::Hub
    expect(@server.hubs[hub.name]).to be_nil
    expect(@server.hubs.count).to eq(hub_ct-1)
    expect(result).to be true
  end

  it "should maintain a hub cache" do
    hub = @server.create_hub!("hub#{uid}",'pass')

    expect(@server.hub_cache_is_dirty?).to be true
    @server.hubs
    expect(@server.hub_cache_is_dirty?).to be false
  end
end
