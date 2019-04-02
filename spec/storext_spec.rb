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

    it "can access methods as its default" do
      book = Book.new
      expect(book.preface).to eq "Write something"
    end

    it "can properly execute a lambda to compute the default" do
      book = Book.new
      expect(book.isbn).to eq "Computed ISBN"
    end

    it "can properly coerce truthy boolean values" do
      book = Book.new
      book.hardcover = "1"

      expect(book.data['hardcover']).to eq true
      expect(book.hardcover).to eq true
    end

    it "can properly coerce falsey boolean values" do
      book = Book.new
      book.hardcover = "0"

      expect(book.data['hardcover']).to eq false
      expect(book.hardcover).to eq false
    end

    it "can access predicater methods for all attributes (with or without defaults)" do
      book = Book.new
      book.preface = nil
      book.alt_name = "Great Travel"

      expect(book.author?).to eq false      # no default
      expect(book.available?).to eq true    # true als default
      expect(book.title?).to eq true        # "Great Voyage" as default
      expect(book.copies?).to eq true       # 0 as default
      expect(book.preface?).to eq false     # set to nil above
      expect(book.alt_name?).to eq true     # set to "Great Travel" above

      book.alt_name = ""
      expect(book.alt_name?).to eq false     # empty string should return false
    end
  end

  describe ".storext_definitions" do
    it "is a hash of attribute definitions" do
      expect(Book.storext_definitions[:title]).to include({
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

  describe "#destroy_key" do
    it "removes the key from the instance and does not save" do
      book = Book.create(author: "Chico's")
      book.destroy_key(:data, :author)
      expect(book.data).to_not have_key("author")
      book.reload
      expect(book.data).to have_key("author")
    end

    it "clears the value from the proxy object" do
      default_title = Book.new.title
      book = Book.create(author: "Chico's", title: "Foo and Bar")

      book.destroy_key(:data, :author)
      expect(book.author).to be_nil

      book.destroy_key(:data, :title)
      expect(book.title).to eq default_title
    end

    it "updates the changes when saved" do
      book = Book.create
      book.data = {'hulla' => 'balloo'}
      book.save
      expect(book.data['hulla']).to eq 'balloo'
      book.destroy_key(:data, :hulla)
      book.save
      book.reload
      expect(book.data).to_not have_key("hulla")
    end
  end

  describe "#destroy_keys" do
    it "removes the keys from the instance and does not save" do
      book = Book.create(author: "Chico's", title: "Go-go")
      book.destroy_keys(:data, :author, :title)
      expect(book.data).to_not have_key("author")
      expect(book.data).to_not have_key("title")
      book.reload
      expect(book.data).to have_key("author")
      expect(book.data).to have_key("title")
    end

    it "clears the values from the proxy object" do
      default_title = Book.new.title
      book = Book.create(author: "Chico's", title: "Foo and Bar")
      book.destroy_keys(:data, :author, :title)

      expect(book.author).to be_nil
      expect(book.title).to eq default_title
    end

    it "updates the changes when saved" do
      book = Book.create
      book.data = { 'hulla' => 'balloo', 'foo' => 'bar' }
      book.save
      expect(book.data['hulla']).to eq 'balloo'
      book.destroy_keys(:data, :hulla, :foo)
      book.save
      book.reload
      expect(book.data).to_not include("hulla", "foo")
    end
  end

  describe "#storext_has_key?(column, attr)" do
    it "is indifferent to key (string or symbol)" do
      book = Book.create(author: "Lola")
      expect(book.storext_has_key?(:data, :author)).to be true
      expect(book.storext_has_key?(:data, 'author')).to be true
    end
  end

  it "does not create new proxy classes for each instance" do
    Book.create
    total_class_count = ObjectSpace.count_objects[:T_CLASS]
    Book.create
    expect(ObjectSpace.count_objects[:T_CLASS]).to be <= (total_class_count+1)
  end

  describe "calling select on model" do
    context "when no default is given for the store attribute" do
      it "does not blow up when `select` is specified and does not include the serialized column" do
        Book.create
        book = Book.select(:id)
        expect { book.inspect }.to_not raise_error
      end
    end

    context "when a default is given for the store attribute" do
      it "does not blow up when `select` is specified and does not include the serialized column" do
        Phone.create
        phone = Phone.select(:id)
        expect { phone.inspect }.to_not raise_error
      end
    end
  end

  describe "marshalling" do
    it "can properly dump and load a non-persisted object" do
      author = Author.new(name: "A. Clarke")
      expect { Marshal.dump(author) }.to_not raise_error

      dump = Marshal.dump(author)
      author2 = Marshal.load(dump)
      expect(author2.name).to eq "A. Clarke"
    end

    it "can properly dump and load a persisted object" do
      author = Author.create(name: "A. Clarke")
      expect { Marshal.dump(author) }.to_not raise_error

      dump = Marshal.dump(author)
      author2 = Marshal.load(dump)
      expect(author2.name).to eq "A. Clarke"
      expect(author2.id).to eq author.id
    end
  end
end
