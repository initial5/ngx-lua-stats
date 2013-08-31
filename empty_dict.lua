----
local log_dict = ngx.shared.log_dict
local result_dict = ngx.shared.result_dict
---- 将字典中每个key的值重置为0
for k,v in pairs(result_dict:get_keys())do
  result_dict:set(v, 0)
  log_dict:set(v, 0)
end
