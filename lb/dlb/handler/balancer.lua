local balancer = require "ngx.balancer"

local _M = {
    _VERSION = '0.0.1'
}

local counter = 0

-- balancer entry
function _M.start()
    -- upstream info
    -- set peer & timeouts
    -- failover
    -- TODO: 域名解析

    local upstream = {
        servers = {
            -- {
            --     ip = 'backend1',
            --     port = 80,
            --     -- weight = 1,
            -- },
            -- {
            --     ip = 'backend2',
            --     port = 80,
            --     -- weight = 2,
            -- },
            {
                ip = '172.17.0.1',
                port = 9000,
                -- weight = 1,
            },
            {
                ip = '172.17.0.1',
                port = 9001,
                -- weight = 2,
            },
        },
        timeouts = {
            -- in seconds
            connect_timeout = 0.1,
            read_timeout = 0.1,
            send_timeout = 0.1,
        }
    }

    -- for k, backend in pairs(upstream.servers) do
    --     ngx.log(ngx.INFO, '')
        
    -- end

    local state, status = balancer.get_last_failure()
    print("last peer failure: ", state, " ", status)
    if not ngx.ctx.tries then
        ngx.ctx.tries = 0
    end

    if ngx.ctx.tries < 2 then
        local ok, err = balancer.set_more_tries(1)
        if not ok then
            return error("failed to set more tries: ", err)
        elseif err then
            ngx.log(ngx.WARN, "set more tries: ", err)
        end
    end
    ngx.ctx.tries = ngx.ctx.tries + 1

    local server_num = #(upstream.servers) or 1
    local counter = (counter + 1) % server_num

    local ip = upstream.servers[counter+1].ip or nil
    local port = upstream.servers[counter+1].port or nil
    ngx.log(ngx.INFO, 'cur ip is ', tostring(ip))
    ngx.log(ngx.INFO, 'cur port is ', tostring(port))
    local ok, err = balancer.set_current_peer(ip, port)
    if not ok then
        ngx.log(ngx.ERR, "failed to set the current peer: ", err)
        return ngx.exit(500)
    end


    local connect_timeout = upstream.timeouts.connect_timeout
    local read_timeout = upstream.timeouts.read_timeout
    local send_timeout = upstream.timeouts.send_timeout
    ok, err = balancer.set_timeouts(connect_timeout, send_timeout, read_timeout)
    if not ok then
        ngx.log(ngx.ERR, 'failed to set the timeouts: ', err)
        return ngx.exit(500)
    end


end

return _M
