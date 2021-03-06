require "spec_helper"

RSpec.describe Bsale do
  before(:each) do
    Bsale.configure do |config|
      config.access_token = ENV['BSALE_KEY']
    end
  end

  it 'set credentials correctly' do
      expect(Bsale.config.access_token).to eq ENV['BSALE_KEY']
      expect(Bsale.config.content_type).to eq 'application/json'
    end

  it "has a version number" do
    expect(Bsale::VERSION).not_to be "0.1.0"
  end

  context "When is a tax" do
    before(:each) do
      @tax = Bsale::Tax.new
    end

    it "get all taxes availables" do
      response = @tax.all
      expect(response["href"].include?("taxes")).to eq true
    end

    it "get a specific tax" do
      tax = @tax.all["items"].first
      response = @tax.find({ id: tax["id"] })
      expect(tax).to eq response
    end
  end

  context "When is a document" do
    before(:each) do
      @document = Bsale::Document.new
    end

    it "get all documents" do
      response = @document.all
      expect(response["href"].include?("documents")).to eq true
    end

    it "get a summary" do
      response = @document.summary
      expect(response.class).to eq Array
    end

    it "get an error when document ID is not passed to find" do
      expect{ @document.find }.to raise_error("You must need to pass an ID")
    end

    it "find from document ID" do
      document = @document.all["items"].first
      response = @document.find({ id: document["id"] })
      expect(document).to eq response
    end

    it "details by document ID" do
      document = @document.all["items"].first
      response = @document.by_details({ id: document["id"] })
      expect(response["href"].include?("details")).to eq true
    end

    it "references by document ID" do
      document = @document.all["items"].first
      response = @document.by_references({ id: document["id"] })
      expect(response["href"].include?("references")).to eq true
    end

    it "taxes by document ID" do
      document = @document.all["items"].first
      response = @document.taxes({ id: document["id"] })
      expect(response["href"].include?("taxes")).to eq true
    end

    it "sellers by document ID" do
      document = @document.all["items"].first
      response = @document.sellers({ id: document["id"] })
      expect(response["href"].include?("sellers")).to eq true
    end

    it "count documents" do
      document = @document.all["items"].first
      response = @document.count
      expect(response.class).to eq Hash
    end

    it "post a new document" do
      tax = Bsale::Tax.new
      payments = Bsale::Payment.new({ paymentTypeId: nil, amount: nil, recordDate: nil })
      client = Bsale::Client.new({ code: "1-9", city: "Santiago",
                                   company: "Freelance SpA", municipality: "Santiago Centro",
                                   activity: "Asesoría informatica", address: "Moneda 975" })
      taxes = tax.all["items"].map {|item| item["id"] }

      details = Bsale::Detail.new({ netUnitValue: 53975, quantity: 1,
                                    taxId: "#{taxes}", comment: "el nombre del producto que voy a vender", discount: 5 })
      reference = Bsale::Reference.new({ number: 123, referenceDate: Time.now.to_i,
                                         reason: "Factura electrónica 123", codeSii: 33 })

      #priceListId: default, not specified for this case
      #documentTypeId: 8 factura electronica
      #officeId: default, not specified for this case
      #payments: default option
      #client: default option
      document = Bsale::Document.new({ codeSii: 33, emissionDate: Time.now.to_i,
                                       expirationDate: Time.now.to_i, declareSii: 0,
                                         client: client.to_h})
      document.details << details.to_h
      document.references << reference.to_h

      request = document.create(document.to_h)
      response = document.find({ id: request["id"] })
      expect(request).to eq response
    end
  end
end
