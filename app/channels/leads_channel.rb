class LeadsChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to all leads for the current user's company
    stream_from "leads_#{current_user.company_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast_lead_update(lead)
    ActionCable.server.broadcast(
      "leads_#{lead.company_id}",
      {
        type: 'lead_update',
        lead_id: lead.id,
        data: {
          id: lead.id,
          name: lead.name,
          phone: lead.phone,
          status: lead.status&.name,
          comment: lead.comment,
          updated_at: lead.updated_at
        }
      }
    )
  end

  def self.broadcast_lead_creation(lead)
    ActionCable.server.broadcast(
      "leads_#{lead.company_id}",
      {
        type: 'lead_created',
        lead_id: lead.id,
        data: {
          id: lead.id,
          name: lead.name,
          phone: lead.phone,
          status: lead.status&.name,
          comment: lead.comment,
          created_at: lead.created_at
        }
      }
    )
  end
end
