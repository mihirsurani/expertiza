class DueDate < ActiveRecord::Base
  NO = 1
  LATE = 2
  OK = 3
  
  belongs_to :assignment
  belongs_to :deadline_type
  validate :due_at_is_valid_datetime


  def due_at_is_valid_datetime
    errors.add(:due_at, 'must be a valid datetime') if ((DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError)
  end

  def self.copy(old_assignment_id, new_assignment_id)    
    duedates = find(:all, :conditions => ['assignment_id = ?',old_assignment_id])
    duedates.each{
      |orig_due_date|
      new_due_date = orig_due_date.clone
      new_due_date.assignment_id = new_assignment_id
      new_due_date.save       
    }    
  end

// moved this method from assignment.rb as it is related to due dates.  
  def self.set_duedate (duedate,deadline, assign_id, max_round)
    submit_duedate=DueDate.new(duedate);
    submit_duedate.deadline_type_id = deadline;
    submit_duedate.assignment_id = assign_id
    submit_duedate.round = max_round; 
    submit_duedate.save;
  end
  
  def setFlag()
     #puts"~~~~~~~~~enter setFlag"
      self.flag = true
      self.save
     #puts"~~~~~~~~~#{self.flag.to_s}"
    end

  def get_current_due_date(assignment)
    #puts "~~~~~~~~~~Enter get_current_due_date()\n"
    due_date = find_current_stage(assignment)
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return due_date
    end

  end

// moved this method from assignment.rb as it is related to due dates.
  def get_next_due_date(assignment)
    #puts "~~~~~~~~~~Enter get_next_due_date()\n"
    due_date = find_next_stage(assignment)
    if due_date == nil or due_date == COMPLETE
      return nil
    else
      return due_date
    end

  end

// moved this method from assignment.rb as it is related to due dates.
  def self.find_next_stage(assignment)
    #puts "~~~~~~~~~~Enter find_next_stage()\n"
    due_dates = DueDate.find(:all,
                 :conditions => ["assignment_id = ?", assignment.id],
                 :order => "due_at DESC")

    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return COMPLETE
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
             (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
             if (i > 0)
               return due_dates[i-1]
             else
               return nil
             end
          end
          i = i + 1
        end

        return nil
      end
    end
  end

// moved this method from assignment.rb as it is related to due dates.
  def self.find_current_stage(assignment,topic_id=nil)
    if assignment.staggered_deadline?
      due_dates = TopicDeadline.find(:all,
                   :conditions => ["topic_id = ?", topic_id],
                   :order => "due_at DESC")
    else
      due_dates = DueDate.find(:all,
                   :conditions => ["assignment_id = ?", assignment.id],
                   :order => "due_at DESC")
    end


    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return COMPLETE
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
             (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
            return due_date
          end
          i = i + 1
        end
      end
    end
  end

end
