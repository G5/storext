require 'spec_helper'

describe Storext do

  describe ".store_attributes" do
    it "allows definition of multiple attributes" do
      book = Book.create
      book.author = "A. Clarke"
      book.available = false
      book.copies = "20"

      expect(book.author).to eq "A. Clarke"
      expect(book.title).to eq "Great Voyage"
      expect(book.available).to be false
      expect(book.copies).to eq 20
    end
  end

  describe ".store_attribute" do
    it "allows definition of a single attribute" do
      book = Book.create
      book.hardcover = true
      book.alt_name = "Something"
      expect(book.hardcover).to be true
      expect(book.alt_name).to eq "Something"
    end

    it "allows definitions of `name`" do
      author = Author.new(name: "A. Clarke")
      expect(author.name).to eq "A. Clarke"
    end
  end

  it "does not leak definitions into other classes" do
    author = Author.new(name: "A. Clarke")
    book = Book.new
    expect(book).to_not respond_to(:name)
  end

  context "class that include Storext does not have Boolean defined" do
    it "allows using `Boolean` type" do
      book = Book.new(hardcover: true)
      expect(book.hardcover).to be true
    end
  end

  context "class that includes Storext has boolean defined" do
    it "does not override Boolean" do
      bad_author_class = Class.new(ActiveRecord::Base) do
        self.table_name = "authors"
        self::Boolean = "Something"

        include Storext
        store_attributes :data do
          name String
        end
      end
      expect(bad_author_class::Boolean).to eq "Something"
    end

    it "raises an error to warn the developer" do
      expect {
        bad_author_class = Class.new(ActiveRecord::Base) do
          self.table_name = "authors"
          Boolean = "Something"

          include Storext
          store_attributes :data do
            name String
            alive Boolean
          end
        end
      }.to raise_error(
        ArgumentError,
        "problem defining `alive`. `Something` may not be a valid type.",
      )
    end
  end

  it "creates the records with defaults set" do
    Book.create
    expect(Book.where("data -> 'title' = 'Great Voyage'")).to_not be_empty
  end

  it "initializes the records with defaults set" do
    expect(Book.new.title).to eq('Great Voyage')
    expect(Book.new.diff_hstore_attr).to eq('some value')
  end

  it "defaults do not override already set values" do
    book = Book.create(title: nil)
    expect(book.title).to be_nil
    book = Book.last
    expect(book.title).to be_nil
  end

end
