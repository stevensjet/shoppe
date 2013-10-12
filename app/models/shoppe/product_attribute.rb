class Shoppe::ProductAttribute < ActiveRecord::Base
  
  # Set the table name
  self.table_name = 'shoppe_product_attributes'  
  
  # Validations
  validates :key, :presence => true
  
  # Relationships
  belongs_to :product, :class_name => 'Shoppe::Product'
  
  # Scopes
  scope :searchable, -> { where(:searchable => true) }
  scope :public, -> { where(:public => true) }
  
  # Return the the available options as a hash
  def self.grouped_hash
    all.group_by(&:key).inject(Hash.new) do |h, (key, attributes)|
      h[key] = attributes.map(&:value).uniq
      h
    end
  end
  
  # Create/update attributes for a product based on the provided hash of
  # keys & values
  def self.update_from_array(array)
    existing_keys = self.pluck(:key)
    index = 0
    array.each do |hash|
      next if hash['key'].blank?
      index += 1
      params = hash.merge({
        :searchable => hash['searchable'].to_s == '1',
        :public => hash['public'].to_s == '1',
        :position => index
      })
      if existing_attr = self.where(:key => hash['key']).first
        if hash['value'].blank?
          existing_attr.destroy
          index -= 1
        else
          existing_attr.update_attributes(params)
        end
      else
        attribute = self.create(params)
      end
    end
    self.where(:key => existing_keys - array.map { |h| h['key']}).delete_all
  end
  
end
