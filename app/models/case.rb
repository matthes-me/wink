class Case < ActiveRecord::Base
  belongs_to :case_type

  has_many :events
  has_many :items

  validates :name, presence: true
  validates :acronym, presence: true
  validates :case_type, presence: true

  LOCATIONS = ["Meshbag", "Fach"]

  def locations
    Item.where("case_id = #{self.id} and \
      (item_type_id = #{ItemType.find_by(name: "Meshbag").id} or
      item_type_id = #{ItemType.find_by(name: "Fach").id})")
  end
end
