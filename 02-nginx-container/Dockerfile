FROM semik-debian

RUN apt-get update && apt-get install -y nginx && apt-get clean

CMD ["nginx", "-g", "daemon off;"]
# EXPOSE 80