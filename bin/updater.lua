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

local function getChanges()
  local url="https://api.github.com/repos/Dabraleli/DabOS/compare/" .. getCurrentCommit() .. "... " .. getLastCommit()
  local raw=""
  for chunk in internet.request(url) do
    raw=raw..chunk
  end
  local t=json.decode(raw)
  print(json.decode(t["files"]))
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