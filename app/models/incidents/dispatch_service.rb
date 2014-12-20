class Incidents::DispatchService
  def initialize(incident)
    @incident = incident
  end

  attr_reader :incident

  def assign_contact
    if incident.current_dispatch_contact_id
      create_not_available_assignment
    end

    person = next_contact

    unless person
      incidents.responder_assignments.destroy_all
      person = next_contact
    end

    incident.update current_dispatch_contact_id: person.try(:id)
  end

  def complete

  end

  protected

  def create_not_available_assignment
    incidents.responder_assignments.find_or_create_by person_id: incident.current_dispatch_contact_id do |ra|
      ra.role = 'not_available'
    end
  end

  def next_contact
    service = Incidents::RespondersService.new(incident, incident.responder_assignments)
    shift = service.dispatch_shifts.first
    if shift
      shift.person
    else
      service.dispatch_backup.first
    end
  end
end