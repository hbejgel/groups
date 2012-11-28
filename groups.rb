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
  app = ProvisioningApi.new(user.to_s,password.to_s)
  return app
end

#given a user, returns its groups
def retrieve_groups(myapps,user)
  begin
    mylists = myapps.retrieve_groups(user)
    return_value = []
    mylists.each {|list| return_value << list.group_id }
  rescue GDataError => e
    return ["Error: " + e.reason]
  end
      
  return return_value 
end  

def complement_groups(myapps,model,included)
  begin
    mylists = myapps.retrieve_groups(model)
    mylists.each {|list| myapps.add_member_to_group(included, list.group_id)  } 
  rescue GDataError => e
    return "Error: " + e.reason  
  end
  return "Success"  
end

get '/login' do
  erb :login
end

post '/login' do
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
  return resp.to_json

end

get '/transfer' do
  myapps = login(session[:user],session[:password])  
  dst = params[:destination].to_s
  src = params[:source].to_s
  
  return complement_groups(myapps,src,dst)
  
end
