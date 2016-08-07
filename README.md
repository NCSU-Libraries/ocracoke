# IIIF Search Inside app

1. create some OCR
2. index the OCR


## Vagrant

Development is done in Vagrant.

Start vagrant:

```
vagrant up
```

On the host visit Solr at <http://localhost:8984>

SSH to vagrant machine and start Rails:
```
vagrant ssh
cd /vagrant
bundle
bin/rails s -b 0.0.0.0
```

On the host visit Rails: <http://localhost:8090>



## Solr

Update the core's config:

```
cp ~/code/iiif_search_inside/solr_conf/solrconfig.xml /home/jnronall/programs/solr-6.1.0/server/solr/iiifsi/conf/. && curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=iiifsi"
```
