
---- log_dict做临时记录用 result_dict记录最终需要采集的数据
local log_dict = ngx.shared.log_dict
local result_dict = ngx.shared.result_dict


---- 用server 和 location来作为标示. localtion通过对uri的处理拿到
local server_name = ngx.var.server_name
local uri = ngx.var.uri
local var_prefix = server_name.."_"
local m, err = ngx.re.match(uri, "(/[0-9a-zA-Z]+)(/[0-9a-zA-Z]+)", "ix")

-- var_prefix是每个站点+location的标示, 以__作为分界, 便于数据处理
if m then
  if m[1] then
    local var_prefix = server_name.."_"..m[1].."_"
  else
    local var_prefix = server_name.."_"..m[0].."_"
  end
else
  var_prefix = server_name.."_"
end


---- 请求次数统计, counter
query_nb_var = var_prefix.."_query_counter"

local newval, err = result_dict:incr(query_nb_var, 1)
if not newval and err == "not found" then
    result_dict:add(query_nb_var, 0)
    result_dict:incr(query_nb_var, 1)
end


---- request_time统计, counter
request_time_var = var_prefix.."_request_time_counter"

local request_time = tonumber(ngx.var.request_time)

local sum = result_dict:get(request_time_var) or 0
sum = sum + request_time
result_dict:set(request_time_var, sum)


---- upstream_time统计, counter
upstream_time_var = var_prefix.."_upstream_time_counter"

local upstream_time = tonumber(ngx.var.upstream_response_time)

local sum = result_dict:get(upstream_time_var) or 0
sum = sum + upstream_time
result_dict:set(upstream_time_var, sum)


---- upstream_time_addr统计, counter
local upstream_addr = ngx.var.upstream_addr
upstream_time_addr_var = var_prefix.."_upstream_time_"..upstream_addr.."_counter"

local upstream_time_addr = tonumber(ngx.var.upstream_response_time)

local sum = result_dict:get(upstream_time_addr_var) or 0
sum = sum + upstream_time_addr
result_dict:set(upstream_time_addr_var, sum)

-- upstream_time_addr记录query次数的累加器, counter
upstream_time_addr_nb_var = var_prefix.."_upstream_time_"..upstream_addr.."_nb_counter"

local newval, err = result_dict:incr(upstream_time_addr_nb_var, 1)
if not newval and err == "not found" then
    result_dict:add(upstream_time_addr_nb_var, 0)
    result_dict:incr(upstream_time_addr_nb_var, 1)
end



---- bytes_sent累加, 便于做speed统计, counter
bytes_sent_var = var_prefix.."_bytes_sent_counter"

local bytes_sent = tonumber(ngx.var.bytes_sent)

local sum = result_dict:get(bytes_sent_var) or 0
sum = sum + bytes_sent
result_dict:set(bytes_sent_var, sum)


---- 状态码统计, 4xx, 5xx, counter
local status_code = tonumber(ngx.var.status)
status_code_4xx_nb_var = var_prefix.."_status_code_4xx_counter"
status_code_5xx_nb_var = var_prefix.."_status_code_5xx_counter"

local status_code_4xx_nb = result_dict:get(status_code_4xx_nb_var) or 0
if status_code >= 400 then
        local newval, err = result_dict:incr(status_code_4xx_nb_var, 1)
        if not newval and err == "not found" then
            result_dict:add(status_code_4xx_nb_var, 0)
            result_dict:incr(status_code_4xx_nb_var, 1)
        end
end

local status_code_5xx_nb = result_dict:get(status_code_5xx_nb_var ) or 0
if status_code >= 500 then
        local newval, err = result_dict:incr(status_code_5xx_nb_var, 1)
        if not newval and err == "not found" then
            result_dict:add(status_code_5xx_nb_var, 0)
            result_dict:incr(status_code_5xx_nb_var, 1)
        end
end
