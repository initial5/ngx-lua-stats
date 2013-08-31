----
local log_dict = ngx.shared.log_dict
local result_dict = ngx.shared.result_dict
---- 将字典中所有的值输出出来
for k,v in pairs(result_dict:get_keys())do
  ngx.say("key: ", v)
  ngx.say(result_dict:get(v))
end
