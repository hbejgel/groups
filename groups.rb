require 'rubygems'
require 'sinatra'
require 'gappsprovisioning/provisioningapi'
require 'highline/import'
require 'shotgun'
require 'json'

include GAppsProvisioning

enable :sessions
set :sessions, true

def get_password(prompt="Enter Password")
   ask(prompt) {|q| q.echo = false}
end

def login(user,password)
  user = "leonardo.constantino@21212.com" #apagar essa e a debaixo
  password = "qheddcyxvthzsrlp"

  ProvisioningApi.new(user.to_s,password.to_s)
end

#given a user, return their groups
def retrieve_groups(myapps,user)
  begin
    myapps.retrieve_groups(user).map { |list| list.group_id }
  rescue GDataError => e
    ["Error: #{e.reason}"]
  end
end

def complement_groups(myapps,model,included)
  begin
    myapps.retrieve_groups(model).each do |list|
      myapps.add_member_to_group(included, list.group_id)
    end
  rescue GDataError => e
    "Error: {e.reason}"
  end
  "Success"
end

def edit_groups(myapps,user,groups)
  begin
    retrieve_groups(myapps,user).each do |group|
      myapps.remove_member_from_group(user, group)
    end
    return "#{user} removed from all groups. " if groups.nil?
    groups.each do |group|
      myapps.add_member_to_group(user, group)
    end
  rescue GDataError => e
    "Error: " + e.reason
  end
  "Success"
end

get '/login' do
  erb :login
end

get '/logout' do
  session.clear

  erb :login
end

post '/login' do
  session[:user]= params[:user]
  session[:password]= params[:password]

  redirect '/groups'
end

get '/groups' do
  redirect '/login' and return if session[:user].nil? || session[:password].nil?
  myapps = login(session[:user],session[:password])
  @list = myapps.retrieve_all_users
  @grupos = myapps.retrieve_all_groups.map { |group| group.group_id }

  erb :groups
end

get '/search' do
  myapps = login(session[:user],session[:password])
  user = params[:q].to_s

  content_type :json
  return retrieve_groups(myapps,user).to_json
end

get '/transfer' do
  myapps = login(session[:user], session[:password])
  dst = params[:destination].to_s
  src = params[:source].to_s

  complement_groups(myapps, src, dst)
end

get '/edit' do
  myapps = login(session[:user], session[:password])
  user = params[:user].to_s
  groups = params[:groups]

  edit_groups(myapps, user, groups)
end

