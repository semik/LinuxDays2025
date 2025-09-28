---
marp: true
paginate: true
theme: semikova

---

# Kubernetes pro dinosaury

Jan Tomášek <jan@tomasek.cz>

Linux Days 2025
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;

![bg right:50% w:500](img/t-rex4.png)

---
# Představení

## Administrátor & Vývojář v CESNET, z.s.p.o. --- 21 let</h2>
- eduroam, eduID, CESNET IdM + PKI

<div data-marpit-fragment>

## Platform Engineer v 3Key Company, s.r.o. --- od 11/2022

</div>

<div data-marpit-fragment>

## 3Key Company vyvíjí platformu [CZERTAINLY](https://www.czertainly.com/):
- Digitální Certifikáty
- Digitální podpisy dle eIDAS
- Open Source &  <ins>Cloud Native</ins>

</div>


---

# Vývoj sdílení výpočetního výkonu
![](img/BareMetal-Virtualized-Containerized-4.png)

---
# Proč se zajímat o Kontejnery?
<div class="twocols">

## Obsahují
- aplikaci
* závislosti = knihovny
&nbsp;
&nbsp;
&nbsp;
&nbsp;

<p class="break"></p>

<div data-marpit-fragment>

## Neobsahují
* data
* konfiguraci
* kernel
* init systém
* ssh server
</div>
</div>

---

# A proč se o Kubernetes zajímat?

* Nejrozšířenější orchestrátor kontejnerů
* Efektivní využití výpočetního výkonu
* **Dokumentace** instalace aplikace
* ...

---
# Ukázka dokumentace instalace EJBCA

```yaml
ejbca:
  useEphemeralH2Database: false
  env:
    DATABASE_JDBC_URL: jdbc:postgresql://dbserver.3key.company:5432/ejbca
  env:
    - name: DATABASE_PASSWORD
      value: supertajne-heslo
    - name: DATABASE_USER
      value: ejbca-user

services:
  directHttp:
    enabled: true

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: "ejbca.3key.company"
      paths:
        - path: /ejbca
          pathType: Prefix
  tls:
   - hosts:
       - ejbca.3key.company
     secretName: tls-secret
```

---
# Znalosti potřebné pro Kubernetes

## 🥱 Síťové koncepty

<div data-marpit-fragment>

## 🥱 Základy Linuxu

</div>

<div data-marpit-fragment>

## 🏫 Kontejnery

</div>

<div data-marpit-fragment>

## 🤔 Základy YAML

</div>

<div data-marpit-fragment>

## 🥱 Základy verzovacích systémů

</div>

---

# Ukázka - kontejner od samého začátku
 - nginx server
 - statická HTML stránka s počítadlem návštěv

![bg right height:350px](img/VisitorNo.drawio.svg)

---

# Základní Debian kontainer - základ FS

```
$ sudo debootstrap --variant=minbase --arch=amd64 stable ./debian-rootfs http://deb.debian.org/debian/
[sudo] password for semik:
I: Target architecture can be executed
I: Retrieving InRelease
I: Checking Release signature
I: Valid Release signature (key id 41587F7DB8C774BCCF131416762F67A0B2C39DE4)
I: Retrieving Packages
I: Validating Packages
I: Resolving dependencies of required packages...
I: Resolving dependencies of base packages...
I: Checking component main on http://deb.debian.org/debian...
I: Retrieving apt 3.0.3
I: Validating apt 3.0.3
I: Retrieving base-files 13.8+deb13u1
...
I: Configuring libc-bin...
I: Unpacking the base system...
I: Base system installed successfully.

$ sudo tar -C ./debian-rootfs -czf debian-rootfs.tar.gz .
$ ls -lh debian-rootfs.tar.gz
-rw-r--r-- 1 semik semik 91M Sep 21 11:59 debian-rootfs.tar.gz
```

---
# Základní Debian kontainer - Dockerfile

```Dockerfile
FROM scratch
ADD debian-rootfs.tar.gz /
CMD ["/bin/bash"]
```

---
# Základní Debian kontainer - build
```
$ podman build -t semik-debian .
STEP 1/3: FROM scratch
STEP 2/3: ADD debian-rootfs.tar.gz /
--> 88a23cbc621
STEP 3/3: CMD ["/bin/bash"]
COMMIT semik-debian
--> 23e9c8d7323
Successfully tagged localhost/semik-debian:latest
23e9c8d7323dd1073c4dae198d259e39e93b4e09189ccc8f7aa359a8258f8e58
$ podman images | head -2
REPOSITORY              TAG    IMAGE ID      CREATED         SIZE
localhost/semik-debian  latest 23e9c8d7323d  11 seconds ago  307 MB
$ podman run -it --rm semik-debian
root@e51b231698ee:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   4332  3868 pts/0    Ss   10:19   0:00 /bin/bash
root           2  0.0  0.0   6396  3864 pts/0    R+   10:19   0:00 ps aux
root@e51b231698ee:/# exit
$
```

