local balancer = require "ngx.balancer"

local _M = {
    _VERSION = '0.0.1'
}

local counter = 0

local function main()
    -- upstream info
    -- set peer & timeouts
    -- failover
    -- TODO: Weight RR

    local upstream = {
        servers = {
            {
                host = '172.28.0.101',
                port = 80,
                -- weight = 1,
            },
            {
                host = '172.28.0.102',
                port = 80,
                -- weight = 2,
            }
        },
        timeouts = {
            -- in seconds
            connect_timeout = 0.1,
            read_timeout = 0.1,
            send_timeout = 0.1,
        }
    }

    -- Round robin
    local server_num = #(upstream.servers) or 1
    counter = counter % server_num + 1
    
    local cur_server = upstream.servers[counter]

    local host = cur_server.host
    local port = cur_server.port
    ngx.log(ngx.INFO, 'cur host is ', tostring(host))
    ngx.log(ngx.INFO, 'cur port is ', tostring(port))

    if (not host) or (not port) then
        ngx.log(ngx.ERR, "can NOT get the upstream ip or port!")
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    
    ngx.ctx.cur_server = cur_server
    ngx.ctx.timeouts = upstream.timeouts
end

local function exception_handler(err)
    ngx.log(ngx.CRIT, "Upstream error: ", err)
end

-- upstream entry
function _M.start()
    xpcall(main, exception_handler)
end

return _M
