# frozen_string_literal: true

require_relative 'lib/origami/version'

Gem::Specification.new do |spec|
    spec.name          = 'origamindee'
    spec.version       = Origami::VERSION
    spec.authors       = ['Guillaume Delugré', 'Mindee, SA']
    spec.email         = ['devrel@mindee.co']

    spec.summary       = 'Ruby framework to manipulate PDF documents'
    spec.description   = "Mindee's fork of Origami, a pure Ruby library to parse, modify and generate PDF documents."
    spec.homepage      = 'https://github.com/mindee/origamindee'
    spec.license       = 'LGPL-3.0+'

    spec.metadata['source_code_uri'] = 'https://github.com/mindee/origamindee'
    spec.metadata['changelog_uri'] = 'https://github.com/mindee/origamindee/blob/main/CHANGELOG.md'
    spec.metadata['rubygems_mfa_required'] = 'true'

    spec.platform      = Gem::Platform::RUBY

    spec.files         = Dir[
                            'README.md',
                            'CHANGELOG.md',
                            'COPYING.LESSER',
                            '{lib,bin,test,examples}/**/*',
                            'bin/shell/.irbrc',
                        ]
    spec.require_paths = ['lib']
    spec.bindir        = 'bin'
    spec.executables   = %w(pdfsh
                         pdf2pdfa pdf2ruby
                         pdfcop pdfmetadata
                         pdfdecompress pdfdecrypt pdfencrypt
                         pdfexplode pdfextract)
    spec.test_file     = 'test/test_pdf.rb'

    spec.required_ruby_version = '>= 2.6'

    spec.add_runtime_dependency 'rainbow', '~> 3.1.1'
    spec.add_runtime_dependency 'rexml', '~> 3.2'
    spec.add_runtime_dependency 'matrix', '~> 0.4'

    spec.add_development_dependency 'minitest', '~> 5.0'
    spec.add_development_dependency 'rake', '~> 12.3'
    spec.add_development_dependency 'yard', '~> 0.9'
end
