class CreateAppointmentRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :appointment_requests do |t|
      t.references :nutritionist, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.string :guest_name, null: false
      t.string :guest_email, null: false
      t.date :desired_date, null: false
      t.time :desired_time, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :appointment_requests, :guest_email
    add_index :appointment_requests, :status
    add_index :appointment_requests, [ :nutritionist_id, :status ]
    add_index :appointment_requests, [ :nutritionist_id, :desired_date, :desired_time ]
    add_index :appointment_requests, [ :guest_email, :status ]
  end
end
