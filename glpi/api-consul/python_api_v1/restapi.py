import requests, json, base64, sys, os
from flask import Flask
from flask import request

####################
#
# CONFIGURATION
#
####################


# Determine if script is launched inside container or from shell
if os.environ.get('INCONTAINER'):
    host = 'consul'
else:
    host = '127.0.0.1'


scheme = 'http'
port   = '8500'
uri    = '/v1/kv/'
url    = scheme + '://' + host + ':' + port + uri

print("url for request: ", url)

# Default Values
defaultval = '1'


#####################
#
# Requests Configs
#
#####################

proxies = {
  "http": None,
  "https": None,
}
# this proxy setting is very important !
os.environ['NO_PROXY'] = host 
headers = {'User-Agent': 'Mozilla/5.0'}

####################
#
# FONCTIONS
#
####################


# Check & decode value from Consul (encoded in base64)
def getConsulVal(url):
    print("request : getConsulVal on ", url)
    print("proxies are : ", proxies)
    r = requests.get(url, proxies, headers=headers)
    print("Status Code: ", r.status_code)
    # If Key does not exist set to defaultVal
    # TODO suppress and 
    if r.status_code == 404:
        setConsulVal(url, defaultval)
        return defaultval
    o = json.loads(r.content)
    print("JSON CONTENT: ", o)
    valb64 = o[0]['Value']
    print("Value Retrieved base64: ",valb64)
    dec = base64.b64decode(valb64)
    print ("Value decoded: ", dec)
    return dec


# put value in consul KV
def setConsulVal(url, payload):
    print ("setConsulVal Payload : " , payload)
    print ("longueur du payload  : " , len(payload))
    putr = requests.put(url,data=payload)
    return putr.status_code


#increment String value
def incStringVal(strval):
    inc=int(strval)+1
    payload=str(inc)
    return payload


# decrement String value
def decStringVal(strval):
    dec = int(strval)-1
    # if value < defaultval we set it to defaultval
    if dec < int(defaultval) :
        dec = defaultval
    payload=str(dec)
    return payload


####################
#
# Flask REST API
#
####################

app = Flask(__name__)


@app.route("/")
def hello():
    hello = " Python-Consul API / Context: " + url
    return hello


@app.route("/getval")
def getval():
    key = request.args.get('key')
    print ("Requested key : " , key)
    urlcli = url + key
    print("/getval requested on ", urlcli)
    val0 = getConsulVal(urlcli)
    print("Value to provide to Client: ",val0)
    return val0


@app.route("/incval")
def incval():
    key = request.args.get('key')
    print ("Requested key : " , key)
    urlcli = url + key
    print("/incval requested on ", urlcli)
    val1 = getConsulVal(urlcli)
    val2 = incStringVal(val1)
    setConsulVal(urlcli, val2)
    print("initial value was %s, new value is : %s " %(val1, val2))
    return val2 


@app.route("/setval")
def setval():
    key = str(request.args.get('key'))
    print ("Requested key : " , key)
    value = str(request.args.get('value'))
    print ("Requested value : " , value)
    urlcli = url + key
    print("/setval requested on %s with value %s" %(urlcli, value))
    retval = "Response Code: " + setConsulVal(urlcli, value)
    return retval


@app.route("/decval")
def decval():
    key = request.args.get('key')
    print ("Requested key : " , key)
    urlcli = url + key
    print("/decval requested on ", urlcli)
    val1 = getConsulVal(urlcli)
    val2 = decStringVal(val1)
    setConsulVal(urlcli, val2)
    print("initial value was %s, new value is : %s " %(val1, val2))
    return val2 


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
