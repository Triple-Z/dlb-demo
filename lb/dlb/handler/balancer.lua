local balancer = require "ngx.balancer"

local _M = {
    _VERSION = '0.0.1'
}

local function main()
    local state, status = balancer.get_last_failure()
    ngx.log(ngx.DEBUG, "last peer failure: ", state, " ", status)
    if not ngx.ctx.tries then
        ngx.ctx.tries = 0
    end
    
    if ngx.ctx.tries < 2 then
        local ok, err = balancer.set_more_tries(1)
        if not ok then
            ngx.log(ngx.ERR, "failed to set more tries: ", err)
            return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        elseif err then
            ngx.log(ngx.NOTICE, "set more tries: ", err)
        end
    end
    ngx.ctx.tries = ngx.ctx.tries + 1
    
    local cur_server = ngx.ctx.cur_server

    local ok, err = balancer.set_current_peer(cur_server.host, cur_server.port)
    if not ok then
        ngx.log(ngx.ERR, "failed to set the current peer: ", err)
        return ngx.exit(500)
    end

    local timeouts = ngx.ctx.timeouts
    local connect_timeout = timeouts.connect_timeout
    local read_timeout = timeouts.read_timeout
    local send_timeout = timeouts.send_timeout
    ok, err = balancer.set_timeouts(connect_timeout, send_timeout, read_timeout)
    if not ok then
        ngx.log(ngx.ERR, 'failed to set the timeouts: ', err)
        return ngx.exit(500)
    end
end

local function exception_handler(err)
    ngx.log(ngx.CRIT, "Balancer error: ", err)
end

-- balancer entry
function _M.start()
    xpcall(main, exception_handler)
end

return _M
