###### ETCD images
# A docker image that includes
# - etcd
FROM qnib/supervisor
MAINTAINER "Christian Kniep <christian@qnib.org>"

# haproxy
RUN yum install -y haproxy
ADD etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
ADD etc/supervisord.d/haproxy.ini /etc/supervisord.d/haproxy.ini

CMD /bin/supervisord -c /etc/supervisord.conf

