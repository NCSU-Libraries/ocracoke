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

First, we need to create a file which includes the identifiers for resources and images. You can see an example of how this is created for NCSU Libraries with the `NcsuFileCreator` class. This uses an API on our public site to gather the needed information. You can give it a try with: `bin/rake iiifsi:create_ncsu`. This will place a JSON file in `tmp/ncsu_source_file.json`.

If you are using the NCSU Libraries task to create the source file you can adjust the path of the outfile and give the URL to use for the query. In this example all of the Technician newspapers from the 1970s that match the query "april 1" are output. This is just a matter of taking a URL from the public site and requesting the JSON version of the query.

```sh
bin/rake iiifsi:create_ncsu["./tmp/nsf.json","http://d.lib.ncsu.edu/collections/catalog.json?f[format][]=Text&f[ispartof_facet][]=Technician&f[resource_decade_facet][]=1970s&q=april+1"]
```

Source files should be in the format of an array of objects. You can see a simple example in `examples/short_ncsu_source_file.json`. Each object includes two keys `resource` and `images`. The value of `resource` should be a unique identifier for the resource. The value of `images` is an array of the IIIF image identifiers which will be used to retrieve the images from an IIIF Image API server for processing OCR for each image. The `resource` value will be used as the name of the directory to place the concatenated text and PDF from all of the page `images` of the resource. The concatenated PDF can be used to allow downloading a searchable PDF.

### Create OCR

To create OCR you can run the rake task `iiifsi:create_ocr`. You'll want to use the source file you created in the previous step. If you have your own source file you can pass it in as a parameter to the task: `bin/rake iiifsi:create_ocr[./examples/short_ncsu_source_file.json]`.

To use your own IIIF image server you will want to include the value of your IIIF base URL in `config/iiifsi.yml` for the correct environment.

### Index the OCR

Now that you have created OCR you can index the OCR. Combined OCR will not be indexed. So you only index the page images you'll give the rake task the source file as a parameter again: `bin/rake iiifsi:index_ocr[./examples/short_ncsu_source_file.json]`.

### Search a Resource

Now that you have indexed the pages of your resources you can search inside them and get a [IIIF Content Search API](http://iiif.io/api/search/) response. If you are using the NCSU Libraries example you can do the following search from the host: <http://localhost:8090/search/technician-v60n1-1980-04-01?q=student>. The search URL follows the pattern `/search/RESOURCE_IDENTIFIER?q=QUERY` and always returns JSON.

### Use Search Endpoint in a IIIF Presentation Manifest

You can now include the search endpoint in a [IIIF Presentation API](http://iiif.io/api/presentation) manifest. If you are working in development you can include it as a service in your manifest like this:

```json
"service": [
  {
    "@context": "http://iiif.io/api/search/0/context.json",
    "@id": "http://localhost:8090/search/technician-v60n1-1980-04-01",
    "profile": "http://iiif.io/api/search/0/search",
    "label": "Search within this thing",
    "service": {
      "@id": "http://localhost:8090/autocomplete/technician-v60n1-1980-04-01",
      "profile": "http://iiif.io/api/search/0/autocomplete",
      "label": "Get suggested words (Currently a fake endpoint)"
    }
  }
]
```

Note that currently the autocomplete endpoint just returns a 200 OK status. This is to work around this issue with universalviewer: <https://github.com/UniversalViewer/universalviewer/issues/348>

## Solr

To update the Solr core's configuration you can run this from the host:

```sh
curl "http://localhost:8984/solr/admin/cores?action=RELOAD&core=iiifsi"
```
