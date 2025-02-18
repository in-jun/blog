FROM hugomods/hugo:latest as builder
WORKDIR /src
COPY .gitmodules .
COPY themes/PaperMod/themes.toml themes/PaperMod/
RUN git submodule update --init --recursive
COPY config.toml .
COPY hugo.toml .
COPY hugo.yaml .
COPY hugo.json .
COPY content/ content/
COPY static/ static/
COPY data/ data/
COPY assets/ assets/
COPY layouts/ layouts/
RUN hugo --minify

FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]