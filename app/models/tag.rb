class Tag < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  searches_on :name

  def self.find_or_create_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end

  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end

  def to_s
    name
  end

  def count
    read_attribute(:count).to_i
  end
end
