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

class Labeling::Base < ActiveRecord::Base

  self.table_name = 'labelings'

  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = nil
  self.rdf_predicate = nil

  # ********** Associations

  belongs_to :owner,  :class_name => 'Concept::Base'
  belongs_to :target, :class_name => 'Label::Base'

  # ********** Scopes

  def self.by_concept(concept)
    where(:owner_id => concept.id)
  end

  def self.by_label(label)
    where(:target_id => label.id)
  end

  def self.concept_published
    includes(:owner).merge(Concept::Base.published)
  end

  def self.label_published
    includes(:target).merge(Label::Base.published)
  end

  def self.label_begins_with(prefix)
    includes(:target).merge(Label::Base.begins_with(prefix))
  end

  def self.by_label_language(lang)
    includes(:target).merge(Label::Base.by_language(lang.to_s))
  end

  # ********** Methods

  # if `singular` is true, only a single occurrence is allowed per instance
  # FIXME: There must be a validation checking this
  # Might there be more than one labeling of this type and language per concept?
  def self.singular?
    false
  end

  def self.view_section(obj)
    obj.is_a?(Label::Base) ? 'concepts' : 'labels'
  end

  def self.view_section_sort_key(obj)
    200
  end

  def self.partial_name(obj)
    'partials/labeling/base'
  end

  def self.edit_partial_name(obj)
    'partials/labeling/edit_base'
  end

  def self.relation_name
    relname = self.name.underscore.gsub('/', '_').sub('labeling_', '')
    Rails.logger.warn "WARN: Inferring relation name #{relname} from class name (#{self.name}), you should define self.relation_name in your relation class."
    relname
  end

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    rdf_subject = Concept::Base.from_origin_or_instance(rdf_subject)
    raise "#{self.name}#build_from_rdf: Object (#{rdf_object}) must be a string literal" unless rdf_object =~ /^"(.+)"(@(.+))?$/

    lang, value = $3, JSON.parse(%Q{["#{$1}"]})[0].gsub("\\n", "\n") # Trick to decode \uHHHHH chars

    predicate_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self
    predicate_class.new(:target => self.label_class.new(:value => value, :language => lang)).tap do |label|
      rdf_subject.send(predicate_class.name.to_relation_name) << label
    end
  end

end
