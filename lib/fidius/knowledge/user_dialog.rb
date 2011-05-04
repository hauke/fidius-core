module FIDIUS
  class UserDialog < ActiveRecord::Base
    DIALOG_TYPE_STANDARD = 1
    DIALOG_TYPE_YES_NO = 2

    def self.create_dialog(title,message)
      UserDialog.create(:title=>title,:message=>message,:dialog_type=>DIALOG_TYPE_STANDARD)
    end

    def self.create_yes_no_dialog(title,message)
      UserDialog.create(:title=>title,:message=>message,:dialog_type=>DIALOG_TYPE_YES_NO)
    end
  end
end
