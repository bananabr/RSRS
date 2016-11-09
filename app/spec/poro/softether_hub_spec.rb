RSpec.describe "SoftEtherHub" do

  before :all do
    @cid=`/usr/bin/docker run -d -p 4443:443 --name softether frosquin/softether`
    sleep 5
    @server = SoftEther::Server.new('localhost', :port => 4443)
    @hub = @server.create_hub!('NEW')
  end
  
  after :all do
    @cid=`/usr/bin/docker stop #{@cid}`
    `/usr/bin/docker rm #{@cid}`
  end

  let(:uid){ (Time.now.to_f * 1000.0).to_i }

  it "should have no users after creation" do
    expect(@hub.users.count).to eq 0
  end

  it "should be able to create new users" do
    expect{@hub.create_user('daniel')}.to change{@hub.users.count}.by(1)
    expect(@hub.users).to include('daniel')
  end
end
