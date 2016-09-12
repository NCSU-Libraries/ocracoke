# Ocracoke

Rails application to create, index, and search page text and provide results in [IIIF Content Search API](http://iiif.io/api/search/) format. The application can OCR for indexing content using a IIIF Image server for source images.

## Quick start

### Vagrant

Development is done in Vagrant. Check out the code.  Start vagrant:

```sh
vagrant up
```

While this is installing the appropriate box and provisioning it, you can look through the /ansible directory to get some idea of all the dependencies and how the application gets deployed to a production environment.

### Solr
On the host visit Solr at <http://localhost:8984>. You should see the "ocracoke" Solr core under "Core Admin."

### Rails

SSH to vagrant machine, migrate the database, and start Rails:
```sh
vagrant ssh
cd /vagrant
bundle
bin/rake db:migrate
bin/rails s -b 0.0.0.0
```

On the host visit Rails: <http://localhost:8090/jobs>
You should see the the Resque jobs page.

### OCR a Resource

This will show you all the rake tasks available for ocracoke:

```sh
vagrant ssh
cd /vagrant
bin/rake -T ocr
```

We're going to OCR a single resource from the NCSU Libraries' collection. This is a Commencement program that mentions a graduate from Ocracoke. It also ought to OCR quickly enough.

```sh
bin/rake ocracoke:queue_from_ncsu_id[LD3928-A23-1947]
```

That task will use an NCSU Libraries API to get the list of identifiers for images associated with this resource. You should now see one "resource_ocr" job in the queue. Now we need to run a worker to process the jobs. This is the suggested queue order though you can change it to suit your needs.

```sh
QUEUE=ocr,word_boundaries,index,concatenate_txt,pdf,delayed,notification,resource_ocr REDO_OCR=true bin/rake resque:work
```

You should see output on the console that the jobs are working. The Resque web interface will show that one worker is working, and you can see the status of all the queues.

### Search Inside

At this point you ought to be able to see the result for Ocracoke in the search inside results: <http://localhost:8090/search/LD3928-A23-1947?q=ocracoke>

### Suggestions

Suggestions will not work yet until the suggestion dictionary is built. This is a time consuming process so it is something that would be run nightly in a production. You can trigger building the suggester by optimizing the Solr index:

```
bin/rake ocracoke:solr:optimize
```

You should now see a suggestion for "ocra" <http://localhost:8090/suggest/LD3928-A23-1947?q=ocra>

## OCRing and Indexing Your Own Content

Ocracoke uses a IIIF Image server to get the images that it OCRs and indexes. You will need image identifiers that can be used in a IIIF Image API URL to grab the images. Currently Ocracoke is configured to only use a single IIIF Image server. Edit `./config/ocracoke.yml` to point to a different iiif_base_url.

You will also need a resource identifier to group all the images for search inside.

There is currently no user interface for adding OCR jobs. You may eventually want to add your own Rake tasks to queue OCR jobs.

Or you could use the API for sending OCR jobs in. This is one way that NCSU Libraries can kick jobs off from a separate application.

```sh
curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"resource": "ua102_002-001-bx0012-013-008", "images": ["ua102_002-001-bx0012-013-008_001","ua102_002-001-bx0012-013-008_002","ua102_002-001-bx0012-013-008_003"]}' -H  "Authorization: Token token=scams_token, user=scams" http://localhost:8090/api/ocr_resource
```

You should now see 1 job in the resource_ocr queue. Take a look in `./config/api_tokens.yml` for the valid users and tokens.

## Indexing Content Without OCR

It also ought to be possible to use Ocracoke without relying on it to create the OCR. You will just need a certain directory structure and the right files to be in place for it to work as expected.

The `ocr_directory` can be set in `config/ocracoke.yml`. Under the OCR directory are directories using the first two characters of your resource and image identifiers. For instance if one or more identifiers begins with "LD" then there will be a directory named "LD" under the OCR directory. Within will be directories named after each resource and image identifier. In order to use the OCR index script you will need to have within each directory for an image at minimum a text file with the full text of the page and a JSON word boundaries file. If you are not using the provided scripts for indexing, the minimum will be the JSON word boundaries file if you want hits to be highlighted.

If creating OCR using the scripts given here you will have already created hOCR with Tesseract. The hOCR is used to extract word boundaries, which you could do some other way. There will also be a PDF for each resource available for users to download.

Here's an example directory structure of a single resource with a couple of the pages from the resource after OCR:

```
/access-images/
└── ocr
    └── LD
        ├── LD3928-A23-1947
        │   ├── LD3928-A23-1947.pdf
        │   └── LD3928-A23-1947.txt
        ├── LD3928-A23-1947_0001
        │   ├── LD3928-A23-1947_0001.hocr
        │   ├── LD3928-A23-1947_0001.json
        │   └── LD3928-A23-1947_0001.txt
        ├── LD3928-A23-1947_0002
        │   ├── LD3928-A23-1947_0002.hocr
        │   ├── LD3928-A23-1947_0002.json
        │   └── LD3928-A23-1947_0002.txt
        ...
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

In the future this data might be indexed instead of just present in a JSON file.

### Use Search Endpoint in a IIIF Presentation Manifest

You can include the search endpoint in a [IIIF Presentation API](http://iiif.io/api/presentation) manifest. If you are working in development you can include it as a service in your manifest like this:

```json
"service": [
  {
    "@context": "http://iiif.io/api/search/0/context.json",
    "@id": "http://localhost:8090/search/LD3928-A23-1947",
    "profile": "http://iiif.io/api/search/0/search",
    "label": "Search within this thing",
    "service": {
      "@id": "http://localhost:8090/suggest/LD3928-A23-1947",
      "profile": "http://iiif.io/api/search/0/autocomplete",
      "label": "Get suggested words"
    }
  }
]
```


## Indexing Page Text

In some cases you may already have OCR or the text has been transcribed. In these cases you could just index the text directly into Solr. The fields you will want to include in the Solr document you add for each page image are:

- "id" for the identifier for the page image. This is a single-valued field.
- "resource" for the identifier for the resource which may have multiple images associated with it. The "resource" field allows for filtering Solr queries for search inside functionality rather than searching across all documents in the index. This is a single-valued field.
- "txt" for the full text of the page either from OCR or transcription. This is a single-valued field.
- TODO: are there other fields created in the application now?

## Suggester

A simple suggester is provided. It currently has some limitations where it can only suggest a single word and not a phrase. This example request would return suggested terms like "ocracoke": <http://localhost:8090/suggest/LD3928-A23-1947?q=ocra>

## Solr in Vagrant

Sometimes when Vagrant starts up it seems the synced file system is not present when Solr start, so it is necessary to restart Solr on the guest to pick up the configs:

```sh
sudo service solr-ocracoke restart
```

To update the Solr core's configuration you can run this from the host:

```sh
curl "http://localhost:8984/solr/admin/cores?action=RELOAD&core=ocracoke"
```

## Notifications

If notifications are turned on then the application will also queue a job to notify an external API that an OCR job for a particular resource has been completed. Currently this job only gets queued if the PDF is successfully created which is the last step in the NCSU Libraries' workflow.

This API is currently under development and it only POSTs the resource identifier via JSON. In the future it may send the image identifiers, size of the resulting PDF, and other data.

In the included `./config/ocracoke.yml` file notifications are turned off. An example is given of how to send a notification to the host machine on port 3000 to the ``/api_incoming/ocr` path.

## TODO

- #TODO:10 Allow the JSON word boundary file to include x, y, w, h values instead of the hOCR x0, y0, x1, y1 values and work either way.

## Authors

- Jason Ronallo

## License

See MIT-LICENSE
