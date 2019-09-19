# coding:utf-8

import requests
import json
import base64
import os


###
# Check Connection On KV
###

def check_host_connection(host, proxies):
    try:
        r = requests.get(host, timeout=2, proxies=proxies)
        r.raise_for_status()
    except requests.exceptions.HTTPError as errH:
        print("\tmessage: HTTP Error", errH)
        raise("KVConnectionError")
    except requests.exceptions.ConnectionError as errC:
        print("\tmessage: Connection Error", errC)
        raise ("KVConnectionError")
    except requests.exceptions.Timeout:
        print("\tmessage: Timeout Error")
        raise ("KVConnectionError")
    except requests.exceptions.RequestException:
        print("\tOOps: Something Else")
        raise("KVConnectionError")


def check_and_set_kv_host(possible_hosts, proxies):
    print("\nChecking Connection on KV host ")

    activehost = ""
    for h in possible_hosts:
        hostname = h[7:-5]
        print("\nTesting ", h)
        print("\tHost: ", hostname)
        # this proxy setting is very important !
        os.environ['NO_PROXY'] = hostname
        try:
            print("\tChecking connection ...")
            check_host_connection(h, proxies)
        except:
            print("\tErreur de Connection")
        else:
            print("\n[+] Sucessfull Connection to {} \n".format(h))
            activehost = h
            break
        finally:
            if not activehost:
                print("\tConnection non Disponible sur cet hote")
            else:
                return activehost


# Check & decode value from Consul (encoded in base64)
def get_consul_val(url, proxies, defaultval="UNINITIALIZED"):
    print("\n---entering get_consul_val---\n")
    print("\trequest : getConsulVal on ", url)
    print("\tproxies are : ", proxies)
    r = requests.get(url, proxies)
    print("\tStatus Code: ", r.status_code)
    # If Key does not exist set to defaultVal
    if r.status_code == 404:
        set_consul_val(url, defaultval)
        return defaultval
    o = json.loads(r.content)
    print("\tJSON CONTENT: ", o)
    valb64 = o[0]['Value']
    print("\tValue Retrieved base64: ", valb64)
    dec = base64.b64decode(valb64)
    print("\tValue decoded: ", dec)
    print("\tType of value: ", type(dec))
    print("\n---end of get_consul_val---\n")
    return str(dec.decode())


# put value in consul KV
def set_consul_val(url, payload):
    print("\n---entering set_consul_val---\n")
    print("\tsetConsulVal Payload : ", payload)
    print("\tlongueur du payload  : ", len(payload))
    putr = requests.put(url, data=payload)
    print("\n---end of set_consul_val---\n")
    return putr.status_code


# increment String value
def inc_string_val(strval):
    inc = int(strval)+1
    payload = str(inc)
    return payload


# decrement String value
def dec_string_val(strval, defaultval):
    dec = int(strval)-1
    # if value < defaultval we set it to defaultval
    if dec < int(defaultval):
        dec = defaultval
    payload = str(dec)
    return payload
