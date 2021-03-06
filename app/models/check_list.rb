class CheckList < ActiveRecord::Base
  has_one :event_case
  has_one :event, through: :event_case
  has_one :case,  through: :event_case

  has_many :check_list_items

  validates :advisor, presence: true


  def copy_items!
    return false if check_list_items.count > 0

    event_case.case.not_deleted_items.each do |ec_item|
      cl_item = CheckListItem.new
      cl_item.item = ec_item
      cl_item.item.broken = ec_item.broken
      cl_item.item.missing = ec_item.missing
      self.check_list_items << cl_item
      self.save!
    end

    true
  end

  def locations
    self.check_list_items.map do |cli|
      cli if cli.item&.shelf?
    end.compact
  end

  def items
    self.check_list_items
  end

  def items_without_shelfs
    self.check_list_items - self.locations
  end
end
