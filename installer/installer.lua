local internet=require("internet")
local text=require("text")
local filesystem=require("filesystem")
local unicode=require("unicode")
local term=require("term")
local event=require("event")
local keyboard=require("keyboard")
 
local json = nil

local function getLastCommit()
  local url="https://api.github.com/repos/Dabraleli/DabOS/commits"
    local raw=""
    for chunk in internet.request(url) do
      raw=raw..chunk
    end
    local t=json.decode(raw)
    return t[1]["sha"]
end

local function gitContents(repo, dir)
  local url="https://api.github.com/repos/Dabraleli/DabOS/contents"..dir
  dir = dir .. "/"
  local raw=""
  local files={}
  local directories={}
  for chunk in internet.request(url) do
    raw=raw..chunk
  end
  local t=json.decode(raw)
 
  for i=1,#t do
    if t[i]["type"]=="dir" then
      table.insert(directories,dir..t[i]["name"])
 
      local subfiles,subdirs=gitContents(repo,dir..t[i]["name"])
      for i=1,#subfiles do
        table.insert(files,subfiles[i])
      end
      for i=1,#subdirs do
        table.insert(directories,subdirs[i])
      end
    else
      files[#files+1]=dir..t[i]["name"]
    end
  end
  return files, directories
end

local function getJsonLib()
  print("Загрузка json библиотеки")
  local jsonPath = "/cache/system_update/json.lua"
  filesystem.makeDirectory(filesystem.path(jsonPath))
  loadfile("/bin/wget.lua")("https://github.com/rxi/json.lua/raw/master/json.lua", jsonPath, "-fq")
  json = dofile(jsonPath)
end

local function checkLimit()
  print("Проверка лимита")
  local url = "https://api.github.com/rate_limit"
  raw = ""
  for chunk in internet.request(url) do
      raw = raw..chunk
  end
  jsonData = json.decode(raw)
  if jsonData["rate"]["remaining"] < 5 then
      print("Исчерпан лимит запросов к API, подождите пару минут")
  end
end

print("Клонирование репозитория...") 
getJsonLib()
checkLimit()
print("Установка ОС версии " .. getLastCommit())
local files,dirs=gitContents(repo,"/")
print("Чтение директорий")

for i=1,#dirs do
  print("Создание директории "..dirs[i])
  if filesystem.exists(dirs[i]) then
    if not filesystem.isDirectory(dirs[i]) then
      print("Ошибка: директория "..dirs[i].." блокируется файлом с тем же именем")
      return
    end
  else
    filesystem.makeDirectory(dirs[i])
  end
end
os.sleep(0.1)
for i=1,#files do
  local replace=nil
  if filesystem.exists(files[i]) then
      filesystem.remove(files[i])
  end
  print("Загрузка "..files[i])
  local url="https://raw.github.com/Dabraleli/DabOS/master"..files[i]
  local result,response=pcall(internet.request,url)
  if result then
    local raw=""
    for chunk in response do      
      raw=raw..chunk
    end
    print("Сохранение "..files[i])
    local file=io.open(files[i],"w")
    file:write(raw)
    file:close()
  else
    print("Ошибка, пропуск файла")
  end
end

update_info = {}
update_info["sha"] = getLastCommit()
update_info["time"] = os.time()
local file=io.open("/cache/system_update/current_version","w")
file:write(json.encode(update_info))
file:close()

print("ОС установлена, версия " .. sha)
print("Перезагрузить? [Y/n] ")
if ((io.read() or "n").."y"):match("^%s*[Yy]") then
  print("Перезагрузка!")
  computer.shutdown(true)
end