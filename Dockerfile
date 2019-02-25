FROM ruby:2.3.3

WORKDIR /workdir
ADD . /workdir

RUN apt update && \
    apt install -y nodejs vim
RUN gem install bundler
RUN bundle

EXPOSE 3030
CMD ["smashing", "start"]

