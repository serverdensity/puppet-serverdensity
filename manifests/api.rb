require 'net/http'
require 'uri'
require 'json'

hostclass :api, :arguments => {"api_version" => nil, "sd_username" => nil, "sd_password" => nil, "sd_url" => nil, "token" => nil} do

    api_version = scope.lookupvar("api_version")
    if api_version.nil? or api_version.empty?
        raise Puppet::ParseError, "API version not set"
    end

    sd_url = scope.lookupvar("sd_url")
    if sd_url.nil? or sd_url.empty?
        raise Puppet::ParseError, "SD URL not set"
    end

    if api_version == "1"
        notice ["Using SD Version 1"]

        sd_password = scope.lookupvar("sd_password")
        if sd_password.nil? or sd_password.empty?
            raise Puppet::ParseError, "SD Password not set"
        end
        sd_username = scope.lookupvar("sd_username")
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

        device = JSON.parse(res.body)

        if device['status'] == 2
            notice ["Device not found, creating a new one"]

            uri = URI("#{ base_url }devices/add?account=#{ sd_url }")
            req = Net::HTTP::Post.new(uri.request_uri)
            req.basic_auth sd_username, sd_password

            params = {
                'name' => Facter["hostname"].value,
                'hostName' => Facter["hostname"].value,
                'notes' => 'Created automatically by chef-serverdensity',
            }

            # Create new device
            req.set_form_data(params)

            res = Net::HTTP.start(uri.host, uri.port) {|http|
                http.request(req)
            }

            notice [res.value]
        end


    elsif api_version == "2"
        notice ["Using SD Version 2"]

        api_token = scope.lookupvar("token")
        if api_token.nil? or api_token.empty?
            raise Puppet::ParseError, "SD API token not set"
        end
    end

    

    #notice [)]

    #uri = URI('scope.lookupvar("token")
    #token = Net::HTTP.get(uri)

    

    notice [api_token]
    notice [sd_url]
end