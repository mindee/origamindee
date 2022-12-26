[![License: LGPL](https://img.shields.io/github/license/mindee/origamindee)](https://www.gnu.org/licenses/lgpl-3.0)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mindee/origamindee/test.yml)](https://github.com/mindee/origamindee)
[![Gem Version](https://img.shields.io/gem/v/origamindee)](https://rubygems.org/gems/origamindee)
[![Downloads](https://img.shields.io/gem/dt/origamindee.svg)](https://rubygems.org/gems/origamindee)

Origamindee
===========
[Mindee](https://mindee.com/)'s fork of the popular Origami library.

Overview
--------
Origami is a framework written in pure Ruby to manipulate PDF files.

It offers the possibility to parse the PDF contents, modify and save the PDF
structure, as well as creating new documents.

Origami supports some advanced features of the PDF specification:

  * Compression filters with predictor functions
  * Encryption using RC4 (now obsolete) or AES, including the undocumented Revision 6 derivation algorithm
  * Digital signatures and Usage Rights
  * File attachments
  * AcroForm and XFA forms
  * Object streams

Origami is able to parse PDF, FDF and PPKLite (Adobe certificate store) files.

Requirements
------------
The following Ruby versions are tested and supported: 2.6, 2.7, 3.0, 3.1

Some optional features require additional gems:

  * [therubyracer][the-ruby-racer] for JavaScript emulation of PDF scripts

Quick start
-----------
First install Origamindee (this fork) using the latest gem available:

    $ gem install origamindee

You'll need to import it under the original name:
```ruby
require 'origami'
```

To process a PDF document, you can use the ``PDF.read`` method:

```ruby
pdf = Origami::PDF.read "something.pdf"

puts "This document has #{pdf.pages.size} page(s)"
```

The default behavior is to parse the entire contents of the document at once.
This can be changed by passing the ``lazy`` flag to parse objects on demand.

```ruby
pdf = Origami::PDF.read "something.pdf", lazy: true

pdf.each_page do |page|
    page.each_font do |name, font|
        # ... only parse the necessary bits
    end
end
```

You can also create documents directly by instantiating a new PDF object:

```ruby
pdf = Origami::PDF.new

pdf.append_page
pdf.pages.first.write "Hello", size: 30

pdf.save("example.pdf")

# Another way of doing it
Origami::PDF.write("example.pdf") do |pdf|
    pdf.append_page do |page|
        page.write "Hello", size: 30
    end
end
```

Take a look at the [examples](examples) and [bin](bin) directories for some examples of advanced usage.

Tools
-----
Origami comes with a set of tools to manipulate PDF documents from the command line.

  * [pdfcop](bin/pdfcop): Runs some heuristic checks to detect dangerous contents.
  * [pdfdecompress](bin/pdfdecompress): Strips compression filters out of a document.
  * [pdfdecrypt](bin/pdfdecrypt): Removes encrypted contents from a document.
  * [pdfencrypt](bin/pdfencrypt): Encrypts a PDF document.
  * [pdfexplode](bin/pdfexplode): Explodes a document into several documents, each of them having one deleted resource. 
                                  Useful for reduction of crash cases after a fuzzing session.
  * [pdfextract](bin/pdfextract): Extracts binary resources of a document (images, scripts, fonts, etc.).
  * [pdfmetadata](bin/pdfmetadata): Displays the metadata contained in a document.
  * [pdf2ruby](bin/pdf2ruby): Converts a PDF into an Origami script rebuilding an equivalent document (experimental).
  * [pdfsh](bin/pdfsh): An IRB shell running inside the Origami namespace.

**Note**: Since version 2.1, [pdfwalker][pdfwalker-gem] has been moved to a [separate repository][pdfwalker-repo].

Motivation
----------
We were using the excellent Origami library for our [Ruby OCR client library](https://github.com/mindee/mindee-api-ruby).

Unfortunately, it seems the Origami project is now inactive, and as we needed to add Ruby 3.0 support, the decision was made
to fork Origami.

We also noticed that the `colorize` library is licensed under GPL, meaning that Origami cannot be licensed under the LGPL.  
It was therefore replaced by `Rainbow` which has similar functionality, and is licensed under MIT.

Furthermore, we are now in a better position to fix any problems related to PDF parsing that are encountered by our users. 

As such it is our intention to support functionalities within the scope of our client library.

**We do not claim to be an official successor to Origami.**

License
-------
Origami is distributed under the [LGPL](COPYING.LESSER) license.

Copyright © 2019 Guillaume Delugré

Copyright © 2022 Mindee, SA

[the-ruby-racer]: https://rubygems.org/gems/therubyracer
[pdfwalker-gem]: https://rubygems.org/gems/pdfwalker
[pdfwalker-repo]: https://github.com/gdelugre/pdfwalker
