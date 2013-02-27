require 'net/http'
require 'uri'

module Puppet::Parser::Functions

    newfunction(:agent_key, :type => :rvalue) do |args|

        sd_username = args[0]
        sd_password = args[1]
        sd_url = args[2]
        token = args[3]
        agent_key = args[4]

        sd_url = sd_url.sub(/^https?\:\/\//, '')

        unless agent_key.nil? or agent_key.empty?
            notice ["Agent Key Provided: #{ agent_key }"]
            return agent_key
        end

        if sd_url.nil? or sd_url.empty?
            raise Puppet::ParseError, "SD URL not set"
        end

        if token.nil? or token.empty?
            api_version = "1.4"
        else
            api_version = "2"
        end


        if api_version == "1.4"

            if sd_password.nil? or sd_password.empty?
                raise Puppet::ParseError, "SD Password not set"
            end
            if sd_username.nil? or sd_username.empty?
                raise Puppet::ParseError, "SD Username not set"
            end

            base_url = 'http://api.serverdensity.com/1.4/'
            hostname = Facter["hostname"].value
            uri = URI("#{ base_url }devices/getByHostName?hostName=#{ hostname }&account=#{ sd_url }")

            req = Net::HTTP::Get.new(uri.request_uri)
            req.basic_auth sd_username, sd_password

            res = Net::HTTP.start(uri.host, uri.port) {|http|
                http.request(req)
            }

            device = PSON.parse(res.body)

            if device['status'] == 2
                notice ["Device not found, creating a new one"]

                uri = URI("#{ base_url }devices/add?account=#{ sd_url }")
                req = Net::HTTP::Post.new(uri.request_uri)
                req.basic_auth sd_username, sd_password

                params = {
                    'name' => hostname,
                    'hostName' => hostname,
                    'notes' => 'Created automatically by puppet-serverdensity',
                }

                # Create new device
                req.set_form_data(params)

                res = Net::HTTP.start(uri.host, uri.port) {|http|
                    http.request(req)
                }
                device = PSON.parse(res.body)
                agent_key = device['data']['agentKey']
            else
                notice ["Reusing existing device"]
                agent_key = device['data']['device']['agentKey']
            end

            notice ["Agent Key: #{ agent_key }"]


        elsif api_version == "2"
            notice ["Using SD Version 2"]

            api_token = scope.lookupvar("token")
            if api_token.nil? or api_token.empty?
                raise Puppet::ParseError, "SD API token not set"
            end
        end

        return agent_key
    end
end