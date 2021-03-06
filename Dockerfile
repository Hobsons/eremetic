FROM golang:1.5-alpine
RUN apk add --no-cache --virtual git
ADD . /go/src/github.com/Hobsons/eremetic
WORKDIR /go/src/github.com/Hobsons/eremetic
RUN mv scheduler.go /scheduler.go
RUN go get -v -d
RUN mv /scheduler.go /go/src/github.com/mesos/mesos-go/scheduler/scheduler.go
RUN go install -v github.com/Hobsons/eremetic
CMD [ "docker/marathon.sh" ]
