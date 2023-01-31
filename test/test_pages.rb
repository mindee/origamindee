require 'minitest/autorun'
require 'stringio'

class TestPages < Minitest::Test
    def setup
        @target = PDF.new
        @output = StringIO.new
    end

    def test_append_page
        p1, p2, p3 = Page.new, Page.new, Page.new

        @target.append_page p1
        @target.append_page p2
        @target.append_page p3

        assert_equal @target.pages.count, 3

        assert_equal @target.get_page(1), p1
        assert_equal @target.get_page(2), p2
        assert_equal @target.get_page(3), p3

        assert_raises(IndexError) { @target.get_page(0) }
        assert_raises(IndexError) { @target.get_page(4) }

        assert_equal @target.Catalog.Pages, p1.Parent
        assert_equal @target.Catalog.Pages, p2.Parent
        assert_equal @target.Catalog.Pages, p3.Parent

        @target.save(@output)

        assert_equal @target.Catalog.Pages.Count, 3
        assert_equal @target.pages, [p1, p2, p3]
        assert_equal @target.each_page.to_a, [p1, p2, p3]
    end

    def test_insert_page
        pages = Array.new(10) { Page.new }

        pages.each_with_index do |page, index|
            @target.insert_page(index + 1, page)
        end

        assert_equal @target.pages, pages

        new_page = Page.new
        @target.insert_page(1, new_page)
        assert_equal @target.get_page(1), new_page

        assert_raises(IndexError) { @target.insert_page(0, Page.new) }
        assert_raises(IndexError) { @target.insert_page(1000, Page.new) }
    end

    def test_example_write_delete_page
        @target.append_page
        @target.pages.last.write 'Hello, page 1 world!', size: 30
        @target.append_page
        @target.pages.last.write 'Hello, page 2 world!', size: 30
        @target.save(@output)
        assert_equal @target.Catalog.Pages.Count, 2

        @target.delete_page_at(1)
        @target.save(@output)
        assert_equal @target.Catalog.Pages.Count, 1
    end

    def test_delete_pages_generated
        to_append = [Page.new, Page.new, Page.new, PageTreeNode.new, Page.new, Page.new, Page.new]
        to_append.each { |page| @target.append_page(page) }
        to_del = [0,1]
        assert_equal @target.Catalog.Pages.Count, to_append.length
        @target.delete_pages_at(to_del)
        assert_equal @target.Catalog.Pages.Count, to_append.length - to_del.length
    end

    def test_delete_pages_parsed
        file = File.join(__dir__, 'dataset', '3_pages.pdf')
        pdf = PDF.read(file, ignore_errors: false, verbosity: Parser::VERBOSE_QUIET)
        assert_equal pdf.Catalog.Pages.Count, 3
        pdf.delete_pages_at([0,2])
        assert_equal pdf.Catalog.Pages.Count, 1
    end
end
