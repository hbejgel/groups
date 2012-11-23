#!/usr/bin/ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'highline/import'
require 'sinatra'
require 'shotgun'
require 'gappsprovisioning/provisioningapi'
require 'json'
include GAppsProvisioning
enable :sessions
set :sessions, true






def get_password(prompt="Enter Password")
   ask(prompt) {|q| q.echo = false}
end

def login(user,password)
  #puts "Enter Username"
  #user = gets.chomp
  #password = get_password()
  user = "leonardo.constantino@21212.com"
  password = "qheddcyxvthzsrlp"
  app = ProvisioningApi.new(user.to_s,password.to_s)
  return app
end

#given a user, returns its groups
def retrieve_groups(myapps,user)
  #puts "Enter a username to know its groups"
  mylists = myapps.retrieve_groups(user)
  return_value = []
  mylists.each {|list| return_value << list.group_id }
  return return_value 
end  

def complement_groups(myapps,model,included)
  #puts "Enter a username to be included in the groups"
  #included = gets.chomp
  #puts "Enter a username to be used as a model"
  #model = gets.chomp
  
  mylists = myapps.retrieve_groups(model)
  mylists.each {|list| myapps.add_member_to_group(included, list.group_id)  } 
end

get '/login' do
  erb :login
end

post '/login' do
  
  #list = myapps.retrieve_all_users
  #erb :groups
  session[:user]= params[:user]
  session[:password]= params[:password]
  redirect '/groups'
  
end  

get '/groups' do
  if session[:user].nil? || session[:password].nil?
    redirect '/login'
  end   
  myapps = login(session[:user],session[:password])
  @list = myapps.retrieve_all_users
  
  erb :groups
end


get '/search' do

myapps = login(session[:user],session[:password])  
user = params[:q].to_s

resp=retrieve_groups(myapps,user)  
content_type :json
puts "**********#{resp.to_json}************"
return resp.to_json

end

get '/transfer' do
  myapps = login(session[:user],session[:password])  
  dst = params[:destination].to_s
  src = params[:source].to_s
  complement_groups(myapps,src,dst)
end





#myapps = login()

#retrieve_groups(myapps)
#complement_groups(myapps)