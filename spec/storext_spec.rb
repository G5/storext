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

end
