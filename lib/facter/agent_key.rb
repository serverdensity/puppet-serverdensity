require 'facter'
require 'net/http'
require 'uri'

Facter.add(:sd_agent_key, :timeout => 10) do

    # just in case we don't get any of them
    result = nil

    # We inject '/etc/sd-agent-key' using the Rackspace api when an
    # instance is created via the Server Density Cloud integration.
    # Do this first as it's fast
    if File::exist?('/etc/sd-agent-key')
        result = Facter::Util::Resolution.exec("cat /etc/sd-agent-key")
    elsif File::exist?('/var/run/sd-agent-key')
        result = Facter::Util::Resolution.exec("cat /var/run/sd-agent-key")
    elsif Facter.value('ec2_instance_id')
        # use the amazon metadata api to
        # get user-data that we've set on
        # instance creation
        uri = URI("http://ec2meta.serverdensity.com/latest/user-data")
        req = Net::HTTP::Get.new(uri.request_uri)
        res = Net::HTTP.start(uri.host, uri.port) {|http|
                http.request(req)
            }

        result = res.body.split(':').last if res.code == 200
    end

    # if we get to here and neither of the above
    # methods have worked
    # the custom function will use the api to create
    # a new device, rather than matching to an existing one

    setcode { result }
end
