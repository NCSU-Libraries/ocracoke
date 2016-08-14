# IIIF Search Inside

Application to create, index, and search OCR and provide results in [IIIF Content Search API](http://iiif.io/api/search/) format.

## Quick start

### Vagrant
Check out the code. Development is done in Vagrant. Start vagrant:

```sh
vagrant up
```

On the host visit Solr at <http://localhost:8984>

SSH to vagrant machine and start Rails:
```sh
vagrant ssh
cd /vagrant
bundle
bin/rails s -b 0.0.0.0
```

On the host visit Rails: <http://localhost:8090>
You should see the "Yay! You're on Rails!" page.

### Create Source File

First, we need to create a file which includes the identifiers for resources and images. You can see an example of how this is created for NCSU Libraries with the `NcsuFileCreator` class. This uses an API on our public site to gather the needed information. You can give it a try with: `bin/rake iiifsi:create_ncsu`. This will place a JSON file in `tmp/ncsu_file.json`.

Source files should be in the format of an array of objects. Each object includes two keys `resource` and `images`. The value of `resource` should be a unique identifier for the resource. The value of `images` are the IIIF image identifiers which will be used to retrieve the images from an IIIF Image API server for processing OCR for each image. The `resource` value will be used as the name of the directory to place the concatenated text and PDF from all of the page `images` of the resource. The concatenated PDF can be used to allow downloading a searchable PDF.

### Create OCR

To create OCR you can run the rake task `iiifsi:create_ocr`. You'll want to use the source file you created in the previous step. If you have your own source file you can pass it in as a parameter to the task: `bin/rake iiifsi:create_ocr[./examples/short_ncsu_source_file.json]`.

To use your own IIIF image server you will want to include the value of your IIIF base URL in `config/iiifsi.yml` for the correct environment.

### Index the OCR

Now that you have created OCR you can index the OCR. Combined OCR will not be indexed. So you only index the page images you'll give the rake task the source file as a parameter again: `bin/rake iiifsi:index_ocr[./examples/short_ncsu_source_file.json]`.

### Search a Resource

Now that you have indexed the pages of your resources you can search inside them and get a [IIIF Content Search API](http://iiif.io/api/search/) response. If you are using the NCSU Libraries example you can do the following search from the host: <http://localhost:8090/search/technician-v60n1-1980-04-01?q=student>. The search URL follows the pattern `/search/RESOURCE_IDENTIFIER?q=QUERY`.

## Solr

To update the core's config you can run this from the host:

```sh
curl "http://localhost:8984/solr/admin/cores?action=RELOAD&core=iiifsi"
```
