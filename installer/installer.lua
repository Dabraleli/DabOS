local fs = require("filesystem")
 
print("Клонирование репозитория...")
 
local internet=require("internet")
local text=require("text")
local filesystem=require("filesystem")
local unicode=require("unicode")
local term=require("term")
local event=require("event")
local keyboard=require("keyboard")
 
local repo,target
 
repo="Dabraleli/DabOS"
 
target="/"
 
local function gitContents(repo,dir)
  local url="https://api.github.com/repos/"..repo.."/contents"..dir
  print(url)
  dir = dir .. "/"
  local raw=""
  local files={}
  local directories={}
  for chunk in internet.request(url) do
    raw=raw..chunk
  end
  raw=raw:gsub("%[","{"):gsub("%]","}"):gsub("(\".-\"):(.-[,{}])",function(a,b) return "["..a.."]="..b end)
  local t=load("return "..raw)()
 
  for i=1,#t do
    if t[i].type=="dir" then
      table.insert(directories,dir..t[i].name)
 
      local subfiles,subdirs=gitContents(repo,dir..t[i].name)
      for i=1,#subfiles do
        table.insert(files,subfiles[i])
      end
      for i=1,#subdirs do
        table.insert(directories,subdirs[i])
      end
    else
      files[#files+1]=dir..t[i].name
    end
  end
  return files, directories
end
 
 
print("Проверка лимита")
local url = "https://api.github.com/rate_limit"
raw = ""
for chunk in internet.request(url) do
  raw = raw..chunk
end
raw=raw:gsub("%[","{"):gsub("%]","}"):gsub("(\".-\"):(.-[,{}])",function(a,b) return "["..a.."]="..b end)
local t=load("return "..raw)()
print(t.resources.rate.remaining)
 
 
local files,dirs=gitContents(repo,"/OS")
print("Чтение директорий")
 
for i=1,#dirs do
  print("Создание директории "..string.sub(dirs[i], 4))
  if filesystem.exists(string.sub(dirs[i], 4)) then
    if not filesystem.isDirectory(string.sub(dirs[i], 4)) then
      print("Ошибка: директория "..string.sub(dirs[i], 4).." блокируется файлом с тем же именем")
      return
    end
  else
    filesystem.makeDirectory(string.sub(dirs[i], 4))
  end
end
 
for i=1,#files do
  local replace=nil
  if filesystem.exists(string.sub(files[i], 4)) then
      filesystem.remove(string.sub(files[i], 4))
  end
  print("Загрузка "..string.sub(files[i], 4))
  local url="https://raw.github.com/"..repo.."/master"..files[i]
  local result,response=pcall(internet.request,url)
  if result then
    local raw=""
    for chunk in response do      
      raw=raw..chunk
    end
    print("Сохранение "..string.sub(files[i], 4))
    local file=io.open(string.sub(files[i], 4),"w")
    file:write(raw)
    file:close()
  else
    print("Ошибка, пропуск файла")
  end
end
print("ОС установлена")
print("Через секунду компьютер будет перезагружен")
os.sleep(1)
computer.shutdown(true)