desc 'Import Users from Shike System API everyday.'

require 'open-uri'
task :import_users => :environment do
  s = Setting.find_by_name('plugin_s_audit_question') || {}
  get_user_list(Time.now() - 1.days, s.value['shike_url'], s.value['shike_api_key']).each do |u|
    create_or_update_user(u)
  end
end

def get_user_list(lasttime, host, apikey)
  puts "Sync users from: #{lasttime.to_s}"
  begin
    JSON.parse( open(host + '/users/list.json?apikey=' + apikey + 'time=' + lasttime.strftime('%Y-%m-%d %H:%M:%S')).read )
  rescue
    puts "Get user list error!"
    []
  end
end

def create_or_update_user(user)
  if u = User.find_by_login(user['login'])
    if u.update(firstname: user['name'][1..user['name'].length-1], lastname: user['name'][0])
      u.email_address.update(address: user['email']) if u['email'].present?
      puts "Update user: #{u.login}"
    end
  else
    u = User.new(login: user['login'], firstname: user['name'][1..user['name'].length-1], lastname: user['name'][0], admin: false, status: 1, language: 'zh', type: 'User', mail_notification: 'none')
    u.mail = user['email'] || (user['login'] + '@mail.com')
    # u.create_email_address(address: user['email'] || (user['login'] + '@mail.com'), is_default: true, notify: false)
    if u.save
      u.create_preference(hide_mail: true, time_zone: 'Beijing')
      puts "Create user: #{u.login}"
    else
      u.errors.full_messages.each do |m|
        puts m
      end
    end
    # UserPreference.create(user_id: u.id, hide_mail: true, time_zone: 'Beijing')
  end
end
