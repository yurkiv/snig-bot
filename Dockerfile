FROM ruby:2.5.0-alpine3.7

COPY . /
WORKDIR /

RUN apk add --update ruby-dev build-base && \
    bundle install && \
    apk del ruby-dev build-base tzdata