---
# Přidání NGINX webserveru

```Dockerfile
FROM semik-debian

RUN apt-get update
RUN apt-get install -y nginx

CMD ["nginx", "-g", "daemon off;"]
```

---
# Přidání NGINX webserveru - build
```
$ podman build -t semik-nginx .
STEP 1/4: FROM semik-debian
STEP 2/4: RUN apt-get update
Hit:1 http://deb.debian.org/debian stable InRelease
...
--> 3e4e199c320
STEP 3/4: RUN apt-get install -y nginx
Reading package lists...
Building dependency tree...
...
--> 838947b502a
STEP 4/4: CMD ["nginx", "-g", "daemon off;"]
COMMIT semik-nginx
--> f8e6d41355a
Successfully tagged localhost/semik-nginx:latest
f8e6d41355a8987e18f83bbe88a615a89825561efd9a563bea0609e0cfbcbdeb
```
---
# Přidání NGINX webserveru - velikosti
```
$ podman images | head -2
REPOSITORY              TAG    IMAGE ID      CREATED         SIZE
localhost/semik-nginx   latest f8e6d41355a8  10 minutes ago  487 MB

$ podman history semik-nginx:latest
ID            CREATED        CREATED BY                              SIZE     COMMENT
838947b502a0  7 min ago      /bin/sh -c #(nop) CMD ["nginx", "-g", "dae...  0 B      FROM 838947b502a0
<missing>     7 min ago      /bin/sh -c apt-get install -y nginx            51.4 MB  FROM 3e4e199c3200
3e4e199c3200  7 min ago      /bin/sh -c apt-get update                      129 MB   FROM localhost/semik-debian
............................................................................^^^^^^..............................
8a93158a2a68  3 hours ago    /bin/sh -c #(nop) CMD ["/bin/bash"]            0 B      FROM 8a93158a2a68
<missing>     3 hours ago    /bin/sh -c #(nop) ADD file:9964643c2b482ae...  307 MB
```

---
# Přidání NGINX webserveru - optimalizace #1

```Dockerfile
FROM semik-debian

RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get clean

CMD ["nginx", "-g", "daemon off;"]
```
---
# Přidání NGINX webserveru - optimalizace #1
```
$ podman images | head -2
REPOSITORY             TAG     IMAGE ID      CREATED         SIZE
localhost/semik-nginx  latest  63f05057b311  19 seconds ago  487 MB

$ podman history semik-nginx:latest
ID            CREATED         CREATED BY                                     SIZE        COMMENT
84ab1cf88f95  7 seconds ago   /bin/sh -c #(nop) CMD ["nginx", "-g", "dae...  0 B         FROM 84ab1cf88f95
<missing>     8 seconds ago   /bin/sh -c apt-get clean                       78.8 kB     FROM 838947b502a0
838947b502a0  20 minutes ago  /bin/sh -c apt-get install -y nginx            51.4 MB     FROM 3e4e199c3200
3e4e199c3200  20 minutes ago  /bin/sh -c apt-get update                      129 MB      FROM localhost/semik-debian
8a93158a2a68  4 hours ago     /bin/sh -c #(nop) CMD ["/bin/bash"]            0 B         FROM 8a93158a2a68
<missing>     4 hours ago     /bin/sh -c #(nop) ADD file:9964643c2b482ae...  307 MB
```

---
# Přidání NGINX webserveru  - optimalizace #2

```Dockerfile
FROM semik-debian

RUN apt-get update && apt-get install -y nginx && apt-get clean

CMD ["nginx", "-g", "daemon off;"]
```

<div data-marpit-fragment>

```
$ podman images | head -2
REPOSITORY             TAG     IMAGE ID      CREATED             SIZE
localhost/semik-nginx  latest  0498ab51a846  About a minute ago  346 MB

$ podman history semik-nginx:latest
ID            CREATED             CREATED BY                                     SIZE        COMMENT
b5b0bce5767a  About a minute ago  /bin/sh -c #(nop) CMD ["nginx", "-g", "dae...  0 B         FROM b5b0bce5767a
<missing>     About a minute ago  /bin/sh -c apt-get update && apt-get insta...  38.8 MB     FROM localhost/semik-debian
8a93158a2a68  4 hours ago         /bin/sh -c #(nop) CMD ["/bin/bash"]            0 B         FROM 8a93158a2a68
<missing>     4 hours ago         /bin/sh -c #(nop) ADD file:9964643c2b482ae...  307 MB
```

</div>

---

# Otestování NGINX image

