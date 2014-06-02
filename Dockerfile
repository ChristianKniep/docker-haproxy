###### ETCD images
# A docker image that includes
# - etcd
FROM qnib-supervisor
MAINTAINER "Christian Kniep <christian@qnib.org>"

# haproxy
RUN yum install -y haproxy
ADD etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
ADD etc/supervisord.d/haproxy.ini /etc/supervisord.d/haproxy.ini
ADD root/bin/start_haproxy.sh /root/bin/start_haproxy.sh

CMD /bin/supervisord -c /etc/supervisord.conf
