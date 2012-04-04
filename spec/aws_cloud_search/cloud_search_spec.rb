require 'spec_helper'

describe AwsCloudSearch::CloudSearch do

  let(:ds) { AwsCloudSearch::CloudSearch.new('spoke-dev-1-na4eszv5wms3lahf4xnq27x6ym') }

  it "should send document batch" do
    batch = AwsCloudSearch::DocumentBatch.new
    
    doc1 = AwsCloudSearch::Document.new(true)
    doc1.id = Time.now.to_i.to_s
    doc1.lang = 'en'
    doc1.add_field('name', 'Jane Williams')
    doc1.add_field('type', 'person')

    doc2 = AwsCloudSearch::Document.new(true)
    doc2.id = Time.now.to_i.to_s
    doc2.lang = 'en'
    doc2.add_field(:name, 'Bob Dobalina')
    doc2.add_field(:type, 'person')
    doc2.add_field(:summary, nil)
    doc2.add_field(:num_links, nil)


    batch.add_document doc1
    batch.add_document doc2
    ds.documents_batch(batch)
  end

  it "should delete a document" do
    id = 'joeblotzdelete_test'
    batch1 = AwsCloudSearch::DocumentBatch.new
    doc1 = AwsCloudSearch::Document.new(true)
    doc1.id = id
    doc1.lang = 'en'
    doc1.add_field('name', 'Joe Blotz Delete Test')
    doc1.add_field('type', 'person')
    batch1.add_document doc1
    ds.documents_batch(batch1)

    batch2 = AwsCloudSearch::DocumentBatch.new
    doc2 = AwsCloudSearch::Document.new(true)
    doc2.id = id
    batch2.delete_document doc2
    ds.documents_batch(batch2)
  end

  it "should raise ArgumentError for invalid XML 1.0 chars" do
    batch = AwsCloudSearch::DocumentBatch.new

    doc1 = AwsCloudSearch::Document.new(true)
    id = Time.now.to_i.to_s
    doc1.id = id
    doc1.lang = 'en'
    doc1.add_field('name', "Jane Williams")
    doc1.add_field('type', 'person')

    # \\uD800 is not a valid UTF-8 and it this line of code may cause your debugger to break
    expect {doc1.add_field("summary", "This is a REALLY bad char, not even UTF-8 acceptable: \uD800")}.to raise_error(ArgumentError)

    #expect { batch.add_document doc1 }.to raise_error(ArgumentError)

    doc2 = AwsCloudSearch::Document.new(true)
    id = Time.now.to_i.to_s
    doc2.id = id
    doc2.lang = 'en'
    doc2.add_field('name', "Brian Williams")
    doc2.add_field('type', 'person')
    expect {doc2.add_field("summary", "This is a bad char for XML 1.0: \v")}.to raise_error(ArgumentError)

    doc2.instance_variable_get("@fields")['how_did_i_get_here'] = "This is a bad char for XML 1.0: \ufffe"
    expect { batch.add_document doc2 }.to raise_error(ArgumentError)

  end



  it "should return a DocumentBatcher instance for new_batcher" do
    ds.new_batcher.should be_an(AwsCloudSearch::DocumentBatcher)
  end

  it "should search" do
    sr = AwsCloudSearch::SearchRequest.new
    sr.bq = "(and name:'Jane')"
    sr.return_fields = %w(logo_url name type)
    sr.size = 10
    sr.start = 0
    sr.results_type = 'json'

    res = ds.search(sr)

    res.should be_an(AwsCloudSearch::SearchResponse)
  end

end
