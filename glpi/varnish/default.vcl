#
# Please Note 2 BackEnd are required with these name
#
vcl 4.0;
import directors;

# Backend probes / healthchecks */
# See https://www.varnish-cache.org/docs/4.0/reference/vcl.html#probes
probe basic {
    .request =
	 "GET / HTTP/1.1"
	 "Host: 127.0.0.1"
	 "Connection: close"
	 "User-Agent: Varnish healthcheck";

    .interval = 10s;
    .timeout = 2s;
    .window = 8;
    .threshold = 6;
 }

# Node Definition
backend nodephp {
    .host = "nodephp";
    .port = "80";
    .max_connections = 100;
    .connect_timeout = 6s;
    .first_byte_timeout = 6s;
    .between_bytes_timeout = 6s;
    .probe = basic;
}
#backend node2 {
#    .host = "node2";
#    .port = "80";
#    .max_connections = 100;
#    .connect_timeout = 6s;
#    .first_byte_timeout = 6s;
#    .between_bytes_timeout = 6s;
#    .probe = basic;
#}
sub vcl_init {
    new apache = directors.round_robin();
    apache.add_backend(nodephp);
#    apache.add_backend(node2);
}

sub vcl_recv {

  # send all traffic to the apache director:
  set req.backend_hint = apache.backend();

  unset req.http.Vary;

  if (req.url ~ "login") {
    return(pass);
  }

  set req.http.X-Forwarded-For = client.ip;
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|lzma|tbzi|jpeg|)(\?.*|)$") {
        unset req.http.Accept-Encoding;
        return(hash);
    } elsif (req.http.Accept-Encoding ~ "gzip") {
        set req.http.Accept-Encoding = "gzip";
    } elsif (req.http.Accept-Encoding ~ "deflate") {
        set req.http.Accept-Encoding = "deflate";
    } else {
        unset req.http.Accept-Encoding;
    }
  }

    set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");
    if (req.http.Cookie ~ "^\s*$") {
      unset req.http.Cookie;
    }

    # Remove cookies for static files
    if (req.url ~ "\.(gif|jpg|jpeg|swf|css|js|flv|mp3|mp4|pdf|ico|png|tif|tiff|mp3|htm|html|md5|map|woff)(\?.*|)$") {
        unset req.http.cookie;
        return(hash);
    }

    if (req.http.Cookie == "") {
       # If there are no more cookies, remove the header to get page cached.
       unset req.http.Cookie;
    }

}

#
sub vcl_backend_response {

    # If the backend fails, keep serving out of the cache for 30m
    set beresp.grace = 30m;
    set beresp.ttl = 48h;

    # Remove some unwanted headers
    unset beresp.http.Server;
    unset beresp.http.X-Powered-By;

    # Respect the Cache-Control=private header from the backend
    if (beresp.http.Cache-Control ~ "private") {
        set beresp.http.X-Cacheable = "NO:Cache-Control=private";
    } elsif (beresp.http.Cache-Control ~ "no-store") { 
        set beresp.http.X-Cacheable = "NO:Cache-Control=no-store";
    } elsif (beresp.ttl < 1s) {
        set beresp.ttl   = 120s;
        set beresp.grace = 5s;
        set beresp.http.X-Cacheable = "YES:FORCED";
    } else {
        set beresp.http.X-Cacheable = "YES";
    }

    # Don't cache responses to posted requests or requests with basic auth
    if ( bereq.method == "POST" || bereq.http.Authorization ) {
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;
        return (deliver);
    }

    # Cache error pages for a short while
    if( beresp.status == 404 || beresp.status == 500 || beresp.status == 301 || beresp.status == 302 ){
        set beresp.ttl = 1m;
        return(deliver);
    }

    # Do not cache non-success response
    if( beresp.status != 200 ){
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;
        return(deliver);
    }

   return (deliver);
}

#
sub vcl_deliver {

  # Add debugging headers to cache requests
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }
}
