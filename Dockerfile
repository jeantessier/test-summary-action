#
# Based on the official Ruby image: https://hub.docker.com/_/ruby
#
# To build:
#     $ docker build . --tag jeantessier/test-summary-action:1.0.5 --tag jeantessier/test-summary-action:latest
#
# To upload to hub.docker.com:
#     $ docker push jeantessier/test-summary-action:1.0.5
#     $ docker push jeantessier/test-summary-action:latest
#

FROM ruby:latest

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# GitHub Actions resets WORKDIR to /github/workspace, so we have to reference
# the install path directl.
ENTRYPOINT ["/usr/src/app/entrypoint.rb"]
