class TrackerHiderController < ApplicationController
  
  before_filter :find_optional_project
  before_filter :authorize
  unloadable
  
  def list
    @hidden_trackers = HiddenTracker.where(project_id: params[:project_id])
  end
  
  def add_hider
    ht = HiddenTracker.where(project_id: @project.id, tracker_id: params[:tracker_id], user_id: params[:user_id])
    if ht.count > 0 then
      flash[:alert] = t(:tracker_hider_already_exists)
    else
      ht = HiddenTracker.new
      ht.project = @project
      ht.user = User.find(params[:user_id])
      ht.tracker = Tracker.find(params[:tracker_id])
      if ht.save then
        flash[:notice] = t(:tracker_hider_created)
      else
        flash[:alert] = t(:tracker_hider_isnt_created_due_errors)
      end
    end
    
    redirect_to settings_project_path(id: params[:project_id], tab: 'tracker_hider')
  end
  
  def remove
    HiddenTracker.find(params[:id]).destroy
    flash[:notice] = t(:tracker_hider_deleted)
    redirect_to settings_project_path(id: params[:project_id], tab: 'tracker_hider')
  end
  
private
  
  def find_optional_project
    @project = Project.find(params[:project_id])
    super
  end
  
end