```
$ podman run --rm -d --name semik-nginx -p 8080:80 semik-nginx
6246a4ca7d0e1e73b1bd9c3800a46ee98bcfb1d5c76a838bd9491c3d6ca67564
$
```

<div data-marpit-fragment>

```
$ podman ps
CONTAINER ID  IMAGE                         COMMAND               ...  PORTS                 NAMES
6246a4ca7d0e  localhost/semik-nginx:latest  nginx -g daemon o...  ...  0.0.0.0:8080->80/tcp  semik-nginx
$
```
</div>
<div data-marpit-fragment>


```
$ curl http://localhost:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...

```

</div>

---
# Zobrazení správné stránky
```
$ podman run --rm -d --name semik-nginx -p 8080:80 \
   -v $(pwd)/index.html:/var/www/html/index.nginx-debian.html:ro \
   semik-nginx
190e9adb47b71216c1e4729da78933f8cb9c0c3c4ecae5ad7bdb83b8578be5e7
```

<div data-marpit-fragment>

```
$ curl http://localhost:8080
<!DOCTYPE html>
<html><head><title>Vítejte na LinuxDays!</title></head>
<body style="text-align:center;">
<h1>LinuxDays 2025</h1>
<h2>4. a 5. října 2025, Praha</h2>
<h3>FIT ČVUT, Praha Dejvice</h3>
</body></html>
```
</div>
<div data-marpit-fragment>

```
$ podman stop semik-nginx
semik-nginx
$
```
</div>

---
# Vytvoření počítadla návštěv

## skript pro generován obrázků (bash + imagemagick)

```bash
./cgi-bin/7segment.sh -w 10 \
    -c '#00DD00' -o '#d2ffd2' \
    -b white 01234 output.png ; display output.png
```

<div data-marpit-fragment>

![](./img/VistNo-example.png)

</div>

---
# Vytvoření počítadla návštěv - soubory

```
.
├── alive.txt
├── cgi-bin
│   ├── 7segment.sh
│   └── counter.sh
├── data
│   └── counter
├── Dockerfile
└── entrypoint.sh
```

`./data` - datový adresář pro počítadlo návštěv (mimo image)
`./cgi-bin/counter.sh` - skript počítadla návštěv

---

# Vytvoření počítadla návštěv - Dockerfile

```Dockerfile

FROM semik-debian

# Install busybox, bash, and any image dependencies (e.g., imagemagick, png tools, etc)
RUN apt-get update && apt-get install -y bash busybox imagemagick && apt-get clean

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
```
---

# Vytvoření počítadla návštěv - test

```
$ podman run --rm --name semik-counter \
  -p 8080:8080 \
  -v $(pwd)/data:/data -e COUNTER_DIR=/data semik-counter
[::ffff:10.0.2.100]:48136: url:/cgi-bin/counter.sh
[::ffff:10.0.2.100]:48142: url:/cgi-bin/counter.sh
[::ffff:10.0.2.100]:48150: url:/cgi-bin/counter.sh
[::ffff:10.0.2.100]:48158: url:/cgi-bin/counter.sh
```

![](img/VisitNo-browser.png)

---
# podman-compose

možná v další prezentaci?

---
# YAML Ain't Markup Language

- čitelnost nejen strojem, ale i člověkem
* struktura a hierarchie dat je řešena odsazením (**mezerami**, ne tabulátory)
* neomezené úrovně vnořování
* nahrazuje JSON konfigurace
  * XML si pamatují už jen 🦖
* používá se k definici konfigurací v Kubernetes (a nejen tam)

---
# Základní struktura YAML

```yaml
jmeno: "Ukázka struktury YAML"
verze: 1.0
cesky: true
cislo: 42
pole:
  - polozka1
  - polozka2
hash:
  klic1: hodnota1
  klic2: "hodnota 2"
dataTakJakJsou: |
  Toto je text
  ve kterém budou zachovány
  nové řádky.
dataVJednomRadku: >
  Toto je text
  který bude interpretován jako
  jediný řádek.
```

---
# Příklad z Kubernetes - Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: semik-counter
spec:
  containers:
    - name: semik-counter
      image: semik-counter
      ports:
        - containerPort: 8080
```

---
```
$ podman push semik75/ld25-nginx:latest
Getting image source signatures

Copying blob 8cd8bb154730 done
Copying blob e91d164cdb11 done
Copying config 0f252a9325 done
Writing manifest to image destination
Storing signatures
$
$ podman push semik75/ld25-counter:latest
Getting image source signatures
Copying blob 3c2da93b9307 done
Copying blob 49fde82665a2 done
Copying blob 4d47c999746d done
Copying blob bc8a185f2edc done
Copying blob a28687ae7ca4 done
Copying blob 469a5aa7e0e2 skipped: already exists
Copying config 917795cd2e done
Writing manifest to image destination
Storing signatures
$
```

---
