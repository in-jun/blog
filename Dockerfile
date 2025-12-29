FROM hugomods/hugo:latest AS builder
WORKDIR /src
COPY . .
RUN git clone --depth 1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod && \
    hugo --minify

FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]