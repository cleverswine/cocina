class User < ActiveRecord::Migration
	def change
		create_table "users", :force => true do |t|
			t.string   "name"            
			t.string   "description"
			t.boolean  "is_admin", :default => false
			t.string   "password_digest"
			t.string   "auth_token"
			t.timestamps
		end
	end
end
