FROM alpine:latest
LABEL "Description"="############ STARTUP CONTAINER IMAGE  ###########"

RUN apk update
RUN apk add curl

COPY start.sh /start.sh
ADD  start.sh /start.sh

CMD ["./start.sh"]
