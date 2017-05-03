FROM ruby:2.3.1
RUN apt-get update -qq && \
  apt-get upgrade -y && \
  apt-get install -y build-essential libpq-dev postgresql-client

RUN mkdir /app
WORKDIR /app

ENV BUNDLE_GEMFILE=/app/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

ENV PATH=./bin:$PATH
ENV RAILS_ENV=test

ADD . /app
