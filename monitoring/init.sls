#!py
def run():
    config = {}
    to_monitor = []

    # Automatic detection of services
    available_states = __salt__['cp.list_states'](__env__)

    available_services = __salt__['service.get_all']()

    for service in available_services:
      service = service.lower()
      if service.startswith('php') and service.endswith('-fpm'):
        service = 'phpfpm'

      state_name = create_state_name( service )

      if state_name in available_states:
        to_monitor.append( state_name )

    # Append manually added roles via Pillar
    monitoring_roles = __salt__['pillar.get']('monitoring:roles')

    for role in monitoring_roles:
      # SBTK-769: Workaround for PHP*-FPM service
      if role == 'php5-fpm':
        role = 'phpfpm'

      state_name = create_state_name( role )
      if state_name in available_states:
        to_monitor.append( state_name )

    # Finally, include all the states
    config = {
        'include': to_monitor
    }

    return config

def create_state_name(service):
  return 'monitoring.' + service
