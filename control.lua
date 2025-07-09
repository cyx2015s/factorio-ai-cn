local translated = require("mods")
local skipped = require("skipped")

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
local skipped_enabled = {}
local skipped_builtin = {}
local skipped_graphic = {}
for name, version in pairs(script.active_mods) do
    if not whitelist[name] then
        if skipped[name] then
            if skipped[name]["reason"] == "builtin" then
                table.insert(skipped_builtin, name)
            end
            if skipped[name]["reason"] == "graphic" then
                table.insert(skipped_graphic, name)
            end
            table.insert(skipped_enabled, name)
            goto continue
        end
        local translation_version = translated[name]
        if translation_version == nil then
            table.insert(not_translated, name)
            goto continue
        end
        local cmp = helpers.compare_versions(version, translation_version)
        if cmp == 0 then
            table.insert(up_to_date, name)
        elseif cmp > 0 then
            table.insert(old_translation, name)
        else
            table.insert(old_mod, name)
        end
    end
    ::continue::
end

local enter_str = "【提示】欢迎使用AI汉化，点击快捷栏的DeepSeek按钮可查看汉化覆盖情况，并向作者请求新的汉化。"

script.on_configuration_changed(
    function()
        for _, player in pairs(game.players) do
            if player.locale == "zh-CN" then
                player.print(enter_str)
            end
            if player.name == "tanvec" then
                player.tag = "切向量"
            end
        end
    end
)

script.on_event(
    defines.events.on_player_joined_game,
    function(event)
        local player = game.get_player(event.player_index)
        if player and player.locale == "zh-CN" then
            player.print(enter_str)
        end
        if player and player.name == "tanvec" then
            player.tag = "切向量"
        end
    end
)

script.on_init(
    function()
        for _, player in pairs(game.players) do
            if player.locale == "zh-CN" then
                player.print(enter_str)
            end
        end
    end
)

script.on_event(
    defines.events.on_lua_shortcut,
    function(event)
        local log_str = ""
        if event.player_index ~= nil and event.prototype_name == "show-locale-stats" then
            local player = game.get_player(event.player_index)
            if player and player.locale == "zh-CN" then
            else
                return
            end
            if player.gui.screen.locale_stats_frame then
                player.gui.screen.locale_stats_frame.destroy()
                return
            end
            log_str = log_str .. "【提示】此消息仅你可见。"
            if #up_to_date > 0 then
                log_str = log_str .. ("\n翻译覆盖: " .. table.concat(up_to_date, ", "))
            end
            if #old_translation > 0 then
                log_str = log_str .. ("\n翻译过时: " .. table.concat(old_translation, ", "))
            end
            if #old_mod > 0 then
                log_str = log_str .. ("\n模组过时: " .. table.concat(old_mod, ", "))
            end
            if #up_to_date + #old_translation + #old_mod > 0 then
                log_str = log_str ..
                    ("\n显示已翻译不代表模组一定全部按照中文显示。原模组代码中硬编码的字符串无法翻译或代价过大。（如检测代码中的显示字符串，然后更改原模组中的硬编码字符串为本地化字符串。）")
            end
            if #skipped_builtin > 0 then
                log_str = log_str .. ("\n跳过自带翻译模组（尝试翻译时发现词条覆盖率 > 80%）: " .. table.concat(skipped_builtin, ", "))
            end
            if #skipped_graphic > 0 then
                log_str = log_str .. ("\n跳过图形资源模组: " .. table.concat(skipped_graphic, ", "))
            end
            if #not_translated > 0 then
                log_str = log_str .. ("\n无翻译: " .. table.concat(not_translated, ", "))
                log_str = log_str .. ("\n无翻译不代表模组没有汉化，也有可能有以下原因：模组内置汉化；模组无可汉化内容，如为图形资源或函数库")
            end
            log_str = log_str .. ("\n本翻译对模组名的处理为，若原文提供了对应键值，则认为原作者意图其他翻译人翻译，否则保留原文。")
            log_str = log_str .. ("\n本模组提供的翻译内容全部为 AI 翻译，请仔细辨别使用。")
            log_str = log_str .. ("\n前往 https://mods.factorio.com/mod/factorio-ai-cn 查看更多信息。作者：切向量/tanvec")
            log_str = log_str .. ("\n\n可以复制以下文本框中的内容并提交给我，以便我增加翻译。")
            local frame = player.gui.screen.add {
                type = "frame",
                name = "locale_stats_frame",
                caption = "汉化覆盖情况",
                direction = "vertical",
            }
            frame.style.height = 480
            frame.style.width = 600
            frame.style.vertically_squashable = true
            local scroll_pane = frame.add {
                type = "scroll-pane",
                name = "locale_stats_scroll_pane",
            }
            scroll_pane.style.vertically_stretchable = true
            scroll_pane.style.horizontally_stretchable = true
            local label = scroll_pane.add {
                type = "label",
                name = "locale_stats_label",
                caption = log_str,
            }
            label.style.single_line = false
            local textbox = scroll_pane.add {
                type = "text-box",
                name = "locale_stats_textfield",
                caption = "可以复制以下信息并导出提供给我。",
                text = helpers.table_to_json(
                    {
                        up_to_date = up_to_date,
                        old_translation = old_translation,
                        old_mod = old_mod,
                        not_translated = not_translated,
                        skipped_enabled = skipped_enabled,
                    }
                ),
                tooltip = "点击后自动全选，按Ctrl + C复制"
            }
            textbox.word_wrap = true
            textbox.read_only = true
            textbox.style.height = 200
            textbox.style.width = 550


            local close_button = frame.add {
                type = "button",
                name = "locale_stats_close_button",
                caption = "关闭",
            }
            frame.force_auto_center()
        end
    end
)

script.on_event(
    defines.events.on_gui_click,
    function(event)
        if event.element and event.element.valid and event.element.name == "locale_stats_close_button" then
            local player = game.get_player(event.player_index)
            if player and player.gui.screen.locale_stats_frame then
                player.gui.screen.locale_stats_frame.destroy()
            end
        end
        if event.element and event.element.valid and event.element.name == "locale_stats_textfield" then
            local player = game.get_player(event.player_index)
            if player and player.gui.screen.locale_stats_frame then
                player.gui.screen.locale_stats_frame.locale_stats_scroll_pane.locale_stats_textfield.select_all()
            end
        end
    end
)
