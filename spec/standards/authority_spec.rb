RSpec.describe Authority do
  include ObjectHelper

  let(:auth_hash) do
    {
      "acronym" => "CC",
      "descr" => "NGA Center/CCSSO",
      "guid" => "A83297F2-901A-11DF-A622-0C319DFF4B22"
    }
  end

  let(:a) { Authority.from_hash(auth_hash) }

  it "is instantiable with hash" do
    compare_obj_to_hash(a, auth_hash)
  end

  it "responds to code alias" do
    expect(a.code).to eq 'CC'
  end

  it "responds to description alias" do
    expect(a.description).to eq 'NGA Center/CCSSO'
  end

  it "can have children" do
    standards = (1..5).map{ |i| Standard.new({ "attributes" => { guid: i.to_s } }) }
    expect{a.children = standards}.to change{a.children}.from([]).to(standards)
  end

  it "omits empty children properly" do
    expect(a.children).to be_empty
    expect(a.to_h["children"]).to be_nil
  end

  context ".rebranch_children" do
    it 'rebranches' do
      doc_hash = {
        'guid' => 'doc_guid',
        'descr' => 'doc_descr',
        'publication' => {
          'acronym' => 'pub',
          'descr' => 'my_pub',
          'guid' => 'pub_guid',
          'authorities' => []
        }
      }
      sec_hash = {
        'descr' => 'my_sec',
        'guid' => 'sec_guid'
      }
      s1_hash = {
        'attributes' => {
          'guid' => 's1_guid',
          'document' => doc_hash,
          'section' => sec_hash
        }
      }
      s2_hash = {
        'attributes' => {
          'guid' => 's2_guid',
          'document' => doc_hash,
          'section' => sec_hash
        }
      }
      s1 = Standard.new(s1_hash)
      s2 = Standard.new(s2_hash)

      a.children << s1
      a.children << s2
      a.rebranch_children

      pubs = a.children
      expect(pubs.count).to eq 1
      expect(pubs.first.class).to eq Publication
      expect(pubs.first.guid).to eq 'pub_guid'

      docs = pubs.first.children
      expect(docs.count).to eq 1
      expect(docs.first.class).to eq Document
      expect(docs.first.guid).to eq 'doc_guid'

      secs = docs.first.children
      expect(secs.count).to eq 1
      expect(secs.first.class).to eq Section
      expect(secs.first.guid).to eq 'sec_guid'

      stds = secs.first.children
      expect(stds.count).to eq 2
      expect(stds.first.class).to eq Standard
      expect(stds.map(&:guid).sort).to eq ['s1_guid', 's2_guid']
    end
  end
end
