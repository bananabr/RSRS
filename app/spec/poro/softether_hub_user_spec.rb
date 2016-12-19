RSpec.describe "SoftEtherHubUser" do

  before :all do
    @cid=`/usr/bin/docker run -d -p 4443:443 --name softether frosquin/softether`
    sleep 5
    @server = SoftEther::Server.new('localhost', :port => 4443)
    @hub = @server.create_hub!('HUB')
  end
  
  after :all do
    @cid=`/usr/bin/docker stop #{@cid}`
    `/usr/bin/docker rm #{@cid}`
  end

  let(:uid){ (Time.now.to_f * 1000.0).to_i }

  it "should require only a name and its HUB to be created" do
    u = SoftEther::Hub::User.new('test', @hub)
    expect(u).to be_a(SoftEther::Hub::User)
  end

  it "should have no password after creation" do
    u = SoftEther::Hub::User.new('test', @hub)
    expect(u.password).to be_nil
  end

end
