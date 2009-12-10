module Picto
  module BaseHelper

    def photoset_image(photoset, size="tiny")
      main_photo = photoset.main_photo
      if main_photo
        image_tag(main_photo.image.url(size), :style => "float:left;margin-right:10px;")
      else
         image_tag "/tog_picto/images/default_photoset.png", :style => "float:left;margin-right:10px;"
      end
    end

    def text_navigation_links(photo, options={}, html_options={:class => "nav-text-links"})
      default_options = {
        :prev_text => "<< Previous",
        :next_text => "Next >>",
        :separator => "|"
      }.merge(options)

      content_tag :div, html_options do
        <<-eos
        #{link_to default_options[:prev_text], picto_photo_path(photo.higher_item), :class => "nav-text-prev" unless photo.higher_item.nil?}
        #{default_options[:separator]}
        #{link_to default_options[:next_text], picto_photo_path(photo.lower_item), :class => "nav-text-next" unless photo.lower_item.nil?}
        eos
      end
    end

    def image_navigation_links(photo, options={}, html_options={:class => "nav-image-links"})
      default_options = {
        :prev_text => "<< Previous",
        :next_text => "Next >>",
      }.merge(options)

      content_tag :div, html_options do
        <<-eos
        #{ link_to image_tag(photo.higher_item.image.url(:tiny)), picto_photo_path(photo.higher_item), :title => default_options[:prev_text], :class => "nav-image-prev" unless photo.higher_item.nil? }
        #{ link_to image_tag(photo.lower_item.image.url(:tiny)), picto_photo_path(photo.lower_item),  :title => default_options[:next_text], :class => "nav-image-next" unless photo.lower_item.nil? }
        eos
      end
    end

    def tag_cloud_photos(classes)
      tags = 
        if !logged_in? 
          Picto::Photo.public.tag_counts
        else
          Picto::Photo.all.select do |photo| 
            photo.can_be_read_by?(current_user)
          end.map(&:tag_counts).flatten.compact
        end
      return if tags.empty?
      max_count = tags.sort_by(&:count).last.count.to_f
      tags.each do |tag|
        index = ((tag.count / max_count) * (classes.size - 1)).round
        yield tag, classes[index]
      end
    end
    
    def tag_cloud_your_photos(classes)
      tags = @current_user.photos.tag_counts
      return if tags.empty?
      max_count = tags.sort_by(&:count).last.count.to_f
      tags.each do |tag|
        index = ((tag.count / max_count) * (classes.size - 1)).round
        yield tag, classes[index]
      end
    end

    def extract_query_options
      @order = params[:order] || 'created_at'
      @page  = params[:page] || '1'
      @asc   = params[:asc] || 'desc'   
    end

    def pagination_options
      { :page     => @page,
        :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
        :order    => @order + " " + @asc } 
    end

    def privacy_select_options
      [ [I18n.t('tog_picto.member.photosets.new.select_public'), Picto::Photoset::IS_PUBLIC],
        [I18n.t('tog_picto.member.photosets.new.select_friends'), Picto::Photoset::IS_FRIENDS],
        [I18n.t('tog_picto.member.photosets.new.select_private'), Picto::Photoset::IS_PRIVATE] ]
    end
    
  end
end
