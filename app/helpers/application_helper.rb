module ApplicationHelper
  include Pagy::Frontend

  def none_content
    "N/A"
  end

  def avatar_for user, options = {size: Settings.AVATAR_SIZE_200}
    size = options[:size]
    avatar = user.avatar.presence || "default_avatar.jpg"
    image_tag(
      avatar,
      alt: user.name,
      onerror: "this.onerror=nil;this.src='/assets/rails.svg'",
      style: "width: #{size}px; height: #{size}px;"
    )
  end
end
