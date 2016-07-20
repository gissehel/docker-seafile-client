FROM phusion/baseimage:0.9.18

ADD script.sh /tmp/script.sh
RUN /bin/bash /tmp/script.sh
