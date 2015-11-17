require 'net/http'
require 'net/https'
require 'uri'

module Puppet::Parser::Functions

    newfunction(:agent_key, :type => :rvalue) do |args|
        sd_url = args[0]
        token = args[1]
        agent_key = args[2]
        server_name = args[3]
        group = args[4]
        use_fqdn = args[5]

        hostname = lookupvar("hostname")
        fqdn = lookupvar("fqdn")
        provider = lookupvar('sd_provider')
        provider_id = lookupvar('sd_provider_id')
        project_id = lookupvar('sd_project_id')

        if server_name.nil? or server_name.empty?
            server_name = fqdn
        end

        if use_fqdn
            notice "Using fqdn for hostname"
            hostname = fqdn
            checks = [hostname]
        else
            # if we don't explicitly want to use the fqdn
            # then we should check hostname and fqdn
            checks = [hostname, fqdn]
        end


        notice ["Server Name: #{ server_name }"]

        sd_url = sd_url.sub(/^https?\:\/\//, '')

        # can we get the agent key from the environment
        # we set it on cloud devices created on Amazon or Rackspace
        # created via the serverdensity UI
        # uses custom agent_key fact
        agent_key = lookupvar("agent_key")

        # lookupvar returns undef if no value
        # test against nil just in case
        unless agent_key.nil? or agent_key == :undef
            notice ["Agent Key Provided via Facter: #{ agent_key }"]
            return agent_key
        end

        if agent_key == :undef
            agent_key = ""
        end

        unless agent_key.nil? or agent_key.empty?
            notice ["Agent Key Provided: #{ agent_key }"]
            return agent_key
        end

        if sd_url.nil? or sd_url.empty?
            raise Puppet::ParseError, "SD URL not set"
        end

        notice ["Using SD Version 2"]

        base_url = "https://api.serverdensity.io"

        list = nil
        if provider and provider_id
            # attempt to find the device by providerId
            filter = {
                'type' => 'device',
                'provider' => provider,
                'providerId' => provider_id
            }
            if project_id
                filter['projectId'] = project_id
            end
            notice ["Making API request for provider: #{ provider } and providerId: #{ provider_id }"]
            filter_json = URI.escape(PSON.dump(filter))
            begin
                uri = URI("#{ base_url }/inventory/devices?filter=#{ filter_json }&token=#{ token }")
                req = Net::HTTP::Get.new(uri.request_uri)
                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
                https.verify_mode = OpenSSL::SSL::VERIFY_NONE
                res = https.start { |cx| cx.request(req) }

                list = PSON.parse(res.body)

            rescue
                err ["Error from SD API, stopping run"]
                raise Puppet::ParseError, "Error from SD API"
            end

            if Integer(res.code) >= 500
                err ["Error from SD API, stopping run"]
                raise Puppet::ParseError, "Error from SD API"
            end

        end

        if list.nil? or list.empty?
            # attempt to find the device by hostname (which may be local or FQDN)
            list = nil
            checks.each do |hn|
                # attempt to detect google cloud devices
                if provider == 'google'
                    hn_split=hn.split(".")
                    name=hn_split[0..-4].join('.')
                    filter = {
                        'type' => 'device',
                        'deleted' => false,
                        'name' => name,
                        'projectId' => project_id,
                        'provider' => 'google'
                    }
                else
                    filter = {
                        'type' => 'device',
                        'deleted' => false,
                        'hostname' => hn,
                    }
                end

                filter_json = URI.escape(PSON.dump(filter))

                notice ["Making API request for hostname: #{ hn }"]

                begin
                    uri = URI("#{ base_url }/inventory/devices?filter=#{ filter_json }&token=#{ token }")
                    req = Net::HTTP::Get.new(uri.request_uri)
                    https = Net::HTTP.new(uri.host, uri.port)
                    https.use_ssl = true
                    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
                    res = https.start { |cx| cx.request(req) }

                    list = PSON.parse(res.body)

                rescue
                    err ["Error from SD API, stopping run"]
                    raise Puppet::ParseError, "Error from SD API"
                end

                if Integer(res.code) >= 500
                    err ["Error from SD API, stopping run"]
                    raise Puppet::ParseError, "Error from SD API"
                end

                if list.length > 0
                    # keep this response -- device was found
                    break
                end
            end
        end

        if Integer(res.code) >= 300 or list.length == 0
            notice ["Device not found, creating a new one"]

            data = {
                :name => server_name,
                :hostname => hostname,
            }
            unless group.nil? or group.empty?
                data['group'] = group
            end

            if provider
                data['provider'] = provider
                if provider_id
                    data['providerId'] = provider_id
                end
            end

            uri = URI("#{ base_url }/inventory/devices?token=#{ token }")
            req = Net::HTTP::Post.new(uri.request_uri)

            # Create new device
            req.set_form_data(data)

            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE
            res = https.start { |cx| cx.request(req) }

            if Integer(res.code) >= 500
                err ["Error from SD API, stopping run"]
                raise Puppet::ParseError, "Error from SD API"
            end

            device = PSON.parse(res.body)
        elsif list.length > 1
            fail ["More than one existing device matches this hostname or fqdn. Please manually set token"]
        else
            device = list[0]

            # Has the group changed?
            existing_group = device["group"]

            if existing_group != group
                notice ["Updating group on #{device['_id']} from #{existing_group} to #{group}"]

                # update the group
                uri = URI("#{ base_url }/inventory/devices/#{ device['_id'] }?token=#{ token }")

                req = Net::HTTP::Put.new(uri.request_uri)

                update_data = {
                    :group => group
                }
                req.set_form_data(update_data)
                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
                https.verify_mode = OpenSSL::SSL::VERIFY_NONE
                res = https.start { |cx| cx.request(req) }

            end
        end

        agent_key = device["agentKey"]

        notice ["Agent Key: #{ agent_key }"]
        return agent_key
    end
end
