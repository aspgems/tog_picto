class Picto::Photo < ActiveRecord::Base
  before_update :update_position

  acts_as_commentable
  acts_as_taggable
  acts_as_voteable
  acts_as_list :scope => :photoset

  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  belongs_to :photoset
  named_scope :public, :joins => "INNER JOIN photosets ON photosets.id = photos.photoset_id", :conditions => ['photosets.privacy = 0']

  has_attached_file :image, {
    :url => "/system/:class/:attachment/:id/:style_:basename.:extension",
    :styles => {
      :big    => Tog::Plugins.settings(:tog_picto, "photo.versions.big"),
      :medium => Tog::Plugins.settings(:tog_picto, "photo.versions.medium"),
      :small  => Tog::Plugins.settings(:tog_picto, "photo.versions.small"),
      :tiny   => Tog::Plugins.settings(:tog_picto, "photo.versions.tiny")
    }}.merge(Tog::Plugins.storage_options)

  unless Tog::Plugins.settings(:tog_picto, 'search.skip_indices')
    define_index do
      indexes title
      indexes description
      indexes image_file_name
      has photoset(:privacy), :as => :privacy
    end

    def self.site_search(query, options = {})
      self.search query, options.merge(:with => { :privacy => Picto::Photoset::IS_PUBLIC })
    end
  end

  def self.latest
    all({ :limit => "20", :order => "created_at desc" })
  end

  def can_be_read_by?(user)
    if photoset
      photoset.can_be_read_by?(user)
    else
      owner == user
    end
  end

  def creation_date(format=:short)
    I18n.l(self.created_at, :format => format)
  end
  
  private
    def update_position
      add_to_list_bottom if position.nil? || photoset_id != Picto::Photo.find(self.id).photoset_id
    end

end
