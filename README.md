
ELK Notes


http://www.denniskanbier.nl/blog/logging/installing-logstash-on-rhel-and-centos-6/
http://blog.carlos-spitzer.com/2014/09/28/improving-linux-log-analysis-capabilities-with-logstash-elasticsearch-kibana/
http://www.thegeekstuff.com/2014/12/logstash-setup
https://github.com/elasticsearch/kibana/blob/kibana3/sample/nginx.conf
http://blog.comperiosearch.com/blog/2014/08/14/elk-one-vagrant-box/

Elasticsearch – http://localhost:9200/_plugin/head/
Kibana        – http://<IP address>/


curl 'http://localhost:9200/_search?pretty'




On ahlproc3
/data needs to be owned by elasticsearch:elasticsearch


curl -XGET ‘localhost:9200’
curl -XGET ‘localhost:80’

