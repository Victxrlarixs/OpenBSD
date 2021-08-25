# Intro

```
My website automatically redirects users from http to https and this gets achieved using a simple 
redirection in /etc/httpd.conf So if you have a configuration similar to mine, then you will still 
want to have httpd listenon the egress interface on port 80. The key thing to change here is to have
httpd listen on 127.0.0.1 on port 443.
```
_ _ _ 
```
prefork 5
include {types "/usr/share/misc/mime.types"}

server "default" {
		listen on egress port 80
		root "/htdocs"
		index "index.html"

		location "/htdocs*" {
			block return 403
		}
}

server "example.com" {
        listen on egress port 80
        alias "www.example.com"
        block return 302 "https://$SERVER_NAME$REQUEST_URI"
}

server "example.com" {
        listen on localhost tls port 443
        alias "www.example.com"
        root "/htdocs/example"
        directory index "index.html"

        log {
                style forwarded
                access "access-www.log"
                error "error-www.log"
        }

        tcp {
                nodelay
                sack
                backlog 10
        }

        tls {
                certificate "/etc/ssl/example.com.crt"
                key "/etc/ssl/private/example.com.key"
        }
}
```
_ _ _ 

# Commit

```
The key thing to note here, again, is that example.com is also listening on the localhost on port 443. 
This is necessary to maintain the Strict Transport Security integrity intact. Failing to do this may 
result in some unintended consequences like parts of your website not rendering correctly. 
Also, I’ve changed the style of logging to forwarded so that I can see the actual IP address of the client. 
The next step is creating the configuration file for /etc/relayd.conf. 
I also want to be able to support IPv6 because traffic on IPv6 is only going to increase.
```
_ _ _ 
```
prefork 5

http protocol "https" {
        match request header set "X-Forwarded-For" \
                value "$REMOTE_ADDR:$REMOTE_PORT"
        match request header set "X-Forwarded-By" \
                value "$SERVER_ADDR:$SERVER_PORT"
        match request header set "X-Forwarded-Proto" \
                value "https"

		match response header remove "Server"
        match response header set "Strict-Transport-Security" \
                value "max-age=31536000"
        match response header set "X-Frame-Options" \
                value "sameorigin"
        match response header set "X-XSS-Protection" \
                value "1; mode=block"
        match response header set "X-Content-Type-Options" \
                value "nosniff"
        match response header set "Referrer-Policy" \
                value "no-referrer-when-downgrade"
        match response header set "Feature-Policy" \
                value "camera 'none'; microphone 'none'"
        
        tcp {nodelay, sack, backlog 10}

        tls keypair example.com
}

relay "www" {
        listen on egress port 443 tls
        protocol "https"
        forward with tls to 127.0.0.1 port 443
}

relay "www6" {
        listen on 2001:19f0:5:128d::1 port 443 tls
        protocol "https"
        forward with tls to ::1 port 443
}
```
_ _ _ 

# Commit

```
From here it is simply a matter of enabling and starting relayd and reloading the configuration for httpd. 
Once you do this, check your website at securityheaders.com. This setting will give you an A score. 
The only thing I have yet to figure out is the Content Security Policy header.
```

@author: https://goblackcat.com/posts/using-openbsd-relayd-to-add-security-headers/
