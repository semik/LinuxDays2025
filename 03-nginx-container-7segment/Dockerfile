FROM semik-debian

# Install busybox, bash, and any image dependencies (e.g., imagemagick, png tools, etc)
RUN apt-get update && apt-get install -y bash busybox imagemagick&& apt-get clean

# Copy entrypoint script
COPY entrypoint.sh /

# Copy scripts
COPY cgi-bin/ /app/cgi-bin/
COPY alive.txt /app/

# Make CGI executable
RUN chmod +x /app/cgi-bin/*.sh /entrypoint.sh

# Start busybox httpd with CGI enabled
EXPOSE 8080

# CMD ["busybox", "httpd", "-vv", "-f", "-p", "8080", "-h", "/app"]
# bussybox httpd ignores TERM signal, so we need a wrapper script to handle shutdown faster
CMD [ "/entrypoint.sh" ]
