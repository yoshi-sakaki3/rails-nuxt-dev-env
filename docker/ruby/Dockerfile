# Ruby on Rails（開発用）
ARG RUBY_VERSION=4.0
FROM ruby:${RUBY_VERSION}-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential git libpq-dev libyaml-dev pkg-config curl \
 && rm -rf /var/lib/apt/lists/*

# gem はコンテナ側（/usr/local/bundle のボリューム）に置く
ENV TZ=Asia/Tokyo \
    LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4

RUN gem install rails --no-document

WORKDIR /app
