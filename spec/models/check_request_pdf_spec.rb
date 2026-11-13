# frozen_string_literal: true

require 'spec_helper'

describe CheckRequestPdf do
  let(:template) { Tempfile.new(['check-request', '.pdf']) }
  let(:location) { { 'left' => 20, 'top' => 100, 'width' => 250 } }
  let(:layout) do
    { 'pages' => [
      { 'upcase' => true, 'text_size' => 10, 'fields' => [
        { 'name' => 'name', 'location' => [location, location.merge('top' => 70, 'upcase' => nil)] }
      ] },
      { 'upcase' => true, 'fields' => [
        { 'name' => 'address', 'location' => location.merge('upcase' => false, 'line_space' => 4) }
      ] }
    ] }
  end

  before do
    Prawn::Document.generate(template.path, page_size: [400, 500]) do |pdf|
      pdf.text('Original first page')
      pdf.start_new_page(size: [600, 700])
      pdf.text('Original second page')
    end
    document = HexaPDF::Document.open(template.path)
    document.pages[0][:Annots] = [document.add({ Type: :Annot, Subtype: :Link, Rect: [20, 20, 100, 40],
                                                 A: { S: :URI, URI: 'https://www.opensuse.org/' } })]
    document.write(template.path)
  end

  after { template.close! }

  it 'preserves template pages and adds fields with their configured casing', :aggregate_failures do
    values = { 'name' => 'Luke Skywalker', 'address' => "First street\nSecond line" }
    output = described_class.render(template: template.path, layout: layout) { |name| values[name] }
    pages = PDF::Reader.new(StringIO.new(output)).pages

    expect(pages.map(&:text)).to include(a_string_including('Original first page'),
                                         a_string_including('Original second page'))
    expect(pages.first.text.scan('LUKE SKYWALKER').count).to eq(2)
    expect(pages.last.text).to include('First street', 'Second line')
    expect(pages.map { |page| page.attributes[:MediaBox] }).to eq([[0, 0, 400, 500], [0, 0, 600, 700]])
    document = HexaPDF::Document.new(io: StringIO.new(output))
    expect(document.pages[0][:Annots].first[:A][:URI]).to eq('https://www.opensuse.org/')
  end

  it 'rejects layouts with more pages than their template' do
    layout['pages'] << layout['pages'].first

    expect do
      described_class.render(template: template.path, layout: layout) { 'value' }
    end.to raise_error(ArgumentError, 'Check request layout has more pages than its template')
  end
end
