require 'minitest/autorun'
require 'stringio'

class TestNameTreeLeaf < Minitest::Test
    def setup
        @pdf_path = File.join(__dir__, 'dataset', 'name_tree_leaf.pdf')
        @pdf = Origami::PDF.read(
            @pdf_path,
            ignore_errors: false,
            verbosity: Origami::Parser::VERBOSE_QUIET
        )
    end

    def test_read_and_save_does_not_raise_type_error
        buf = StringIO.new
        assert_silent do
            @pdf.save(buf)
        end
    end
end
