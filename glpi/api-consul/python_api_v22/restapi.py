# coding:utf-8

import sys
from flask import Flask, request, render_template
import sqlite3
import modules.user_db as userdb
import modules.user_kv_consul as consul

###
# CONFIGURATION
###

# Connection SQL
con = sqlite3.connect("interface_py.db", check_same_thread=False, timeout=5)
userdb.create_table(con, "users")
userdb.create_table(con, "KV")

# Definition of the Consul url host
# host = 'http://consul:8500'           # Between Container
# host = 'http://192.168.158.129:8500'  # From Host
# host = 'http://127.0.0.1:8500'        # From VM

# Exemple d'une Cle complète : '/v1/kv/mysqld/serverid'
# Prefix : '/v1/kv'  ,  clé client : mysqld/serverid
prefix_key = '/v1/kv/'
proxies = {"http": None, "https": None, }
headers = {'User-Agent': 'Mozilla/5.0'}
possible_hosts = ['http://consul:8500', 'http://192.168.158.129:8500', 'http://127.0.0.1:8500']

host = consul.check_and_set_kv_host(possible_hosts, proxies)
if not host:
    print("FATAL: aucun hôte disponible")
    sys.exit(2)


###
# Flask REST API
###


app = Flask(__name__)


@app.route("/")
def hello():
    return " Interface Python / v2.2 "


@app.route("/getval")
def getval():
    key = request.args.get('key')
    if not key:
        msg = "ERROR! Missing parameter 'key' in function calls"
        print(msg)
        return msg
    key = host + prefix_key + key
    print("/getval requested on ", key)
    val0 = str(consul.get_consul_val(key, proxies))
    operation = "Getval"
    keytext = "{}".format(key)
    valtext = "{}".format(val0)
    print("\tkeytext is '{}' ".format(keytext))
    print("\tvaltext is '{}' ".format(valtext))
    userdb.insert_into_kv(con, "KV", operation, keytext, valtext, request.url)
    print("\tValue to provide to Client: ", val0)
    return val0


@app.route("/incval")
def incval():
    key = request.args.get('key')
    if not key:
        msg = "ERROR! Missing parameter 'key' in function calls"
        print(msg)
        return msg
    key = host + prefix_key + key
    print("/incval requested on ", key)
    val1 = consul.get_consul_val(key, proxies)
    val2 = consul.inc_string_val(val1)
    consul.set_consul_val(key, val2)
    operation = "Incval"
    keytext = "{}".format(key)
    valtext = "{} => {}".format(val1, val2)
    print("\tkeytext is '{}' ".format(keytext))
    print("\tvaltext is '{}' ".format(valtext))
    userdb.insert_into_kv(con, "KV", operation, keytext, valtext, request.url)
    print("\tinitial value was %s, new value is : %s " % (val1, val2))
    return val2


@app.route("/decval")
def decval():
    key = request.args.get('key')
    if not key:
        msg = "ERROR! Missing parameter 'key' in function calls"
        print(msg)
        return msg
    key = host + prefix_key + key
    print("/decval requested on ", key)
    val1 = consul.get_consul_val(key, proxies)
    val2 = consul.dec_string_val(val1)
    consul.set_consul_val(key, val2)
    operation = "Decval"
    keytext = "{}".format(key)
    valtext = "{} => {}".format(val1, val2)
    print("\tkeytext is '{}' ".format(keytext))
    print("\tvaltext is '{}' ".format(valtext))
    userdb.insert_into_kv(con, "KV", operation, keytext, valtext, request.url)
    print("\tinitial value was %s, new value is : %s " % (val1, val2))
    return val2


@app.route("/setval")
def setval():
    val = request.args.get('val')
    key = request.args.get('key')
    if not key:
        msg = "ERROR! Missing parameter 'key' in function calls"
        print(msg)
        return msg
    if not val:
        msg = "ERROR! Missing parameter 'val' in function calls"
        print(msg)
        return msg
    key = host + prefix_key + key
    print("/setval requested on '{}' with value {}".format(key, val))
    consul.set_consul_val(key, val)
    operation = "Setval"
    keytext = "{}".format(key)
    valtext = "{}".format(val)
    print("\tkeytext is '{}' ".format(keytext))
    print("\tvaltext is '{}' ".format(valtext))
    userdb.insert_into_kv(con, "KV", operation, keytext, valtext, request.url)
    return str("\t" + keytext + valtext + "\n")


@app.route("/gethisto",  methods=['GET'])
def gethisto():
    table = request.args.get('table')
    if not table:
        msg = "ERROR! Missing 'table' parameter in request"
        print(msg)
        return msg
    con.row_factory = sqlite3.Row
    db = con.cursor()
    statement = """ select id, operation, key, val, url, date from %s """
    res = db.execute(statement % table)
    return render_template('item.html', listitem=res.fetchall())


# Tests
@app.route("/initdbpers", methods=['GET'])
def initdbpers():
    userdb.drop_table(con, "users")
    userdb.create_table(con, "users")
    userdb.populate_db(con, "users", 30)
    return "Init DB pers ok"


# To register a new Key
@app.route("/registerkey", methods=['GET', 'POST'])
def registerkey():
    # Handling form submitted by POST
    if request.method == 'POST':
        key = request.form['key']
        val = request.form['val']
        if not key or not val:
            return "Missing arguments 'key' or 'val'"
        else:
            url=request.host_url+"setval?key="+key+"&val="+val
            consul.set_consul_val(host + prefix_key + key, val)
            userdb.insert_into_kv(con, "KV", "Setval(Form)", key, val, url)
            return "key: " + key + " val: " + val

    # form to be displayed (GET method)
    else:
        print("Base url with port", request.host_url)
        return render_template('registerkey.html', host=host)


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
