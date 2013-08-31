## 介绍

    以前我们为nginx做统计,都是通过对日志的分析来完成.比较麻烦,现在基于ngx_lua插件,开发了实时统计站点状态的脚本,解放生产力.

## 功能

- 支持分不同虚拟主机统计, 同一个虚拟主机下可以分不同的location统计.
- 可以统计与query-times request-time status-code speed 相关的数据.


## 环境依赖

- nginx + ngx_http_lua_module

## 安装

```
http://wiki.nginx.org/HttpLuaModule#Installation
```

## 使用方法

### 添加全局字典
                     
在nginx的配置中添加dict的初始化, 类似如下

```
lua_shared_dict log_dict 20M;
lua_shared_dict result_dict 20M;
```

### 为特定的location添加统计

只需要添加一句即可~~
将lua脚本嵌套进nginx的配置中, 例如:

```
server {
        listen 8080;
        server_name weatherapi.market.xiaomi.com;
        access_log  /home/work/nginx/logs/weatherapi.market.xiaomi.com.log milog;
        location / {
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_pass  http://weatherapi.market.xiaomi.com_backend;

                log_by_lua_file ./site-enable/record.lua;
        }
}

```

### 输出结果

通过配置一个server, 使得可以通过curl获取到字典里的所有结果

```
server {
    listen 8080 default;
    server_name  _;

    location / {
        return 404;
    }

    location /status {
        content_by_lua_file ./site-enable/output.lua;
    }

    location /empty_dict {
        content_by_lua_file ./site-enable/empty_dict.lua;
    }
}
```

可以通过如下命令获取

```
curl ip_addr:8080/status
```

### 清理字典
运行一段时间之后, 字典会变大. 可以通过如下接口清理

```
curl ip_addr:8080/empty_dict
```

### 支持的统计数据说明

目前支持统计以下数据,返回的原始数据类似于

```

--------------------------
key: weatherapi.market.xiaomi.com__upstream_time_10.0.3.32:8250_counter
0.375
key: weatherapi.market.xiaomi.com__upstream_time_10.0.3.32:8250_nb_counter
124
key: weatherapi.market.xiaomi.com__upstream_time_10.0.4.93:8250_counter
0.131
key: weatherapi.market.xiaomi.com__upstream_time_10.0.4.93:8250_nb_counter
123
key: weatherapi.market.xiaomi.com__upstream_time_10.20.12.49:8250_counter
0.081
key: weatherapi.market.xiaomi.com__upstream_time_10.20.12.49:8250_nb_counter
127
key: weatherapi.market.xiaomi.com__query_counter
500
key: weatherapi.market.xiaomi.com__request_time_counter
0.683
key: weatherapi.market.xiaomi.com__upstream_time_counter
0.683
key: weatherapi.market.xiaomi.com__upstream_time_10.20.12.59:8250_counter
0.096
key: weatherapi.market.xiaomi.com__upstream_time_10.20.12.59:8250_nb_counter
126
key: weatherapi.market.xiaomi.com__bytes_sent_counter
81500

```

其中 __ 用来分割虚拟主机(包含prefix)与后面的数据项，便于数据处理.
counter表示此值一直在累加
nb表示次数


可以得到的数据包括: query次数 request_time bytes_sent upstream_time
其中 upstream_time_10.20.12.49:8250_counter 表示到某个特定后端的upstrea_time耗时累加
upstream_time_10.20.12.49:8250_nb_counter 表示到到某个特定后端的upstrea_time次数累加


## 如何处理数据

```
   因为采集到的数据大多都是counter值,需要监控系统支持对于delta的处理.目前我们公司的perf-counter监控系统支持简单运算。所以这个处理起来比较简单，对于没有这种系统的同学来说，需要自己处理数据,得到delta值以及更复杂的数据。
   比如 delta(bytes_sent_counter)/delta(query_counter) 得到就是这段时间的http传输速度
   delta(upstream_time_10.20.12.49:8250_counter)/delta(upstream_time_10.20.12.49:8250_nb_counter) 得到的就是这个后端upstream_time的平均值
```

## ToDo

  对于percentile的支持是下一步的重点计划.


## Help!
  联系 xiedanbo &lt;xiedanbo@xiaomi.com&gt;
