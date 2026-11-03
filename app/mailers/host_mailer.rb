class HostMailer < ApplicationMailer
  # Notifies a host that someone applied to one of their rooms.
  def new_application(application)
    @application = application
    @listing = application.listing
    @property = @listing.property
    @host = @property.host
    @seeker = application.seeker

    mail(to: @host.email_address,
         subject: "New application for your room in #{@property.neighborhood.name}")
  end
end
