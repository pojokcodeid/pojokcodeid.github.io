# Image penuh (bukan -slim): sudah berisi gcc, make, dan git,
# jadi tidak perlu apt-get saat build.
FROM docker.io/library/ruby:3.3

ENV LANG=C.UTF-8 \
    JEKYLL_ENV=development

WORKDIR /srv/jekyll

# Gem di-cache di layer ini; build ulang hanya saat Gemfile berubah
COPY Gemfile* ./
RUN bundle config set --local jobs 2 && bundle install

EXPOSE 4000 35729

CMD ["bundle", "exec", "jekyll", "serve", \
     "--host", "0.0.0.0", \
     "--livereload", "--force_polling", \
     "--drafts", "--future"]
