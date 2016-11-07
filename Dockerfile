FROM phusion/baseimage:0.9.18

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Seafile client" \
      org.label-schema.description="An interface less seafile client docker image" \
      org.label-schema.license="MIT" \
      org.label-schema.vendor="strator-dev" \
      org.label-schema.url="https://github.com/strator-dev/docker-seafile-client" \
      org.label-schema.vcs-url="https://github.com/strator-dev/docker-seafile-client" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc.1"

ADD script.sh /tmp/script.sh
RUN /bin/bash /tmp/script.sh
