# Intro

```

If you are using OpenBSD to add security headers to your website, it is only natural to want
to block the bad robot crawlers out there that just hammer your website in the hope that 
you visit the bot’s web page and purchase their services; because there’s nothing like (sic) 
getting people to your website like doing nefarious things.

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
   
		include "/etc/relayd.rules"
     
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
Take special note of the include statement inside the protocol "https" block. 
This is statement will be used to easily load the set of rules for blocking the bad robots. 
The contents of /etc/relayd.rules is below:
```
_ _ _ 
```
block request header "User-agent" value "*Alpha*"
#block request header "User-agent" value "*Ahref*"
block request header "User-agent" value "*Baidu*"
block request header "User-agent" value "*Sogou*"
#block request header "User-agent" value "*Semrush*"
block request header "User-agent" value "*Yandex*"
block request header "User-agent" value "*YaK*"
#block request header "User-agent" value "*PaperLi*"
block request header "User-agent" value "*Buck*"
block request header "User-agent" value "*masscan*"
block request header "User-agent" value "*SearchAtlas*"
block request header "User-agent" value "*SMUrl*"
block request header "User-agent" value "*Twingly*"
block request header "User-agent" value "*Twitterbot*"
block request header "User-agent" value "*zh-CN*"
block request header "User-agent" value "*zh_CN*"
block request header "User-agent" value "*Mb2345*"
block request header "User-agent" value "*LieBaoFast*"
block request header "User-agent" value "*MicroMessenger*"
block request header "User-agent" value "*Snappy*"
block request header "User-agent" value "*QQ*"
block request header "User-agent" value "*Youdao*"
block request header "User-agent" value "*Aspiegel*"
block request header "User-agent" value "*Dalvik*"
block request header "User-agent" value "*Dispatch/0.11*"
block request header "User-agent" value "*Internet-*"
block request header "User-agent" value "*Nimbostratus*"
block request header "User-agent" value "*Researchscan*"
block request header "User-agent" value "*MojeekBot*"
block request header "User-agent" value "*SRA/SMA*"
block request header "User-agent" value "*Hash*"
return error style "body { background: white; color: black; }"
```
_ _ _ 

# Commit

```
All you have to do is comment out the robots that you want to crawl your site. 
To add them use the * before and after the name. 
This will ensure that your rule matches no matter where the bot name appears in the user agent string. 
Enjoy log silence from the bad robots.
```

@author: https://goblackcat.com/posts/using-openbsd-relayd-to-block-bad-robots/
