class Picto::Photoset < ActiveRecord::Base

  IS_PUBLIC  = 0
  IS_FRIENDS = 1
  IS_PRIVATE = 2

  acts_as_commentable
  acts_as_taggable
  acts_as_voteable

  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  belongs_to :main_photo, :class_name => "Picto::Photo", :foreign_key => "main_photo_id"

  has_many :photos, :order => "position"

  named_scope :public, :conditions => ['privacy = ?', IS_PUBLIC] 

  define_index do
    indexes title
    indexes description
    has privacy
  end

  def can_be_read_by?(user)
    return true if self.privacy == IS_PUBLIC
    return true if self.owner == user
    return true if self.privacy == IS_FRIENDS && self.owner.friends.include?(user)
    return false
  end
  
  def creation_date(format=:short)
    I18n.l(self.created_at, :format => format)
  end  

  def number_of_photos
    photos.count
  end

  def self.site_search(query, options = {})
    self.search query, options.merge(:with => { :privacy => Picto::Photoset::IS_PUBLIC })
  end

end
