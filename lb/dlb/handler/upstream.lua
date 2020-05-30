local balancer = require "ngx.balancer"

local _M = {
    _VERSION = "0.0.1"
}

local counter = 0

-- Round robin
--@param upstream table  upstream info.
--@return number  server index in upstream table.
local function round_robin(upstream)
    local server_num = #(upstream.servers)
    if not server_num or server_num == 0 then
        ngx.log(ngx.ERR, "the number of server is NIL or ZERO!")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    counter = counter % server_num + 1
    return counter
end

local weight_servers = nil
-- Weighted round robin
--@param upstream table  upstream info.
--@return number  server index in upstream table.
local function weighted_round_robin(upstream)
    if not weight_servers then
        -- init the weights array
        weight_servers = {}
        for i, server in ipairs(upstream.servers) do
            for j = 1, server.weight do
                server.index = i
                weight_servers[#weight_servers + 1] = server
                ngx.log(ngx.DEBUG, "init the ", #weight_servers, " server")
            end
        end
        ngx.log(ngx.DEBUG, "weighted inited")
    end

    local server_num = #weight_servers
    if not server_num or server_num == 0 then
        ngx.log(ngx.ERR, "the number of server is NIL or ZERO!")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    counter = counter % server_num + 1
    return weight_servers[counter].index
end

local function get_balance_algo(algo_str)
    if not algo_str then
        algo_str = "rr"
    end

    local balance_algo = {
        rr = round_robin,
        wrr = weighted_round_robin
    }

    local cur_algo = balance_algo[string.lower(algo_str)]

    if not cur_algo then
        return balance_algo["rr"]
    else
        return cur_algo
    end
end

local function main()
    -- upstream info
    local upstream = {
        lb_method = "wrr",
        servers = {
            {
                host = "172.28.0.101",
                port = 80,
                weight = 3
            },
            {
                host = "172.28.0.102",
                port = 80,
                weight = 2
            }
        },
        timeouts = {
            -- in seconds
            connect_timeout = 0.1,
            read_timeout = 0.1,
            send_timeout = 0.1
        }
    }

    local cur_server = nil

    -- get selected server index from load balance algorithm(s)
    local selected_index = get_balance_algo(upstream.lb_method)(upstream)
    ngx.log(ngx.DEBUG, "get selected index: ", selected_index)

    cur_server = upstream.servers[selected_index]

    local host = cur_server.host
    local port = cur_server.port
    ngx.log(ngx.DEBUG, "cur host is ", tostring(host))
    ngx.log(ngx.DEBUG, "cur port is ", tostring(port))

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
