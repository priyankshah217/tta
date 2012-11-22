class ProjectMetadatum < ActiveRecord::Base
  belongs_to :project
  attr_accessible :browser, :date_of_execution, :host_name, :os_name, :user_timezone
  validates_presence_of :project
end