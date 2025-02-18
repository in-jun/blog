FROM hugomods/hugo:latest as builder
WORKDIR /src
COPY . .
RUN git submodule update --init --recursive && \
    hugo --minify

FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]