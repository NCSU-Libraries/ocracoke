# IIIF Search Inside

Application to create, index, and search page text and provide results in [IIIF Content Search API](http://iiif.io/api/search/) format. Tasks are provided to use a IIIF Image server to OCR and index page text.

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

## Page Text Directory Structure

The `ocr_directory` can be set in `config/iiifsi.yml`. Under the OCR directory are directories for the first two characters of your resource and image identifiers. For instance if one or more identifiers begins with "technician-" then there will be a directory named "te" under the OCR directory. Within will be directories named after each resource and image identifier. In order to use the OCR index script you will need to have within each directory for an image at minimum a text file with the full text of the page and a JSON word boundaries file. If you are not using the provided scripts for indexing, the minimum will be the JSON word boundaries file if you want hits to be highlighted. If creating OCR using the scripts given here you will have already created hOCR with tesseract and a PDF with hocr-tools.

Here's an example directory structure a single resource with a couple of the pages from the resource:

```
.
└── te
    ├── technician-v60n1-1980-04-01
    │   ├── technician-v60n1-1980-04-01.pdf
    │   └── technician-v60n1-1980-04-01.txt
    ├── technician-v60n1-1980-04-01_0001
    │   ├── technician-v60n1-1980-04-01_0001.hocr
    │   ├── technician-v60n1-1980-04-01_0001.json
    │   ├── technician-v60n1-1980-04-01_0001.pdf
    │   └── technician-v60n1-1980-04-01_0001.txt
    └── technician-v60n1-1980-04-01_0002
        ├── technician-v60n1-1980-04-01_0002.hocr
        ├── technician-v60n1-1980-04-01_0002.json
        ├── technician-v60n1-1980-04-01_0002.pdf
        └── technician-v60n1-1980-04-01_0002.txt

```

## JSON Word Boundaries File

The JSON word boundaries files allow for hit highlighting. If you have this file present then each canvas in "resources" in the content search response will have a "xywh" hash fragment. Each word boundary file for a page takes the form of a single object where the keys are words and the value is an array of word boundaries.

Here's a short example where the words "Wednesday", "April", and "student" could be highlighted if they matched the user's query. If the word "student" matches it would be highlighted on the page four times.

```json
{
  "Wednesday":[{"x0":"149","y0":"734","x1":"431","y1":"791","c":"73"}],
  "April":[{"x0":"450","y0":"733","x1":"555","y1":"781","c":"83"}],
  "student":[
    {"x0":"70","y0":"1442","x1":"808","y1":"1685","c":"88"},
    {"x0":"1578","y0":"4498","x1":"1726","y1":"4531","c":"90"},
    {"x0":"2585","y0":"4126","x1":"2732","y1":"4158","c":"89"},
    {"x0":"4295","y0":"2880","x1":"4444","y1":"2913","c":"86"}]
}
```

The coordinates in the file are the bbox from the hOCR. This data is extracted from the hOCR output from `.ocrx_word` elements during OCR creation, but if you have this information you can create the file yourself. The coordinates are the top-left (x0, y0) and bottom-right (x1, y1) of the bounding box for the word. The height (h) and width (w) are calculated from these points. The "c" value is the confidence level from the OCR engine and currently not used at this point.

If you do not have the JSON word boundaries files then the media fragment will be "xywh=0,0,0,0". This [allows universalviewer](https://github.com/UniversalViewer/universalviewer/issues/202#issuecomment-238036980) to work to get the user to the correct page without showing any highlighting on the matching page.

## Indexing Page Text

In some cases you may already have OCR or the text has been transcribed. In these cases you could just index the text directly into Solr. The fields you will want to include in the Solr document you add for each page image are:

- "id" for the identifier for the page image. This is a single-valued field.
- "resource" for the identifier for the resource which may have multiple images associated with it. The "resource" field allows for filtering Solr queries for search inside functionality rather than searching across all documents in the index. This is a single-valued field.
- "txt" for the full text of the page either from OCR or transcription. This is a single-valued field.

## Autocomplete

Note that currently the autocomplete endpoint just returns a 200 OK status. This is to work around this issue with universalviewer: <https://github.com/UniversalViewer/universalviewer/issues/348>

## Solr

Sometimes when Vagrant starts up it seems the synced file system is not present when Solr start, so it is necessary to restart solr on the guest to pick up the configs:

```sh
sudo service solr-iiifsi restart
```

To update the Solr core's configuration you can run this from the host:

```sh
curl "http://localhost:8984/solr/admin/cores?action=RELOAD&core=iiifsi"
```

## TODO

- #TODO:0 Create rake task to create JSON word boundary files from hOCR and remove this step from OCR creation.
- #TODO:10 Allow the JSON word boundary file to include x, y, w, h values instead of the hOCR x0, y0, x1, y1 values and work either way.
- #TODO:20 Create API for sending OCR and indexing jobs to the application and have a callback when a particular job is completed.

## Authors

- Jason Ronallo

## License

See MIT-LICENSE
