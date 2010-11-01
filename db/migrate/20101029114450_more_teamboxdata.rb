class MoreTeamboxdata < ActiveRecord::Migration
  def self.up
    add_column :teambox_datas, :processed_objects, :text
    add_column :teambox_datas, :service, :string
  end

  def self.down
    remove_column :teambox_datas, :processed_objects
    remove_column :teambox_datas, :service
  end
end
