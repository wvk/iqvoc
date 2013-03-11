# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class ClientAugmentationTest < ActionDispatch::IntegrationTest

  setup do
    Iqvoc::RDFAPI.parse_triples <<-EOT
      :c11880 rdf:type skos:Concept
      :c11880 skos:prefLabel "Lorem Ypsem"@de

      :c11881 rdf:type skos:Concept
      :c11881 skos:prefLabel "Lorem Ypsem"@de
    EOT
    Capybara.current_driver = Capybara.javascript_driver
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.use_default_driver
  end

  test 'dashboard concept overview' do
    login 'administrator'
    visit dashboard_path(:lang => :de)

    table = page.find('#content table')

    assert table.has_css?('tr', :count => 3)
    assert table.has_css?('tr.highlightable', :count => 2)
    assert table.has_no_css?('tr.hover')

    concept_row = table.all('tr')[1]

    # click row to visit concept page
    concept_row.click
    uri = URI.parse(current_url)
    uri = '%s?%s' % [uri.path, uri.query]
    assert_equal concept_path('c11880', :published => 0, :lang => 'de', :format => 'html'), uri
  end

end
