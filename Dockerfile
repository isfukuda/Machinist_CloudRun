FROM nginx:alpine
COPY html /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

CMD sh -c "nginx -g 'daemon off;'"
