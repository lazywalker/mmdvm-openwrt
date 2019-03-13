local n=require"nixio.fs"
local r=require"luci.sys"
local a=require"luci.util"
local e=require"luci.http"
local w=require"nixio",require"nixio.util"
module("luci.dispatcher",package.seeall)
context=a.threadlocal()
uci=require"luci.model.uci"
i18n=require"luci.i18n"
_M.fs=n
local h=nil
local t
function build_url(...)
local a={...}
local e={e.getenv("SCRIPT_NAME")or""}
local t
for a,t in ipairs(a)do
if t:match("^[a-zA-Z0-9_%-%.%%/,;]+$")then
e[#e+1]="/"
e[#e+1]=t
end
end
if#a==0 then
e[#e+1]="/"
end
return table.concat(e,"")
end
function node_visible(e)
if e then
return not(
(not e.title or#e.title==0)or
(not e.target or e.hidden==true)or
(type(e.target)=="table"and e.target.type=="firstchild"and
(type(e.nodes)~="table"or not next(e.nodes)))
)
end
return false
end
function node_childs(e)
local t={}
if e then
local o,o
for a,e in a.spairs(e.nodes,
function(a,t)
return(e.nodes[a].order or 100)
<(e.nodes[t].order or 100)
end)
do
if node_visible(e)then
t[#t+1]=a
end
end
end
return t
end
function error404(t)
e.status(404,"Not Found")
t=t or"Not Found"
local function o()
local e=require"luci.template"
e.render("error404")
end
if not a.copcall(o)then
e.prepare_content("text/plain")
e.write(t)
end
return false
end
function error500(t)
a.perror(t)
if not context.template_header_sent then
e.status(500,"Internal Server Error")
e.prepare_content("text/plain")
e.write(t)
else
require("luci.template")
if not a.copcall(luci.template.render,"error500",{message=t})then
e.prepare_content("text/plain")
e.write(t)
end
end
return false
end
function httpdispatch(o,i)
e.context.request=o
local t={}
context.request=t
local o=e.urldecode(o:getenv("PATH_INFO")or"",true)
if i then
for a,e in ipairs(i)do
t[#t+1]=e
end
end
local i
for e in o:gmatch("[^/%z]+")do
t[#t+1]=e
end
local t,t=a.coxpcall(function()
dispatch(context.request)
end,error500)
e.close()
end
local function y(t)
if type(t)=="table"then
if type(t.post)=="table"then
local o,o,a
for o,t in pairs(t.post)do
a=e.formvalue(o)
if(type(t)=="string"and
a~=t)or
(t==true and a==nil)
then
return false
end
end
return true
end
return(t.post==true)
end
return false
end
function test_post_security()
if e.getenv("REQUEST_METHOD")~="POST"then
e.status(405,"Method Not Allowed")
e.header("Allow","POST")
return false
end
if e.formvalue("token")~=context.authtoken then
e.status(403,"Forbidden")
luci.template.render("csrftoken")
return false
end
return true
end
local function m(t,o)
local e=a.ubus("session","get",{ubus_rpc_session=t})
if type(e)=="table"and
type(e.values)=="table"and
type(e.values.token)=="string"and
(not o or
a.contains(o,e.values.username))
then
uci:set_session_id(t)
return t,e.values
end
return nil,nil
end
local function f(t,o,i)
if a.contains(i,t)then
local o=a.ubus("session","login",{
username=t,
password=o,
timeout=tonumber(luci.config.sauth.sessiontime)
})
local i=context.requestpath
and table.concat(context.requestpath,"/")or""
if type(o)=="table"and
type(o.ubus_rpc_session)=="string"
then
a.ubus("session","set",{
ubus_rpc_session=o.ubus_rpc_session,
values={token=r.uniqueid(16)}
})
io.stderr:write("luci: accepted login on /%s for %s from %s\n"
%{i,t,e.getenv("REMOTE_ADDR")or"?"})
return m(o.ubus_rpc_session)
end
io.stderr:write("luci: failed login on /%s for %s from %s\n"
%{i,t,e.getenv("REMOTE_ADDR")or"?"})
end
return nil,nil
end
function dispatch(s)
local i=context
i.path=s
local o=require"luci.config"
assert(o.main,
"/etc/config/luci seems to be corrupt, unable to find section 'main'")
local d=require"luci.i18n"
local t=o.main.lang or"auto"
if t=="auto"then
local e=e.getenv("HTTP_ACCEPT_LANGUAGE")or""
for a in e:gmatch("[%w_-]+")do
local e,i=a:match("^([a-z][a-z])[_-]([a-zA-Z][a-zA-Z])$")
if e and i then
local a="%s_%s"%{e,i:lower()}
if o.languages[a]then
t=a
break
elseif o.languages[e]then
t=e
break
end
elseif o.languages[a]then
t=a
break
end
end
end
if t=="auto"then
t=d.default
end
d.setlanguage(t)
local t=i.tree
local o
if not t then
t=createtree()
end
local o={}
local h={}
i.args=h
i.requestargs=i.requestargs or h
local c
local u={}
local l={}
for i,e in ipairs(s)do
u[#u+1]=e
l[#l+1]=e
t=t.nodes[e]
c=i
if not t then
break
end
a.update(o,t)
if t.leaf then
break
end
end
if t and t.leaf then
for e=c+1,#s do
h[#h+1]=s[e]
l[#l+1]=s[e]
end
end
i.requestpath=i.requestpath or l
i.path=u
if o.i18n then
d.loadc(o.i18n)
end
if(t and t.index)or not o.notemplate then
local s=require("luci.template")
local t=o.mediaurlbase or luci.config.main.mediaurlbase
if not pcall(s.Template,"themes/%s/header"%n.basename(t))then
t=nil
for a,e in pairs(luci.config.themes)do
if a:sub(1,1)~="."and pcall(s.Template,
"themes/%s/header"%n.basename(e))then
t=e
end
end
assert(t,"No valid theme found")
end
local function h(o,e,t)
if o then
local o=getfenv(3)
local i=(type(o.self)=="table")and o.self
if type(t)=="table"then
if not next(t)then
return''
else
t=a.serialize_json(t)
end
end
return string.format(
' %s="%s"',tostring(e),
a.pcdata(tostring(t
or(type(o[e])~="function"and o[e])
or(i and type(i[e])~="function"and i[e])
or""))
)
else
return''
end
end
s.context.viewns=setmetatable({
write=e.write;
include=function(e)s.Template(e):render(getfenv(2))end;
translate=d.translate;
translatef=d.translatef;
export=function(e,t)if s.context.viewns[e]==nil then s.context.viewns[e]=t end end;
striptags=a.striptags;
pcdata=a.pcdata;
media=t;
theme=n.basename(t);
resource=luci.config.main.resourcebase;
ifattr=function(...)return h(...)end;
attr=function(...)return h(true,...)end;
url=build_url;
},{__index=function(a,t)
if t=="controller"then
return build_url()
elseif t=="REQUEST_URI"then
return build_url(unpack(i.requestpath))
elseif t=="FULL_REQUEST_URI"then
local t={e.getenv("SCRIPT_NAME")or"",e.getenv("PATH_INFO")}
local e=e.getenv("QUERY_STRING")
if e and#e>0 then
t[#t+1]="?"
t[#t+1]=e
end
return table.concat(t,"")
elseif t=="token"then
return i.authtoken
else
return rawget(a,t)or _G[t]
end
end})
end
o.dependent=(o.dependent~=false)
assert(not o.dependent or not o.auto,
"Access Violation\nThe page at '"..table.concat(s,"/").."/' "..
"has no parent node so the access to this location has been denied.\n"..
"This is a software bug, please report this message at "..
"https://github.com/openwrt/luci/issues"
)
if o.sysauth and not i.authsession then
local n=o.sysauth_authenticator
local h,t,a,d,s
if type(n)=="string"and n~="htmlauth"then
error500("Unsupported authenticator %q configured"%n)
return
end
if type(o.sysauth)=="table"then
d,s=nil,o.sysauth
else
d,s=o.sysauth,{o.sysauth}
end
if type(n)=="function"then
h,t=n(r.user.checkpasswd,s)
else
t=e.getcookie("sysauth")
end
t,a=m(t,s)
if not(t and a)and n=="htmlauth"then
local n=e.getenv("HTTP_AUTH_USER")
local h=e.getenv("HTTP_AUTH_PASS")
if n==nil and h==nil then
n=e.formvalue("luci_username")
h=e.formvalue("luci_password")
end
t,a=f(n,h,s)
if not t then
local t=require"luci.template"
context.path={}
e.status(403,"Forbidden")
t.render(o.sysauth_template or"sysauth",{
duser=d,
fuser=n
})
return
end
e.header("Set-Cookie",'sysauth=%s; path=%s; HttpOnly%s'%{
t,build_url(),e.getenv("HTTPS")=="on"and"; secure"or""
})
e.redirect(build_url(unpack(i.requestpath)))
end
if not t or not a then
e.status(403,"Forbidden")
return
end
i.authsession=t
i.authtoken=a.token
i.authuser=a.username
end
if o.cors and e.getenv("REQUEST_METHOD")=="OPTIONS"then
luci.http.status(200,"OK")
luci.http.header("Access-Control-Allow-Origin",e.getenv("HTTP_ORIGIN")or"*")
luci.http.header("Access-Control-Allow-Methods","GET, POST, OPTIONS")
return
end
if t and y(t.target)then
if not test_post_security(t)then
return
end
end
if o.setgroup then
r.process.setgroup(o.setgroup)
end
if o.setuser then
r.process.setuser(o.setuser)
end
local e=nil
if t then
if type(t.target)=="function"then
e=t.target
elseif type(t.target)=="table"then
e=t.target.target
end
end
if t and(t.index or type(e)=="function")then
i.dispatched=t
i.requested=i.requested or i.dispatched
end
if t and t.index then
local e=require"luci.template"
if a.copcall(e.render,"indexer",{})then
return true
end
end
if type(e)=="function"then
a.copcall(function()
local a=getfenv(e)
local o=require(t.module)
local t=setmetatable({},{__index=
function(t,e)
return rawget(t,e)or o[e]or a[e]
end})
setfenv(e,t)
end)
local i,o
if type(t.target)=="table"then
i,o=a.copcall(e,t.target,unpack(h))
else
i,o=a.copcall(e,unpack(h))
end
if not i then
error500("Failed to execute "..(type(t.target)=="function"and"function"or t.target.type or"unknown")..
" dispatcher target for entry '/"..table.concat(s,"/").."'.\n"..
"The called action terminated with an exception:\n"..tostring(o or"(unknown)"))
end
else
local e=node()
if not e or not e.target then
error404("No root node was registered, this usually happens if no module was installed.\n"..
"Install luci-mod-admin-full and retry. "..
"If the module is already installed, try removing the /tmp/luci-indexcache file.")
else
error404("No page is registered at '/"..table.concat(s,"/").."'.\n"..
"If this url belongs to an extension, make sure it is properly installed.\n"..
"If the extension was recently installed, try removing the /tmp/luci-indexcache file.")
end
end
end
function createindex()
local e={}
local o="%s/controller/"%a.libpath()
local t,t
for t in(n.glob("%s*.lua"%o)or function()end)do
e[#e+1]=t
end
for t in(n.glob("%s*/*.lua"%o)or function()end)do
e[#e+1]=t
end
if indexcache then
local a=n.stat(indexcache,"mtime")
if a then
local t=0
for a,e in ipairs(e)do
local e=n.stat(e,"mtime")
t=(e and e>t)and e or t
end
if a>t and r.process.info("uid")==0 then
assert(
r.process.info("uid")==n.stat(indexcache,"uid")
and n.stat(indexcache,"modestr")=="rw-------",
"Fatal: Indexcache is not sane!"
)
h=loadfile(indexcache)()
return h
end
end
end
h={}
for t,e in ipairs(e)do
local t="luci.controller."..e:sub(#o+1,#e-4):gsub("/",".")
local a=require(t)
assert(a~=true,
"Invalid controller file found\n"..
"The file '"..e.."' contains an invalid module line.\n"..
"Please verify whether the module name is set to '"..t..
"' - It must correspond to the file path!")
local a=a.index
assert(type(a)=="function",
"Invalid controller file found\n"..
"The file '"..e.."' contains no index() function.\n"..
"Please make sure that the controller contains a valid "..
"index function and verify the spelling!")
h[t]=a
end
if indexcache then
local e=w.open(indexcache,"w",600)
e:writeall(a.get_bytecode(h))
e:close()
end
end
function createtree()
if not h then
createindex()
end
local t=context
local o={nodes={},inreq=true}
local e={}
t.treecache=setmetatable({},{__mode="v"})
t.tree=o
t.modifiers=e
require"luci.i18n".loadc("base")
local t=setmetatable({},{__index=luci.dispatcher})
for a,e in pairs(h)do
t._NAME=a
setfenv(e,t)
e()
end
local function i(t,a)
return e[t].order<e[a].order
end
for a,e in a.spairs(e,i)do
t._NAME=e.module
setfenv(e.func,t)
e.func()
end
return o
end
function modifier(t,e)
context.modifiers[#context.modifiers+1]={
func=t,
order=e or 0,
module
=getfenv(2)._NAME
}
end
function assign(e,t,a,o)
local e=node(unpack(e))
e.nodes=nil
e.module=nil
e.title=a
e.order=o
setmetatable(e,{__index=_create_node(t)})
return e
end
function entry(e,o,a,t)
local e=node(unpack(e))
e.target=o
e.title=a
e.order=t
e.module=getfenv(2)._NAME
return e
end
function get(...)
return _create_node({...})
end
function node(...)
local e=_create_node({...})
e.module=getfenv(2)._NAME
e.auto=nil
return e
end
function lookup(...)
local t,e=nil,{}
for t=1,select('#',...)do
local a,t=nil,tostring(select(t,...))
for t in t:gmatch("[^/]+")do
e[#e+1]=t
end
end
for a=#e,1,-1 do
local t=context.treecache[table.concat(e,".",1,a)]
if t and(a==#e or t.leaf)then
return t,build_url(unpack(e))
end
end
end
function _create_node(t)
if#t==0 then
return context.tree
end
-- >>>>> patch begin
if path[3] == "firewall" or
	path[3] == "iptables" or
	path[3] == "network" or
	path[3] == "dhcp" or
	path[3] == "hosts" or
	path[3] == "routes" or
	path[3] == "startup" or
	path[3] == "dmesg" or
	path[3] == "leds" or

	-- even more
	-- path[3] == "syslog" or
	-- path[3] == "processes" or
	-- path[3] == "system" or
	-- path[3] == "admin" or
	-- path[3] == "packages" or
	-- path[3] == "crontab" or
	path[3] == "diagnostics"

	then return {}
end
-- <<<< patch end
local a=table.concat(t,".")
local e=context.treecache[a]
if not e then
local o=table.remove(t)
local i=_create_node(t)
e={nodes={},auto=true,inreq=true}
local n,n
for a,t in ipairs(t)do
if context.path[a]~=t then
e.inreq=false
break
end
end
e.inreq=e.inreq and(context.path[#t+1]==o)
i.nodes[o]=e
context.treecache[a]=e
end
return e
end
function _firstchild()
local a={unpack(context.path)}
local e=table.concat(a,".")
local e=context.treecache[e]
local t
if e and e.nodes and next(e.nodes)then
local a,a
for o,a in pairs(e.nodes)do
if not t or
(a.order or 100)<(e.nodes[t].order or 100)
then
t=o
end
end
end
assert(t~=nil,
"The requested node contains no childs, unable to redispatch")
a[#a+1]=t
dispatch(a)
end
function firstchild()
return{type="firstchild",target=_firstchild}
end
function alias(...)
local e={...}
return function(...)
for a,t in ipairs({...})do
e[#e+1]=t
end
dispatch(e)
end
end
function rewrite(o,...)
local t={...}
return function(...)
local e=a.clone(context.dispatched)
for t=1,o do
table.remove(e,1)
end
for t,a in ipairs(t)do
table.insert(e,t,a)
end
for a,t in ipairs({...})do
e[#e+1]=t
end
dispatch(e)
end
end
local function o(e,...)
local t=getfenv()[e.name]
assert(t~=nil,
'Cannot resolve function "'..e.name..'". Is it misspelled or local?')
assert(type(t)=="function",
'The symbol "'..e.name..'" does not refer to a function but data '..
'of type "'..type(t)..'".')
if#e.argv>0 then
return t(unpack(e.argv),...)
else
return t(...)
end
end
function call(e,...)
return{type="call",argv={...},name=e,target=o}
end
function post_on(e,t,...)
return{
type="call",
post=e,
argv={...},
name=t,
target=o
}
end
function post(...)
return post_on(true,...)
end
local t=function(e,...)
require"luci.template".render(e.view)
end
function template(e)
return{type="template",view=e,target=t}
end
local function d(n,...)
local s=require"luci.cbi"
local r=require"luci.template"
local i=require"luci.http"
local t=n.config or{}
local o=s.load(n.model,...)
local e=nil
local h,h
for i,o in ipairs(o)do
if a.instanceof(o,s.SimpleForm)then
io.stderr:write("Model %s returns SimpleForm but is dispatched via cbi(),\n"
%n.model)
io.stderr:write("please change %s to use the form() action instead.\n"
%table.concat(context.request,"/"))
end
o.flow=t
local t=o:parse()
if t and(not e or t<e)then
e=t
end
end
local function a(e)
return type(e)=="table"and build_url(unpack(e))or e
end
if t.on_valid_to and e and e>0 and e<2 then
i.redirect(a(t.on_valid_to))
return
end
if t.on_changed_to and e and e>1 then
i.redirect(a(t.on_changed_to))
return
end
if t.on_success_to and e and e>0 then
i.redirect(a(t.on_success_to))
return
end
if t.state_handler then
if not t.state_handler(e,o)then
return
end
end
i.header("X-CBI-State",e or 0)
if not t.noheader then
r.render("cbi/header",{state=e})
end
local i
local a
local h=false
local s=true
local n={}
for t,e in ipairs(o)do
if e.apply_needed and e.parsechain then
local t
for t,e in ipairs(e.parsechain)do
n[#n+1]=e
end
h=true
end
if e.redirect then
i=i or e.redirect
end
if e.pageaction==false then
s=false
end
if e.message then
a=a or{}
a[#a+1]=e.message
end
end
for e,t in ipairs(o)do
t:render({
firstmap=(e==1),
redirect=i,
messages=a,
pageaction=s,
parsechain=n
})
end
if not t.nofooter then
r.render("cbi/footer",{
flow=t,
pageaction=s,
redirect=i,
state=e,
autoapply=t.autoapply,
trigger_apply=h
})
end
end
function cbi(t,e)
return{
type="cbi",
post={["cbi.submit"]=true},
config=e,
model=t,
target=d
}
end
local function o(e,...)
local a={...}
local t=#a>0 and e.targets[2]or e.targets[1]
setfenv(t.target,e.env)
t:target(unpack(a))
end
function arcombine(t,e)
return{type="arcombine",env=getfenv(),target=o,targets={t,e}}
end
local function i(e,...)
local t=require"luci.cbi"
local o=require"luci.template"
local i=require"luci.http"
local a=luci.cbi.load(e.model,...)
local e=nil
local t,t
for a,t in ipairs(a)do
local t=t:parse()
if t and(not e or t<e)then
e=t
end
end
i.header("X-CBI-State",e or 0)
o.render("header")
for t,e in ipairs(a)do
e:render()
end
o.render("footer")
end
function form(e)
return{
type="cbi",
post={["cbi.submit"]=true},
model=e,
target=i
}
end
translate=i18n.translate
function _(e)
return e
end