class TrackerHiderController < ApplicationController
  
  before_filter :require_admin
  unloadable
 

  def settings
      @global_rules = HiddenTracker.where('project_id IS NULL AND user_id IS NULL AND role_id IS NOT NULL');
      flash[:notice] = t(:no_rules_defined) if @global_rules.empty?
  end
  
  def add_global_rule
    @global_rules = []
    role_id = params[:role_id].to_i
    tracker_id = params[:tracker_id].to_i
    if role_id>0 && tracker_id>0 then
      if HiddenTracker.where('user_id IS NULL AND project_id IS NULL AND tracker_id =? AND role_id = ?', tracker_id, role_id).empty? then
        HiddenTracker.new(tracker_id: tracker_id, role_id: role_id).save
        flash[:notice] = t(:rule_was_created)
      else
        flash[:alert] = t(:the_rule_alredy_exists)
      end
    else
      flash[:alert] = t(:the_rule_is_bad)
    end 
    @global_rules = HiddenTracker.where('project_id IS NULL AND user_id IS NULL AND role_id IS NOT NULL');
    redirect_to :tracker_hider_settings
  end
  
  def drop_global_rule
    if params[:id].to_i > 0 && HiddenTracker.find(params[:id]).destroy then
      flash[:notice] = t(:rule_was_destroyed)
    else
      flash[:alert] = t(:something_went_wrong)
    end
    redirect_to :tracker_hider_settings
  end
  
end
