require 'minitest/autorun'
require 'stringio'
require 'openssl'

class TestSign < Minitest::Test

    def create_self_signed_ca_certificate(key, expires)
        name = OpenSSL::X509::Name.parse 'CN=origami/DC=example'

        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = 0
        cert.not_before = Time.now
        cert.not_after = Time.now + expires
        cert.public_key = key
        cert.subject = name

        extension_factory = OpenSSL::X509::ExtensionFactory.new
        extension_factory.issuer_certificate = cert
        extension_factory.subject_certificate = cert

        cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
        cert.add_extension extension_factory.create_extension('keyUsage', 'digitalSignature,keyCertSign')
        cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')

        cert.issuer = name
        cert.sign key, OpenSSL::Digest::SHA256.new

        cert
    end

    def ec_test_data(curve_name)
        key = OpenSSL::PKey::EC.generate(curve_name)
        other_key = OpenSSL::PKey::EC.generate(curve_name)
        cert = create_self_signed_ca_certificate(key, 3600)
        other_cert = create_self_signed_ca_certificate(other_key, 3600)
        [ cert, key, other_cert ]
    end

    def rsa_test_data(key_size)
        key = OpenSSL::PKey::RSA.new(key_size)
        other_key = OpenSSL::PKey::RSA.new(key_size)
        cert = create_self_signed_ca_certificate(key, 3600)
        other_cert = create_self_signed_ca_certificate(other_key, 3600)
        [ cert, key, other_cert ]
    end

    def setup
        @rsa_1024_data = rsa_test_data(1024)
        @ec_prime256v1_data = ec_test_data('prime256v1')
    end

    def setup_document_with_annotation
        document = PDF.read(File.join(__dir__, "dataset/calc.pdf"),
                           ignore_errors: false, verbosity: Parser::VERBOSE_QUIET)

        annotation = Annotation::Widget::Signature.new.set_indirect(true)
        annotation.Rect = Rectangle[llx: 89.0, lly: 386.0, urx: 190.0, ury: 353.0]

        document.append_page do |page|
            page.add_annotation(annotation)
        end

        [ document, annotation ]
    end

    def sign_document_with_method(method, cert, key, other_cert)
        document, annotation = setup_document_with_annotation

        document.sign(cert, key,
            method: method,
            annotation: annotation,
            issuer: "Guillaume Delugré",
            location: "France",
            contact: "origami@localhost",
            reason: "Example"
        )

        assert document.frozen?
        assert document.signed?

        output = StringIO.new
        document.save(output)

        document = PDF.read(output.reopen(output.string,'r'), verbosity: Parser::VERBOSE_QUIET)

        refute document.verify
        assert document.verify(allow_self_signed: true)
        assert document.verify(trusted_certs: [cert])
        refute document.verify(trusted_certs: [other_cert])

        result = document.verify do |ctx|
            ctx.error == OpenSSL::X509::V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT and ctx.current_cert.to_pem == cert.to_pem
        end

        assert result
    end

    def test_rsa_sign_pkcs7_sha1
        sign_document_with_method(Signature::PKCS7_SHA1, *@rsa_1024_data)
    end

    def test_rsa_sign_pkcs7_detached
        sign_document_with_method(Signature::PKCS7_DETACHED, *@rsa_1024_data)
    end

    def test_rsa_sign_x509_sha1
        sign_document_with_method(Signature::PKCS1_RSA_SHA1, *@rsa_1024_data)
    end

    def test_ec_sign_pkcs7_sha1
        sign_document_with_method(Signature::PKCS7_SHA1, *@ec_prime256v1_data)
    end

    def test_ec_sign_pkcs7_detached
        sign_document_with_method(Signature::PKCS7_DETACHED, *@ec_prime256v1_data)
    end

    def test_ec_sign_x509_sha1
        sign_document_with_method(Signature::PKCS1_RSA_SHA1, *@ec_prime256v1_data)
    end
end
