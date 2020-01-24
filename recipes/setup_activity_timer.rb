# Set up activity-timer on ubuntu.

set(:app_name,    'activity-timer')
set(:db_user,     'rails')
set(:db_password, 'rails123')

include_recipe '::setup_all'
