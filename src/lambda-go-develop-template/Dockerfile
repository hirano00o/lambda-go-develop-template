FROM alpine as build

RUN apk add go git
RUN go env -w GOPROXY=direct

ADD go.mod go.sum ./
RUN go mod download

ADD .. .
RUN go build -o /main

FROM alpine
COPY --from=build /main /main

# (Optional) Add Lambda Runtime Interface Emulator and use a script in the ENTRYPOINT for simpler local runs
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
RUN chmod 755 /usr/bin/aws-lambda-rie
COPY entry.sh /
RUN chmod 755 /entry.sh
ENTRYPOINT [ "/entry.sh" ]
