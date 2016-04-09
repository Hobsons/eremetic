FROM golang:1.5-alpine
RUN apk add --no-cache --virtual git
ADD . /go/src/github.com/Hobsons/eremetic
WORKDIR /go/src/github.com/Hobsons/eremetic
RUN go get -v -d
RUN go install -v github.com/Hobsons/eremetic
CMD [ "docker/marathon.sh" ]