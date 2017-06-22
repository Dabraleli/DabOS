local internet=require("internet")
local text=require("text")
local filesystem=require("filesystem")
local unicode=require("unicode")
local term=require("term")
local event=require("event")
local keyboard=require("keyboard")
local json=require("json")

local function getLastCommit()
  local url="https://api.github.com/repos/Dabraleli/DabOS/commits"
  local raw=""
  for chunk in internet.request(url) do
    raw=raw..chunk
  end
  local t=json.decode(raw)
  return t[1]["sha"]
end

local function getCurrentCommit()
  local file=io.open("/cache/system_update/current_version", "r")
  local jsonData = json.decode(file:read("*all"))
  file:close()
  return jsonData["sha"]
end

local function updateCommitInfo(time, sha)
  local file=io.open("/cache/system_update/current_version", "w")
  local jsonData = {}
  jsonData["time"] = time
  jsonData["sha"] = sha
  file:write(json.encode(jsonData))
  file:close()
end


local function getChanges()
  local url="https://api.github.com/repos/Dabraleli/DabOS/compare/" .. getCurrentCommit() .. "..." .. getLastCommit()
  local raw=""
  for chunk in internet.request(url) do
    raw=raw..chunk
  end
  local t=json.decode(raw)
  local files = t["files"]
  for i = 1, #files do
    if files[i]["type"] == "modified" then
      filesystem.remove("/"..files[i]["filename"])
      local result,response=pcall(internet.request,files[i]["raw_url"])
      if result then
        local rawF=""
        for chunkF in response do      
          rawF=rawF..chunkF
        end
        print("Сохранение ".."/"..files[i]["filename"])
        local fileD=io.open("/"..files[i]["filename"],"w")
        fileD:write(rawF)
        fileD:close()
      else
        print("Ошибка, пропуск файла")
      end
    else if files[i]["type"] == "removed" then
      filesystem.remove("/"..files[i]["filename"])
      end
    end
  end
  updateCommitInfo(os.time(), getLastCommit())
  print("Обновление завершено")
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

checkLimit()
if getCurrentCommit() == getLastCommit() then
  print("Нет доступных обновлений")
else 
  print("Обновление")
  getChanges()
end