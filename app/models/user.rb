class User < ActiveRecord::Base
  has_many :photos, :class_name => "Picto::Photo", :dependent => :destroy
  has_many :owned_photosets, :class_name => "Picto::Photoset"

  def public_photosets
    owned_photosets.all(:conditions => { :privacy => Picto::Photoset::IS_PUBLIC })
  end

  def number_of_photos
    owned_photosets.inject(0) { |sum, photoset| sum + photoset.number_of_photos }
  end

  def can_read?(resource)
    resource.can_be_read_by?(self)
  end

  def friends
    self.profile.friends.map(&:user)
  end
end
