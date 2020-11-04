FROM ruby:2.5.5-alpine3.10

COPY . /
WORKDIR /

RUN apk add --update ruby-dev build-base && \
    bundle install && \
    apk del ruby-dev build-base tzdata
