require 'facter'
require 'net/http'
require 'uri'

Facter.add(:agent_key) do

    result = nil

    if File::exist?('/etc/sd-agent-key')
        result = Facter::Util::Resolution.exec("cat /etc/sd-agent-key")
    else
        uri = URI("http://169.254.169.254/latest/user-data")
        req = Net::HTTP::Get.new(uri.request_uri)
        res = Net::HTTP.start(uri.host, uri.port) {|http|
                http.request(req)
            }

        result = res.body.split(':').last
    end
    setcode { result }
end