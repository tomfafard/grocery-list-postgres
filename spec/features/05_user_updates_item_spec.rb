require "spec_helper"

feature "user updates item on grocery list" do
  scenario "sees grocery items updates grocery item" do
    db_connection do |conn|
      sql_query = "INSERT INTO groceries (name) VALUES ($1)"
      data = ["eggs"]
      conn.exec_params(sql_query, data)
    end

    visit "/groceries"
    click_button "Update"
    fill_in "Renamed Item", with: "Peanut Butter"
    click_button "Change"

    expect(page).to have_content("Peanut Butter")
  end
end
