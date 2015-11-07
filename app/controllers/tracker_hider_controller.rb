class TrackerHiderController < ApplicationController
  
  before_filter :find_optional_project
  before_filter :authorize
  unloadable
  
  def list
    @hidden_trackers = HiddenTracker.where(project_id: params[:project_id])
  end
  
  def add_hider
    if params[:object_id] =~ /user_(\d+)/ then
      user_id = $1
      
      if HiddenTracker.where(project_id: @project.id, tracker_id: params[:tracker_id], user_id: user_id).empty? then 
        ht = HiddenTracker.new
        ht.project = @project
        ht.user = User.find(user_id)
        ht.tracker = Tracker.find(params[:tracker_id])
        if ht.save then
          flash[:notice] = t(:tracker_hider_created)
        else
          flash[:alert] = t(:tracker_hider_isnt_created_due_errors)
        end
      else
        flash[:alert] = t(:tracker_hider_already_exists)
      end
      
    elsif params[:object_id] =~ /role_(\d+)/ then
      role_id = $1

      if HiddenTracker.where(project_id: @project.id, tracker_id: params[:tracker_id], role_id: role_id).empty? then 
        ht = HiddenTracker.new
        ht.project = @project
        ht.role = Role.find(role_id)
        ht.tracker = Tracker.find(params[:tracker_id])
        if ht.save then
          flash[:notice] = t(:tracker_hider_created)
        else
          flash[:alert] = t(:tracker_hider_isnt_created_due_errors)
        end
      else
        flash[:alert] = t(:tracker_hider_already_exists)
      end
      
    else
      flash[:alert] = t(:tracker_hider_isnt_created_due_errors)
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
