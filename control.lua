local all = require("mods")

local whitelist = {
    ["core"] = true,
    ["base"] = true,
    ["space-age"] = true,
    ["quality"] = true,
    ["elevated-rails"] = true,
    ["factorio-ai-cn"] = true,
    ["aotixzhcn"] = true,
    ["chinese"] = true,
    ["aotixk2se"] = true,
    ["aotixpy"] = true,
    ["aotixcube"] = true,
    ["GavinQOL"] = true,
}

local up_to_date = {}
local old_translation = {}
local old_mod = {}
local not_translated = {}
for name, version in pairs(script.active_mods) do
    if not whitelist[name] then
        local translation_version = all[name]
        if translation_version == nil then
            table.insert(not_translated, name)
            goto continue
        end
        local cmp = helpers.compare_versions(version, translation_version)
        if cmp == 0 then
            table.insert(up_to_date, name)
        elseif cmp < 0 then
            table.insert(old_translation, name)
        else
            table.insert(old_mod, name)
        end
    end
    ::continue::
end

script.on_configuration_changed(
    function()
        for _, player in pairs(game.players) do
            if player.locale == "zh-CN" then
                player.print("【提示】欢迎使用AI汉化，使用/locale_stats可以查看汉化覆盖情况。")
            end
        end
    end
)

commands.add_command(
    "locale_stats",
    nil,
    function(command)
        if command.player_index ~= nil then
            local player = game.get_player(command.player_index)
            if player.locale == "zh-CN" then
                player.print("【提示】此消息仅你可见。")
                if #up_to_date > 0 then
                    player.print("翻译覆盖: " .. table.concat(up_to_date, ", "))
                end
                if #old_translation > 0 then
                    player.print("翻译过时: " .. table.concat(old_translation, ", "))
                end
                if #old_mod > 0 then
                    player.print("模组过时: " .. table.concat(old_mod, ", "))
                end
                if #not_translated > 0 then
                    player.print("无翻译: " .. table.concat(not_translated, ","))
                    player.print("无翻译不代表模组没有汉化，也有可能有以下原因：模组内置汉化；模组无可汉化内容，如为图形资源或函数库")
                end
                player.print("本翻译对模组名的处理为，若原文提供了对应键值，则认为原作者意图其他翻译人翻译，否则保留原文。")
                player.print("前往 https://mods.factorio.com/mod/factorio-ai-cn 查看更多信息。")
            end
        end
    end
)
