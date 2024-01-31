local ccChat = exports['cc-chat']

RegisterNetEvent('cc-rpchat:addMessage')
AddEventHandler('cc-rpchat:addMessage', function(color, icon, subtitle, msg, showTime)
    if showTime ~= false then
        Timestamp = ccChat:getTimestamp()
    else
        Timestamp = ''
    end
    TriggerEvent('chat:addMessage', { templateId = 'ccChat', multiline = false, args = { color, icon, subtitle, Timestamp, msg } })
end)

RegisterNetEvent('cc-rpchat:addProximityMessage')
AddEventHandler('cc-rpchat:addProximityMessage', function(color, icon, subtitle, msg, id, pCords)
  Timestamp = ccChat:getTimestamp()
  local myId = PlayerId()
  local pid = GetPlayerFromServerId(id)
  if pid == myId then
    TriggerEvent('chat:addMessage', { templateId = 'ccChat', multiline = false, args = { color, icon, subtitle, Timestamp, msg } })
---@diagnostic disable-next-line: missing-parameter
  elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myId)), pCords, true) < 19.999 then
    TriggerEvent('chat:addMessage', { templateId = 'ccChat', multiline = false, args = { color, icon, subtitle, Timestamp, msg } })
  end
end)