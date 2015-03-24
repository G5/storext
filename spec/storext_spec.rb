require 'spec_helper'

describe Storext do

  it "can set default value for the serialized column" do
    coffee = Coffee.new
    expect(coffee.data).to eq({})
  end

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

  describe ".storext_definitions" do
    it "is a hash of attribute definitions" do
      expect(Book.storext_definitions[:title]).to eq({
        column: :data,
        type: String,
        opts: { default: "Great Voyage" }
      })
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

        include Storext.model
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

          include Storext.model
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

  context "`include Storext` is in the parent class" do
    it "does not blow up" do
      expect(Book.new.title).to eq "Great Voyage"
      expect(PocketBook.new.soft).to be true
      expect(Book.new).to_not respond_to :soft
      expect(PocketBook.new.title).to eq 1
    end

    it "does not overwrite the stored attribute settings" do
      # Because of Rails' autoloading, we have to load SmartPhone first
      SmartPhone
      expect(Phone.new.number).to eq "222"
      expect(FeaturePhone.new.number).to be_nil
      expect(SmartPhone.new.number).to eq "111"
    end
  end

  context "`include Storext` is in the parent class and defaults the column" do
    it "does not override defaults" do
      expect(SmartPhone.new.number).to eq "111"
      expect(FlipPhone.new.number).to eq "222"
    end

    it "retains saved values after initialization" do
      phone = SmartPhone.create(number: "09999")
      expect(phone.reload.number).to eq "09999"
    end
  end

  context "when no attributes defined" do
    it "keeps the column nil, like ActiveRecord does with `store_accessor`" do
      expect(Car.new.data).to be_nil
    end
  end

  it "properly saves data in the store column during creation" do
    book = Book.create(title: "Rarara")
    expect(Book.where("data -> 'title' = 'Rarara'")).to_not be_empty
  end

  it "property saves data in the store column during updates" do
    book = Book.create(title: "Rarara")
    book.title = "Sis boom ba"
    book.save
    expect(Book.where("data -> 'title' = 'Sis boom ba'")).to_not be_empty
    expect(Book.last.title).to eq "Sis boom ba"
  end

  describe ".destroy_key" do
    it "removes the key from the instance and does not save" do
      book = Book.create(author: "Chico's")
      book.destroy_key(:data, :author)
      expect(book.data).to_not have_key("author")
      book.reload
      expect(book.data).to have_key("author")
    end
  end

  describe ".destroy_keys" do
    it "removes the keys from the instance and does not save" do
      book = Book.create(author: "Chico's", title: "Go-go")
      book.destroy_keys(:data, :author, :title)
      expect(book.data).to_not have_key("author")
      expect(book.data).to_not have_key("title")
      book.reload
      expect(book.data).to have_key("author")
      expect(book.data).to have_key("title")
    end
  end

end
