class TeamboxData
  # Note:
  # Internally the import is just a mass creation of objects using hashes of
  # teambox data properties. Importers for each different dump are required to
  # convert their representations to teambox data. 
  
  def unserialize_basecamp(object_maps, opts={})
    # xml dump format:
    # account/projects/project
    # ../attachment-categories/attachment-category
    # ../post-categories/post-category
    # ../milestones/milestone   [as task list?]
    # ../todo-lists/todo-list
    #    ../todo-items/todo-item
    # time-entries/time-entry   [comments]
    # posts/post [conversations]
    #   ../comments/comment [comments]
    # participants/person [people]
    
    account = {}
    import_data = metadata_basecamp(true)
    unserialize_teambox(import_data, object_maps, opts)
  end
  
  def metadata_basecamp(with_project_data=false)
    firm_members = []
    user_list = data['account']['firm']['people'].map do |person|
      {'id' => person['id'],
       'first_name' => person['first_name'],
       'last_name' => person['last_name'],
       'email' => person['email_address'],
       'username' => person['name'].scan(/[A-Za-z0-9]+/).join(''),
       'created_at' => person['created_at']}
    end
    
    project_list = data['account']['projects'].map do |project|
      base = {'id' => id,
       'organization_id' => data['account']['firm']['id'],
       'name' => project['name'].first,
       'archived' => project['status'] == 'active' ? false : true,
       'created_at' => project['created-on'],
       'owner_user_id' => user_list.first['id']}
      
      if with_project_data
        base['conversations'] = project['posts'].map do |post|
          {}.tap do |conversation|
            conversation.merge!({
              'title' => post['title'],
              'user_id' => post['author-id'],
              'created_at' => post['created-on'],
              'simple' => true
            }) 
            conversation['comments'] = post['comments'].map do |comment|
              {'body' => comment['body'],
               'created-at' => post['created-on'],
               'user_id' => post['author-id']}
            end
          end
        end
      end
      
      base
    end
      
    organization_list = ([data['account']['firm']] + data['account']['clients']).map do |firm|
      people = firm['people'].each do |person|
        {'user_id' => person['id']}
      end
      
      compat_name = firm['name'].first
      compat_name = compat_name.length < 4 ? (compat_name + '____') : compat_name
      
      {'id' => firm['id'],
       'name' => compat_name,
       'time_zone' => firm['time_zone_id'],
       'members' => people}
    end
    
    {'users' => user_list,
      'projects' => project_list,
      'organizations' => organization_list}
  end
end