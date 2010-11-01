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
    
    user_list = metadata['users']
    organization_list = metadata['organizations']
    
    project_list = metadata['projects'].map do |project|
      collections = {}
      
      project.merge collections
    end
    
    @data = {'account' => {'projects' => project_list, 'users' => user_list, 'organizations' => organization_list}}
    unserialize_teambox(object_maps, opts)
  end
  
  def metadata_basecamp
    firm_members = []
    puts "BC"
    puts data.inspect
    puts "EBC"
    user_list = data['account']['firm']['people'].map do |person|
      {:id => person['id'],
       :first_name => person['first-name'],
       :last_name => person['last-name'],
       :username => person['username'],
       :created_at => person['created-on']}
    end
    
    project_list = data['account']['projects'].map do |project|
      {:id => id,
       :organization_id => data['account']['firm']['id'],
       :name => project['name'],
       :archived => project['status'] == 'active' ? false : true,
       :created_at => project['created-on']}
    end
      
    organization_list = ([data['account']['firm']] + data['account']['client']).map do |firm|
      people = firm['people'].each do |person|
        {'user_id' => person['id']}
      end
      
      {:id => firm['id'],
       :name => firm['name'],
       :time_zone => firm['time-zone-id'],
       :members => people}
    end
    
    {'users' => user_list,
      'projects' => project_list,
      'organizations' => organization_list}
  end
end