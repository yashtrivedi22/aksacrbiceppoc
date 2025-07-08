FROM nginx
RUN echo "<h1>Hello from AKS deployed via GitHub Actions + Helm!</h1>" > /usr/share/nginx/html/index.html
