require "sinatra"
require "pg"
require "pry"

configure :development do
  set :db_config, { dbname: "grocery_list_development" }
end

configure :test do
  set :db_config, { dbname: "grocery_list_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

def all_groceries
  db_connection do |conn|
    conn.exec("SELECT * FROM groceries")
  end
end

def add_grocery(params)
  unless params["name"].empty?
    db_connection do |conn|
      sql_query = "INSERT INTO groceries (name) VALUES ($1)"
      data = [params["name"]]
      conn.exec_params(sql_query, data)
    end
  end
end

def get_comments
  db_connection do |conn|
    conn.exec("SELECT * FROM comments")
  end
end

def find_grocery(id)
  db_connection do |conn|
    sql_query = "SELECT * FROM groceries WHERE id = ($1)"
    data = [id]
    conn.exec_params(sql_query, data).first
  end
end

def grocery_comments(id)
  db_connection do |conn|
    sql_query = "SELECT groceries.*, comments.* FROM groceries JOIN comments ON groceries.id = comments.grocery_id WHERE groceries.id = ($1)"
    data = [id]
    conn.exec_params(sql_query, data)
  end
end

def delete_grocery(id)
  db_connection do |conn|
    sql_query = "DELETE FROM groceries WHERE id = ($1)"
    data = [id]
    conn.exec_params(sql_query, data)
  end
end

def update_grocery(new_grocery, id)
  db_connection do |conn|
    sql_query = "UPDATE groceries SET name = ($1) WHERE ID = ($2)"
    data = [new_grocery, id]
    conn.exec_params(sql_query, data)
  end
end



get "/" do
  redirect "/groceries"
end


get "/groceries" do
  @groceries = all_groceries
  erb :groceries
end


post "/groceries" do
  add_grocery(params)
  redirect "/groceries"
end


get "/groceries/:id" do
  @grocery = find_grocery(params[:id])
  @comments = grocery_comments(params[:id]).to_a

  erb :details
end


delete "/groceries/:id" do
  delete_grocery(params[:id])

  redirect "/groceries"
end


get "/groceries/:id/edit" do
  @grocery = []
  @grocery = find_grocery(params[:id])

  erb :edit
end


patch "/groceries/:id" do
  update_grocery(params[:name], params[:id])

  redirect "/groceries"
end
