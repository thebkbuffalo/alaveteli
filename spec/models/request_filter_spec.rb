# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RequestFilter do

  describe '#update_attributes' do

    it 'assigns the filter' do
      request_filter = described_class.new
      request_filter.update_attributes(:filter => 'awaiting_response')
      expect(request_filter.filter).to eq 'awaiting_response'
    end

    it 'assigns the search' do
      request_filter = described_class.new
      request_filter.update_attributes(:search => 'lazy dog')
      expect(request_filter.search).to eq 'lazy dog'
    end

    it 'assigns the order' do
      request_filter = described_class.new
      request_filter.update_attributes(:order => 'created_at_asc')
      expect(request_filter.order).to eq 'created_at_asc'
    end
  end

  describe '#order_options' do

    it 'returns a list of sort order options in label, parameter form' do
      expected = [['Last updated', 'updated_at_desc'],
                  ['First created', 'created_at_asc'],
                  ['Title (A-Z)', 'title_asc']]
      expect(described_class.new.order_options).to eq expected
    end
  end

  describe '#persisted?' do

    it 'returns false' do
      expect(described_class.new.persisted?).to be false
    end

  end

  describe '#results' do

    context 'when no attributes are supplied' do

      it 'sorts the requests by most recently updated' do
        user = FactoryGirl.create(:user)
        first_request = FactoryGirl.create(:info_request, :user => user)
        second_request = FactoryGirl.create(:info_request, :user => user)

        request_filter = described_class.new
        expect(request_filter.results(user.info_requests(true)))
          .to eq([second_request, first_request])
      end
    end

    it 'applies a sort order' do
      user = FactoryGirl.create(:user)
      first_request = FactoryGirl.create(:info_request, :user => user)
      second_request = FactoryGirl.create(:info_request, :user => user)

      request_filter = described_class.new
      request_filter.update_attributes(:order => 'created_at_asc')
      expect(request_filter.results(user.info_requests(true)))
        .to eq([first_request, second_request])
    end

    it 'applies a filter ' do
      user = FactoryGirl.create(:user)
      complete_request = FactoryGirl.create(:successful_request,
                                            :user => user)
      incomplete_request = FactoryGirl.create(:info_request,
                                              :user => user)

      request_filter = described_class.new
      request_filter.update_attributes(:filter => 'complete')
      expect(request_filter.results(user.info_requests(true)))
        .to eq([complete_request])
    end

    it 'applies a search to the request titles' do
      user = FactoryGirl.create(:user)
      dog_request = FactoryGirl.create(:info_request,
                                       :title => 'Where is my dog?',
                                       :user => user)
      cat_request = FactoryGirl.create(:info_request,
                                       :title => 'Where is my cat?',
                                       :user => user)
      request_filter = described_class.new
      request_filter.update_attributes(:search => 'CAT')
      expect(request_filter.results(user.info_requests(true)))
        .to eq([cat_request])
    end

  end

end