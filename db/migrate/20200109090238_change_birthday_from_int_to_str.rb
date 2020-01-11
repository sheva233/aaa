# frozen_string_literal: true

class ChangeBirthdayFromIntToStr < ActiveRecord::Migration[6.0]
  def change
    change_column(:users, :birthday, :date)
  end
end