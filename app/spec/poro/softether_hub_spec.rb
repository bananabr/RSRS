RSpec.describe "SoftEtherHub" do

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

  it "should have a constructor that takes at least its name and server" do
    s = SoftEther::Server.new()
    expect(s.host).to eq('localhost')
    expect(s.port).to eq(443)
    expect(s.timeout).to eq(5)
    expect(s.vpncmd_bin_path).to eq('/usr/local/bin/vpncmd')
    expect(s.password).to eq('')
  end

end
