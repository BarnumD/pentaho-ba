# Pentaho-BA
Dockerized implementation of Pentaho business analytics 6.0.1.1 Enterprise Edition.  This configuration uses the 'archive' mode of installation.

# To Run:
<ul>Clone this repository or using a new Dockerfile, source it with the FROM command.</ul>
<ul>Set your enterprise file download location in the Dockerfile starting at 'pkg-biserver-ee='.</ul>
<ul>Build the docker image for this and pentaho-db</ul>
<ul>Run pentaho-db: docker run -d --name pentaho-db -d -p 5432:5432 -v /docker/mounts/pentaho-db/var/lib/postgresql/data:/var/lib/postgresql/data pentaho-db</ul>
<ul>Run pentaho-ba: docker run -d --name pentaho-ba -p 8080:8080 -e TIER=TEST -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-ba/opt/pentaho:/opt/pentaho pentaho-ba &</ul>
<br><br>
For more information on running in test & production see the dockerfile.
