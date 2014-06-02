class Incidents::AttachmentsController < Incidents::EditPanelController
  belongs_to_incident
  self.panel_name = 'attachments'

  protected

  def create_resource res
    super(res).tap{ pp res.errors }
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_attachment).permit(:file, :attachment_type, :name, :description)]
  end
end