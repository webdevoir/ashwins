class StockHolder < PeopleAndFirm

  include MyFunction
  include ModelMethods

  default_scope{ where(class_name: "StockHolder")}
  validate :entity_presence
  validate :reset_first_name_or_entity_id
  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :email, :postal_address, :fax, :phone1, :phone2, :city, :state, :zip, maximum: 250
  validates :email, email: true, if: "self.email.present?"
  validates_length_of :ein_or_ssn, is: 9, if: "self.ein_or_ssn.present?"
  validates_format_of :ein_or_ssn, :with => /\A([A-Za-z0-9]+)\Z/i, message: " is invalid", if: "self.ein_or_ssn.present?"
  validate :validate_my_percentage

  belongs_to :super_entity, class_name: "SuperEntity"
  belongs_to :entity
  after_save :add_key

  def entity_presence
    unless self.is_person?
      if self.entity.blank?
        errors.add(:entity, "is invalid, Please add it before saving")
        return
      end
    end
  end

  def type_
    MemberType.find(Entity.find(self.entity_id).type_).name rescue ""
  end

  def total_stock_share
    self.super_entity.total.to_i rescue nil
  end

  def remaining_stock_share
    val   = StockHolder.where(super_entity_id: self.super_entity_id).sum(:my_percentage)
    val ||= 0
    ((total_stock_share.try(:to_i) || 0) - val.to_i).to_i rescue ""
  end

  def reset_first_name_or_entity_id
    if self.is_person?
      self.entity_id = nil
    end
  end

  def validate_my_percentage
    if self.my_percentage.blank?
      errors.add(:stock_share, "can not be blank")
      return
    end

    if self.my_percentage.to_f <= 0
      errors.add(:stock_share, "must be more than zero")
      return
    end

    if self.my_percentage.to_f >= self.remaining_share_or_interest_
      errors.add(:stock_share, "must be less than #{self.remaining_share_or_interest_}")
      return
    end

  end
  
    # Views
  def name
    "#{self.first_name} #{self.last_name}"
  end

end
