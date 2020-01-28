# Intro

```
In a “get pretty graphs” mood, I’m looking at what can be done regarding OpenBSD monitoring using the CollectD 
collector and Grafana dashboard renderer. OpenBSD 6.2-current provides InfluxDB and Grafana packages. 
A great stack for pretty reportings.
```
_ _ _ 

# Host the data

```
# pkg_add influxdb
# vi /etc/influxdb/influxdb.conf
(...)
[[collectd]]
  enabled = true
  bind-address = ":25826"
  database = "collectd"
  retention-policy = ""
  typesdb = "/usr/local/share/collectd"

# rcctl enable influxdb
# rcctl start influxdb

# netstat -na | grep 25826
udp 0 0 *.25826 *.*
```



# Collect the data

```
# pkg_add collectd
# vi /etc/collectd.conf
(...)
<Plugin network>
  <Server "127.0.0.1" "25826">
  </Server>
  ReportStats true
</Plugin>

# rcctl enable collectd
# rcctl start collectd
```


# Render the data

```
# pkg_add grafana
# vi /etc/grafana/config.ini

# rcctl enable grafana
# rcctl start grafana
```

# SetUP

```
Browse to http://localhost:3000/ and log in using the default credentials (admin:admin). 
Those can be changed this way http://docs.grafana.org/installation/configuration/#security and from the GUI.
```


