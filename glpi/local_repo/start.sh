# To find the directory of this script
HTTPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "------------------------------------------------------------"
echo "Starting to launch Python container for serving $HTTPDIR ..."
echo "------------------------------------------------------------"
echo ""

echo "docker run -d --rm --name http-server --network=glpi_admin -p 6789:6789 -v \"$HTTPDIR\":/usr/src/myapp -w /usr/src/myapp python:rc-alpine python httpserv.py"
docker run -d --rm --name http-server --network=glpi_admin -p 6789:6789 -v "$HTTPDIR":/usr/src/myapp -w /usr/src/myapp python:rc-alpine python httpserv.py

