#!/bin/bash
# script to correctly restart varnish after configuration change by confd
# NB to write on varnishlog we use the proc fd 1 (std out)

# to find varnishlog process to enable to write in pipe
out=$(ps -aux | grep varnishlog | grep -v grep | tr -s " " | cut -d " " -f2);

echo "Reloading varnish configuration properly ..." > /proc/$out/fd/1

#kill all varnishd jobs
for job in $(ps -aux | grep varnishd | grep -v grep | tr -s " " | cut -d " " -f2) ; do
echo "...Killing varnishd job  $job ..." > /proc/$out/fd/1
kill -9 $job
done

echo "...restarting varnish..." > /proc/$out/fd/1
service varnish restart

echo "Varnish configuration reloaded !" > /proc/$out/fd/1
